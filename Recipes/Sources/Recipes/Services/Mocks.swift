//
//  Mocks.swift
//  Recipes
//
//
import Foundation
import Networking
import UIKit

final class MockHTTPClient: HTTPClient {
    func data(from _: URL) async throws -> (Data, URLResponse) {
        return (Data(), URLResponse())
    }

    let customResponse: Data?
    func get(url _: URL) async throws -> Data {
        if let customResponse {
            return customResponse
        } else {
            return """
            {
                "recipes": [
                    {
                        "cuisine": "Malaysian",
                        "name": "Apam Balik",
                        "photo_url_large": "https://d3jbb8n5wk0qxi.cloudfront.net/photos/b9ab0071-b281-4bee-b361-ec340d405320/large.jpg",
                        "photo_url_small": "https://d3jbb8n5wk0qxi.cloudfront.net/photos/b9ab0071-b281-4bee-b361-ec340d405320/small.jpg",
                        "source_url": "https://www.nyonyacooking.com/recipes/apam-balik~SJ5WuvsDf9WQ",
                        "uuid": "0c6ca6e7-e32a-4053-b824-1dbf749910d8",
                        "youtube_url": "https://www.youtube.com/watch?v=6R8ffRRJcrg"
                    }
                ]
            }
            """.data(using: .utf8)!
        }
    }

    init(customResponse: Data? = nil) {
        self.customResponse = customResponse
    }
}

final class MockImageLoader: ImageLoader {
    func retrieveImage(for _: URL) async throws -> UIImage {
        UIImage(systemName: "fork.knife")!
    }
}
