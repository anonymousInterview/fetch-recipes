//
//  HTTPClient.swift
//  Networking
//
//

import Foundation

public protocol HTTPClient: Sendable {
    func get(url: URL) async throws -> Data
    func data(from: URL) async throws -> (Data, URLResponse)
}

/// An implementation of HTTPClient
public final class DefaultHTTPClient: HTTPClient {
    let session: URLSession = {
        // For this exercise, let's disable URL caching.
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        configuration.urlCache = nil
        return URLSession(configuration: configuration)
    }()

    public func data(from url: URL) async throws -> (Data, URLResponse) {
        try await session.data(from: url)
    }

    public func get(url: URL) async throws -> Data {
        var urlRequest = URLRequest(url: url)
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        let (data, response) = try await session.data(for: urlRequest)
        if
            let httpUrlResponse = response as? HTTPURLResponse,
            httpUrlResponse.statusCode == 200
        {
            return data
        } else {
            throw URLError(.badServerResponse)
        }
    }

    public init() {}
}
