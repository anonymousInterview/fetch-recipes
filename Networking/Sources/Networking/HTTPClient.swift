//
//  HTTPClient.swift
//  Networking
//
//


import Foundation

enum NetworkingError: Error {
    case unableToConstructURL
    case unknown
}

public protocol HTTPClient {
    func get(url: URL) async throws -> Data
}

public class DefaultHTTPClient: HTTPClient {
    public func get(url: URL) async throws -> Data {
        do {
            var urlRequest = URLRequest(url: url)
            urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            if
                let httpUrlResponse = response as? HTTPURLResponse,
                httpUrlResponse.statusCode == 200 {
                return data
            } else {
                // TODO: Improve error handling, unknown is vague
                throw NetworkingError.unknown
            }
        } catch let error {
            print(error)
            throw error
        }
    }
}
