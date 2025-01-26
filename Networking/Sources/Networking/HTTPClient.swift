//
//  HTTPClient.swift
//  Networking
//
//

import Foundation

public protocol HTTPClient: Sendable {
    func get(url: URL) async throws -> Data
}

/// An implementation of HTTPClient
public final class DefaultHTTPClient: HTTPClient {
    public func get(url: URL) async throws -> Data {
        var urlRequest = URLRequest(url: url)
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        // For this exercise, let's disable URL caching.
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        configuration.urlCache = nil
        
        let session = URLSession(configuration: configuration)
        let (data, response) = try await session.data(for: urlRequest)
        if
            let httpUrlResponse = response as? HTTPURLResponse,
            httpUrlResponse.statusCode == 200 {
            return data
        } else {
            // TODO: Improve error handling, unknown is vague
            throw URLError(.badServerResponse)
        }
    }
    
    public init() {}
}
