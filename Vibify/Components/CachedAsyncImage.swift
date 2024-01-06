import Combine
import Foundation
import SwiftUI
import UIKit

protocol ImageCache {
    subscript(_ url: URL) -> UIImage? { get set }
}

class DefaultImageCache: ImageCache {
    private var cache = NSCache<NSURL, UIImage>()
    
    subscript(_ url: URL) -> UIImage? {
        get {
            cache.object(forKey: url as NSURL)
        }
        set {
            newValue == nil
            ? cache.removeObject(forKey: url as NSURL)
            : cache.setObject(newValue!, forKey: url as NSURL)
        }
    }
}

struct CachedAsyncImage: View {
    @StateObject private var viewModel: ViewModel
    
    var placeholder: Image
    var errorImage: Image
    
    init(
        url: URL,
        placeholder: Image = Image(systemName: "photo"),
        errorImage: Image = Image(systemName: "multiply.circle"),
        cache: ImageCache = DefaultImageCache()
    ) {
        _viewModel = StateObject(wrappedValue: ViewModel(url: url, cache: cache))
        self.placeholder = placeholder
        self.errorImage = errorImage
    }
    
    var body: some View {
        content
            .onAppear(perform: viewModel.loadImage)
    }
    
    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            placeholder
        case .failed:
            errorImage
                .onTapGesture {
                    viewModel.loadImage()
                }
        case .loaded(let image):
            Image(uiImage: image)
                .resizable()
        }
    }
}

extension CachedAsyncImage {
    
    final class ViewModel: ObservableObject {
        @Published var state: LoadState = .idle
        
        enum LoadState {
            case idle
            case loading
            case loaded(UIImage)
            case failed
        }
        
        private let url: URL
        private var cache: ImageCache
        private var cancellable: AnyCancellable?
        
        init(url: URL, cache: ImageCache) {
            self.url = url
            self.cache = cache
        }
        
        func loadImage() {
            if let image = cache[url] {
                state = .loaded(image)
                return
            }
            
            state = .loading
            cancellable = URLSession.shared.dataTaskPublisher(for: url)
                .map { UIImage(data: $0.data) }
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { [unowned self] completion in
                    if case .failure = completion {
                        state = .failed
                    }
                }, receiveValue: { [unowned self] image in
                    guard let image else { return }
                    state = .loaded(image)
                    cache[url] = image
                })
        }
    }
}
