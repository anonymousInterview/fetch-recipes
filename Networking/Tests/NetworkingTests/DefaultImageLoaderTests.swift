//
//  DefaultImageLoaderTests.swift
//  Networking
//
//

import Foundation
@testable import Networking
import Testing
import UIKit

struct DefaultImageLoaderTests {
    final actor MockDataCache: DataCache {
        private var cache: [String: Data] = [:]
        func data(for key: String) -> Data? {
            return cache[key]
        }

        func set(_ data: Data, forKey key: String) {
            cache[key] = data
        }
    }

    final class MockHTTPClient: HTTPClient {
        func get(url _: URL) async throws -> Data {
            Data()
        }

        nonisolated(unsafe) var mockDataResponse: (Data, URLResponse)?
        nonisolated(unsafe) var mockError: Error?
        nonisolated(unsafe) var didFetchData = false

        func data(from _: URL) async throws -> (Data, URLResponse) {
            didFetchData = true
            if let error = mockError {
                throw error
            }
            if let response = mockDataResponse {
                return response
            }
            throw URLError(.badURL)
        }
    }

    @Test func shouldFetchFromNetworkOnCacheMiss() async throws {
        let mockCache = MockDataCache()
        let mockClient = MockHTTPClient()
        let imageURL = URL(string: "https://example.com/image.png")!
        let expectedImageData = UIImage(systemName: "fork.knife")!.pngData()!
        mockClient.mockDataResponse = (expectedImageData, HTTPURLResponse(url: imageURL, statusCode: 200, httpVersion: nil, headerFields: nil)!)

        let loader = DefaultImageLoader(cache: mockCache, client: mockClient)
        let image = try await loader.retrieveImage(for: imageURL)
        #expect(mockClient.didFetchData)
    }

    @Test func shouldRetrieveImageFromCache() async throws {
        // Arrange
        let mockCache = MockDataCache()
        let mockClient = MockHTTPClient()
        let imageURL = URL(string: "https://example.com/image.png")!
        let downloadedImageData = UIImage(systemName: "fork.knife")!.pngData()!
        await mockCache.set(downloadedImageData, forKey: imageURL.absoluteString)
        let loader = DefaultImageLoader(cache: mockCache, client: mockClient)
        _ = try await loader.retrieveImage(for: imageURL)
        let cachedData = await mockCache.data(for: imageURL.absoluteString)
        #expect(cachedData == downloadedImageData)
        #expect(!mockClient.didFetchData)
    }
}
