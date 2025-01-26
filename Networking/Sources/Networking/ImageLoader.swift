//
//  ImageLoader.swift
//  Networking
//
//

import Foundation
import UIKit
import OSLog

public protocol ImageLoader: Sendable {
    func retrieveImage(for url: URL) async throws -> UIImage
}

public final class DefaultImageLoader: ImageLoader {
    private let cache: DataCache
    
    public init(cache: DataCache) {
        self.cache = cache
    }
    
    /// An image retrieval function
    /// - Parameter url: a given image URL
    /// - Returns: A UIImage
    public func retrieveImage(for url: URL) async throws -> UIImage {
        // Check if we hit the cache
        let cacheKey = url.absoluteString
        if let cachedData = await cache.data(for: cacheKey), let image = UIImage(data: cachedData) {
            Logger.networking.debug("Hit cache for image")
            return image
        }
        
        // If no cache hit, download from network
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        guard let image = UIImage(data: data) else {
            throw URLError(.cannotDecodeContentData)
        }
        
        // Save to cache
        await cache.set(data, forKey: cacheKey)
        Logger.networking.debug("Cache miss, fetched image from network")
        return image
    }
}
