//
//  DataCache.swift
//  Networking
//
//

import Foundation
import SwiftUI
import OSLog

public protocol DataCache: Actor {
    func data(for key: String) -> Data?
    func set(_ data: Data, forKey key: String)
}

/// An Least Recently Used (LRU) data cache that supports both in-memory and on disk retrievals
public actor DefaultDataCache: DataCache {
    /// How many items are currently in our cache
    private var count: Int = 0
    
    /// The capacity of our cache
    private let capacity: Int
    
    /// Pointers to help us insert new items and purge old items
    private var head: Node?
    private var tail: Node?
    
    /// Our key:value store of nodes where key is
    private var cache: [String: Node] = [:]
    
    private let diskCacheFileURL: URL?
    static let diskCacheFilePath = "dataCache"
    
    lazy var writeToDiskDebouncer: Debouncer = Debouncer(duration: .seconds(2)) {
        self.saveDiskCacheToFile()
    }
    
    public init(capacity: Int = 200) {
        self.capacity = capacity
        // Determine file path for the disk cache
        if let cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first {
            diskCacheFileURL = cacheDirectory.appendingPathComponent(Self.diskCacheFilePath)
        } else {
            // If we can't find a path to write to, we won't write to disk
            diskCacheFileURL = nil
        }
        
        Task {
            await loadCacheFromDisk()
        }
    }
    
    /// Retrieve a value
    /// - Parameter key: The identifier for the data
    /// - Returns: Data if it exists in the cache
    public func data(for key: String) -> Data? {
        if let node = cache[key] {
            moveToHead(node)
            writeToDiskDebouncer.emit()
            return node.value
        } else {
            return nil
        }
    }
    
    /// Cache a value
    /// - Parameters:
    ///   - data: The data to be cached
    ///   - key: The data's identifier
    public func set(_ data: Data, forKey key: String) {
        // If we get a hit, move current node to head
        if let node = cache[key] {
            node.value = data
            moveToHead(node)
        } else {
            // if no cache hit, store in cache and make node head
            let node = Node(key: key, value: data)
            node.next = head
            head?.previous = node
            head = node
            cache[key] = node
            count += 1
            
            // If cache is empty and this is the first insertion,
            // give tail a value
            if tail == nil {
                tail = head
            }
        }
        
        // If we have hit capacity, purge last node
        if count > capacity {
            if let tail {
                cache.removeValue(forKey: tail.key)
            }
            
            tail = tail?.previous
            tail?.next = nil
            count -= 1
        }
        // Update disk with new model
        writeToDiskDebouncer.emit()
    }
    
    /// Updates the pointers of an existing node based off its current position
    func moveToHead(_ node: Node) {
        // If the current node is already at the head: noop
        // Otherwise, update pointers to make current node head
        if node === head {
            return
        } else {
            node.previous?.next = node.next
            node.next?.previous = node.previous
            node.next = head
            head?.previous = node
            head = node
        }
        
        // If the current node is the tail, make the previous node tail
        if node === tail {
            tail = tail?.previous
            tail?.next = nil
        }
    }
    
    /// Takes our in-memory cache and saves to disk to persist across app launches
    func saveDiskCacheToFile() {
        if let diskCacheFileURL {
            do {
                let serializedCache = cache.mapValues { $0.value }
                let orderedKeys = getOrderedKeys()
                let diskCache = DiskCache(cache: serializedCache, orderedKeys: orderedKeys)
                let encodedData = try JSONEncoder().encode(diskCache)
                try encodedData.write(to: diskCacheFileURL, options: .atomic)
                Logger.networking.debug("Wrote to disk.")
            } catch {
                Logger.networking.error("\(error.localizedDescription)")
            }
        }
    }
    
    /// Retrieve cache from disk and load values into memory
    func loadCacheFromDisk() {
        guard let diskCacheFileURL else { return }
        do {
            let data = try Data(contentsOf: diskCacheFileURL)
            let decodedCache = try JSONDecoder().decode(DiskCache.self, from: data)
            for key in decodedCache.orderedKeys.reversed() {
                if let data = decodedCache.cache[key] {
                    set(data, forKey: key)
                }
            }
        } catch {
            Logger.networking.debug("Failed to load cache from disk: \(error.localizedDescription)")
        }
    }
    
    /// Iterates through our doubly linked list to return the order of our keys
    /// - Returns: A string array of ordered keys
    func getOrderedKeys() -> [String] {
        var keys: [String] = []
        var current = head
        while let node = current {
            keys.append(node.key)
            current = node.next
        }
        return keys
    }
    
    /// A node for our DataCache
    public class Node {
        fileprivate var key: String
        fileprivate var value: Data
        fileprivate var previous: Node?
        fileprivate var next: Node?
        
        /// An initializer for Node
        /// - Parameters:
        ///   - key: A string identifier
        ///   - value: The associated data for a given key
        public init(key: String, value: Data) {
            self.key = key
            self.value = value
        }
    }
    
    /// A Codable representation of our DataCache
    /// This is used for writing to disk.
    private struct DiskCache: Codable {
        let cache: [String: Data]
        let orderedKeys: [String]
    }
}
