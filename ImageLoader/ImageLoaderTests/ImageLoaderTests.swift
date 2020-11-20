//
//  ImageLoaderTests.swift
//  ImageLoaderTests
//
//  Created by Hugo Alonso on 20/11/2020.
//

import XCTest
import Foundation
import ImageLoader
import AppKit
import Kingfisher

class ImageLoaderTests: XCTestCase {
    func testExample() {
        let view = NSImageView()
        let url = URL(string: "https://www.google.com/images/branding/googlelogo/1x/googlelogo_color_272x92dp.png")!

        let imageLoader = ImageLoader(url: url, uniqueKey: "sdf").image

        let expect = expectation(description: "A request is made")

        var receivedError: Error?
        imageLoader.render(on: view) { error in
            receivedError = error
            expect.fulfill()
        }
        wait(for: [expect], timeout: 5.0)

        XCTAssertNotNil(view.image)
        XCTAssertNil(receivedError)
    }

    func testPrefetchExample() {
        let url = URL(string: "https://www.google.com/images/branding/googlelogo/1x/googlelogo_color_272x92dp.png")!
        let imageLoader = ImageLoader(url: url, uniqueKey: "sdf").image

        let expect = expectation(description: "A request is made")

        var receivedError: Error?
        imageLoader.prefetch() { error in
            receivedError = error
            expect.fulfill()
        }
        wait(for: [expect], timeout: 5.0)

        XCTAssertNil(receivedError)
    }
}
