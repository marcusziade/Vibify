import Combine
import Foundation
import SwiftUI
import UIKit

/// Protocol that defines the requirements for an image caching system.
protocol ImageCache {
    /// Subscript to get or set images for a URL.
    subscript(_ url: URL) -> UIImage? { get set }
}

/// A default implementation of `ImageCache` using `NSCache` to store images.
class DefaultImageCache: ImageCache {
    private var cache = NSCache<NSURL, UIImage>()
    
    /// Access images by subscripting with a URL.
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
        url: URL?,
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
        case .idle, .loading, .noURL:
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

/// Extension to encapsulate the view model of the `CachedAsyncImage`.
extension CachedAsyncImage {
    
    /// ViewModel managing the state of the image loading process.
    final class ViewModel: ObservableObject {
        /// Published property for the current state of the image loading process.
        @Published var state: LoadState = .idle
        
        /// Enumeration of possible states for the image loading process.
        enum LoadState {
            case idle
            case loading
            case loaded(UIImage)
            case failed
            case noURL
        }
        
        init(url: URL?, cache: ImageCache) {
            self.url = url
            self.cache = cache
            if url == nil {
                state = .noURL
            }
        }
        
        /// Begins the image loading process.
        func loadImage() {
            guard let url = url else {
                state = .noURL
                return
            }
            
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
        
        // MARK: Private
        
        private let url: URL?
        private var cache: ImageCache
        private var cancellable: AnyCancellable?
        
    }
}

extension CachedAsyncImage.ViewModel.LoadState: Equatable {
    
    static func == (
        lhs: CachedAsyncImage.ViewModel.LoadState,
        rhs: CachedAsyncImage.ViewModel.LoadState
    ) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.loading, .loading), (.failed, .failed):
            return true
        case (let .loaded(lhsImage), let .loaded(rhsImage)):
            return lhsImage.pngData() == rhsImage.pngData()
        default:
            return false
        }
    }
}
