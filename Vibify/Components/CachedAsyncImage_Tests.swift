import XCTest
@testable import Vibify

final class CachedAsyncImage_Tests: XCTestCase {
    
    var viewModel: CachedAsyncImage.ViewModel!
    var mockCache: MockImageCache!
    var urlSession: URLSession!
    
    override func setUp() {
        super.setUp()
        mockCache = MockImageCache()
        urlSession = URLSession(configuration: .ephemeral)
        viewModel = CachedAsyncImage.ViewModel(url: URL(string: "https://example.com/image.jpg")!, cache: mockCache)
    }
    
    override func tearDown() {
        viewModel = nil
        mockCache = nil
        urlSession = nil
        super.tearDown()
    }
    
    func testViewModel_InitialState_ShouldBeIdle() {
        XCTAssertEqual(viewModel.state, .idle)
    }
    
    func testViewModel_LoadImage_CacheHit_ShouldSetLoadedState() {
        let expectedImage = UIImage()
        mockCache.stubbedImage = expectedImage
        viewModel.loadImage()
        XCTAssertEqual(viewModel.state, .loaded(expectedImage))
    }
    
    func testCache_Miss_ShouldReturnNil() {
        let missingURL = URL(string: "https://example.com/missing-image.jpg")!
        XCTAssertNil(mockCache[missingURL])
    }
    
    func testViewModel_LoadImage_CacheMiss_ShouldNotChangeState() {
        let missingURL = URL(string: "https://example.com/missing-image.jpg")!
        viewModel = CachedAsyncImage.ViewModel(url: missingURL, cache: mockCache)
        viewModel.loadImage()
        XCTAssertEqual(viewModel.state, .loading, "State should transition to loading on cache miss")
    }
    
    func testCache_StoresAndRetrievesImages() {
        let testImage = UIImage(systemName: "photo")!
        let testURL = URL(string: "https://example.com/test-image.jpg")!
        mockCache[testURL] = testImage
        let retrievedImage = mockCache[testURL]
        XCTAssertNotNil(retrievedImage, "Image should be retrieved from cache")
        XCTAssertEqual(retrievedImage?.pngData(), testImage.pngData(), "Retrieved image should be the same as the one stored")
    }
    
    func testViewModel_CacheEviction_ShouldHandleCacheMiss() {
        // Configure the mock cache to simulate eviction
        mockCache.evictsImages = true
        
        let testImage = UIImage(systemName: "photo")!
        let testURL = URL(string: "https://example.com/test-image.jpg")!
        
        // Store the image in the mock cache
        mockCache[testURL] = testImage
        
        // Simulate image eviction
        mockCache.evictImages()
        
        // Attempt to load the image, which should now result in a cache miss
        viewModel.loadImage()
        
        // Verify that the ViewModel handles the cache miss
        XCTAssertEqual(viewModel.state, .loading, "ViewModel should transition to loading after a cache miss")
    }
    
    func testViewModel_RetryAfterFailure_ShouldAttemptReload() {
        // Simulate a failure state
        viewModel.state = .failed(.decodingError)
        
        // Attempt to load the image again
        viewModel.loadImage()
        
        // Verify the ViewModel attempts to reload the image
        XCTAssertEqual(viewModel.state, .loading, "ViewModel should transition to loading on retry")
    }
    
    func testViewModel_CacheReuse_ShouldNotReloadImage() {
        let testImage = UIImage(systemName: "photo")!
        let testURL = URL(string: "https://example.com/test-image.jpg")!
        
        // Store the image in the cache and set the ViewModel to loaded state
        mockCache[testURL] = testImage
        viewModel.state = .loaded(testImage)
        
        // Call loadImage and verify that the state does not change
        viewModel.loadImage()
        XCTAssertEqual(viewModel.state, .loaded(testImage), "ViewModel should not change state if the image is already loaded")
    }
}

final class MockImageCache: ImageCache {
    var stubbedImage: UIImage?
    var didSetImage = false
    var evictsImages = false
    
    subscript(_ url: URL) -> UIImage? {
        get {
            if evictsImages { return nil }
            return stubbedImage
        }
        set {
            stubbedImage = newValue
            didSetImage = true
        }
    }
    
    func evictImages() {
        stubbedImage = nil
    }
}
