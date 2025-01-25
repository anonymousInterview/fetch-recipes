//
//  DataCache.swift
//  Networking
//
//

import Foundation
import SwiftUI
import OSLog

/// An Least Recently Used (LRU) data cache that supports both in-memory and on disk retrievals
public actor DataCache {
    /// How many items are currently in our cache
    private var count: Int = 0
    
    /// The capacity of our cache
    private let capacity: Int
    
    /// Pointers to help us insert new items and purge old items
    private var head: Node?
    private var tail: Node?
    
    /// Our key:value store of nodes where key is
    private var cache: [String: Node] = [:]

    private let diskCacheFilePath: URL?
    
    public init(capacity: Int = 200) {
        self.capacity = capacity
        // Determine file path for the disk cache
        if let cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first {
            diskCacheFilePath = cacheDirectory.appendingPathComponent("dataCache.json")
        } else {
            // If we can't find a path to write to, we won't write to disk
            diskCacheFilePath = nil
        }
        
        // Load disk cache from file
        guard let diskCacheFilePath else { return }
        do {
            let data = try Data(contentsOf: diskCacheFilePath)
            let decodedCache = try JSONDecoder().decode([String: Data].self, from: data)
            Task {
                for (key, value) in decodedCache {
                    await setData(value, forKey: key)
                }
            }
        } catch {
            Logger.networking.debug("Failed to load cache from disk: \(error.localizedDescription)")
        }
    }
    
    public func data(for key: String) -> Data? {
        if let node = cache[key] {
            moveToHead(node)
            return node.value
        } else {
            return nil
        }
    }
    
    public func setData(_ data: Data, forKey key: String) {
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
            cache.removeValue(forKey: tail!.key)
            tail = tail?.previous
            tail?.next = nil
            count -= 1
        }
        
        // After every write, save to disk
        // TODO: This is inefficient, we should batch writes on a given cadence.
        saveDiskCacheToFile()
    }
    
    /// Updates the pointres of an existing node based off its current position
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
    private func saveDiskCacheToFile() {
        if let diskCacheFilePath {
            do {
                let serializedCache = cache.mapValues { $0.value }
                let encodedData = try JSONEncoder().encode(serializedCache)
                try encodedData.write(to: diskCacheFilePath, options: .atomic)
            } catch {
                Logger.networking.error("\(error.localizedDescription)")
            }
        }
    }
    
    /// A node for our DataCache
    class Node: Codable {
        fileprivate var key: String
        fileprivate var value: Data
        fileprivate var previous: Node?
        fileprivate var next: Node?
        
        /// An initializer for Node
        /// - Parameters:
        ///   - key: A string identifier
        ///   - value: The associated data for a given key
        init(key: String, value: Data) {
            self.key = key
            self.value = value
        }
    }
}


