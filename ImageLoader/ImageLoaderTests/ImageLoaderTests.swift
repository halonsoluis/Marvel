//
//  ImageLoaderTests.swift
//  ImageLoaderTests
//
//  Created by Hugo Alonso on 20/11/2020.
//

import XCTest
import Foundation
import ImageLoader
@testable import Kingfisher

import UIKit

//Taken from https://stackoverflow.com/a/48441178/2683201
extension UIColor {
    func image(_ size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { rendererContext in
            self.setFill()
            rendererContext.fill(CGRect(origin: .zero, size: size))
        }
    }
}

class ImageLoaderTests: XCTestCase {

    class MockImageDownloader: ImageDownloader {
        static var image: UIImage?

        override func downloadImage(
            with url: URL,
            options: KingfisherParsedOptionsInfo,
            completionHandler: ((Result<ImageLoadingResult, KingfisherError>) -> Void)? = nil) -> DownloadTask? {
            if let image = Self.image {
                completionHandler?(
                    .success(ImageLoadingResult(image: image, url: url, originalData: image.pngData()!))
                )
            } else {
                completionHandler?(
                    .failure(.requestError(reason: .invalidURL(request: URLRequest(url: url))))
                )
            }
            return nil
        }
    }

    override class func setUp() {
        super.setUp()

        let mockDownloader = MockImageDownloader(name: "mock")
        KingfisherManager.shared.downloader = mockDownloader
    }

    func testAttemptToRender_anUnloadImage_DisplaysNoImage() {
        let (imageLoader, view) = createSUT(image: nil)

        let receivedError = receivedErrorFromRender(from: imageLoader, view: view)

        XCTAssertNotNil(receivedError)
        XCTAssertNil(view.image)
    }

    func testAttemptToPrefetch_anUnloadedImageFromANotValidURL_DoesNotSetAnImageOnAView() {
        let (imageLoader, view) = createSUT(image: nil)

        let receivedError = receivedErrorFromPrefetch(from: imageLoader)

        XCTAssertNil(view.image)
        XCTAssertNotNil(receivedError)
    }

    func testAttemptToPrefetch_anUnloadedImage_DoesNotSetAnImageOnAView() {
        let (imageLoader, _) = createSUT()

        let receivedError = receivedErrorFromPrefetch(from: imageLoader)

        XCTAssertNil(receivedError)
    }

    func testAfterPrefetch_aRender_SetsTheImageInTheView() {
        let (imageLoader, view) = createSUT()

        let _ = receivedErrorFromPrefetch(from: imageLoader)
        let _ = receivedErrorFromRender(from: imageLoader, view: view)

        XCTAssertNotNil(view.image)
    }

    func testAfterFailedPrefetch_aRender_DoesNotSetTheImageInTheView() {
        let (imageLoader, view) = createSUT(image: nil)

        let receivedError = receivedErrorFromPrefetch(from: imageLoader)
        let _ = receivedErrorFromRender(from: imageLoader, view: view)

        XCTAssertNil(view.image)
        XCTAssertNotNil(receivedError)
    }

    private func receivedErrorFromPrefetch(from imageLoader: ImageCreator) -> Error? {
        let expect = expectation(description: "A request to prefetch is made")

        var receivedError: Error?
        imageLoader.image.prefetch() { error in
            receivedError = error
            expect.fulfill()
        }
        wait(for: [expect], timeout: 1.0)
        return receivedError
    }

    private func receivedErrorFromRender(from imageLoader: ImageCreator, view: UIImageView) -> Error? {
        let expect = expectation(description: "A request to render is made")

        var receivedError: Error?
        imageLoader.image.render(on: view) { error in
            receivedError = error
            expect.fulfill()
        }
        wait(for: [expect], timeout: 1.0)
        return receivedError
    }

    private func createSUT(uniqueKey: String = UUID().uuidString, image: UIImage? = UIColor.black.image(CGSize(width: 1, height: 1))) -> (imageLoader: ImageCreator, view: UIImageView){
        let url = URL(string: "https://www.anyurl.com/image.png")!
        let imageLoader = ImageCreator(url: url, uniqueKey: uniqueKey)
        let view = UIImageView()

        MockImageDownloader.image = image

        return (imageLoader: imageLoader, view: view)
    }

    override class func tearDown() {
        super.tearDown()

        KingfisherManager.shared.cache.clearCache()
    }
}
