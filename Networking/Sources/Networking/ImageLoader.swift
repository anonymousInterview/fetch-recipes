//
//  ImageLoader.swift
//  Networking
//
//  Created by Ulises Giacoman on 1/23/25.
//

import Foundation
import UIKit
import OSLog

public actor DataCache {
    private var inMemoryCache: NSCache<NSString, NSData>
    private var diskCache: [String: Data]
    private let diskCacheFilePath: URL?
    
    
    /// A safe access image cache
    /// - Parameters:
    ///   - countLimit: Limit to how many items can be stored (default is 100)
    ///   - totalCostLimit: Limit to total size in bytes (default is 30MB)
    public init(countLimit: Int = 100, totalCostLimit: Int = 30_000_000) {
        inMemoryCache = NSCache<NSString, NSData>()
        inMemoryCache.countLimit = countLimit
        inMemoryCache.totalCostLimit = totalCostLimit
        
        // Determine file path for the disk cache
        if let cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first {
            diskCacheFilePath = cacheDirectory.appendingPathComponent("ImageCache.json")
        } else {
            // If we can't find a path to write to, we won't write to disk
            diskCacheFilePath = nil
        }
        
        // Load disk cache from file
        if let diskCacheFilePath,
           let data = try? Data(contentsOf: diskCacheFilePath),
           let decodedCache = try? JSONDecoder().decode([String: Data].self, from: data)
        {
            diskCache = decodedCache
        } else {
            diskCache = [:]
        }
    }
    
    public func data(forKey key: String) -> Data? {
        // Check memory cache first
        if let cachedData = inMemoryCache.object(forKey: key as NSString) as Data? {
            return cachedData
        }
        // Check disk cache
        return diskCache[key]
    }
    
    public func setData(_ data: Data, forKey key: String) {
        inMemoryCache.setObject(data as NSData, forKey: key as NSString, cost: data.count)
    }
    
    /// Takes our in-memory cache and saves to disk to persist across app launches
    public func saveDiskCacheToFile() {
        if
            let diskCacheFilePath,
            let encodedData = try? JSONEncoder().encode(diskCache)
        {
            try? encodedData.write(to: diskCacheFilePath, options: .atomic)
        }
    }
}

// TODO: Double check safety
public final class ImageLoader: Sendable {
    private let cache: DataCache
    
    // TODO: Make a protocol
    public init(cache: DataCache = DataCache()) {
        self.cache = cache
    }
    
    public func retrieveImage(for url: URL) async throws -> UIImage {
        let cacheKey = url.absoluteString
        
        // Check if we hit the cache
        if let cachedData = await cache.data(forKey: cacheKey), let image = UIImage(data: cachedData) {
            Logger().debug("Hit cache for image")
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
        await cache.setData(data, forKey: cacheKey)
        Logger.tracking.debug("Cache miss, fetched image from network")
        return image
    }
}
