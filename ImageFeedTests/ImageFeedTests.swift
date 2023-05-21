//
//  ImageFeedTests.swift
//  ImageFeedTests
//
//  Created by Igor Ignatov on 21.05.2023.
//
@testable import ImageFeed
import XCTest

final class ImageFeedTests: XCTestCase {
    func testExample() throws {
        let service = ImagesListService()
        
        let expectation = self.expectation(description: "Wait for Notification")
        NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main) { _ in
                expectation.fulfill()
            }
        
        service.fetchPhotosNextPage()
        wait(for: [expectation], timeout: 10)
        
        XCTAssertEqual(service.photos.count, 10)
    }
}
