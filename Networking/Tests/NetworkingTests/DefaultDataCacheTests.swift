import Testing
import Foundation
@testable import Networking

class DefaultDataCacheTests {
    var dataCache: DefaultDataCache!
    
    init() async throws {
        dataCache = DefaultDataCache(capacity: 3)
    }
    
    deinit {
        dataCache = nil
        
        // Clean up after ourselves to ensure test isolation.
        // Writing to disk ruins test isolation.
        var cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        cacheDirectory = cacheDirectory.appendingPathComponent(DefaultDataCache.diskCacheFilePath)
        if FileManager.default.fileExists(atPath: cacheDirectory.absoluteString) {
            try! FileManager.default.removeItem(at: cacheDirectory)
        }
    }
    
    @Test func canSetAndRetrieveData() async {
        let key = "testKey"
        let data = "testData".data(using: .utf8)!
        
        await dataCache.set(data, forKey: key)
        let retrievedData = await dataCache.data(for: key)
        #expect(retrievedData == data)
    }
    
    @Test func cannotRetrieveNonexistentKey() async {
        let data = await dataCache.data(for: "nonExistentKey")
        #expect(data == nil)
    }
    
    @Test func canEvictWhenOverCapacity() async {
        let keys = ["key1", "key2", "key3", "key4"]
        for (index, key) in keys.enumerated() {
            let data = "data\(index)".data(using: .utf8)!
            await dataCache.set(data, forKey: key)
        }
        
        let evictedData = await dataCache.data(for: "key1")
        #expect(evictedData == nil)
    }
    
    @Test func canMoveToHead() async {
        let keys = ["key1", "key2", "key3"]
        for (index, key) in keys.enumerated() {
            let data = "data\(index)".data(using: .utf8)!
            await dataCache.set(data, forKey: key)
        }
        
        // Access "key1" to move it to the head
        _ = await dataCache.data(for: "key1")
        
        _ = await dataCache.data(for: "key2")
        let head = await dataCache.getOrderedKeys().first!
        #expect(head == "key2")
    }
    
    @Test func keysAreInCorrectOrder() async {
        let keys = ["key1", "key2", "key3"]
        for (index, key) in keys.enumerated() {
            let data = "data\(index)".data(using: .utf8)!
            await dataCache.set(data, forKey: key)
        }
        
        let orderedKeys = await dataCache.getOrderedKeys()
        #expect(orderedKeys == keys.reversed())
    }
    
    @Test func emptyCacheReturnsEmpty() async {
        let orderedKeys = await dataCache.getOrderedKeys()
        #expect(orderedKeys.isEmpty)
        
        let data = await dataCache.data(for: "key1")
        #expect(data == nil)
    }
    
    @Test func existingKeyUpdatesData() async {
        let key = "existingKey"
        let oldData = "oldData".data(using: .utf8)!
        let newData = "newData".data(using: .utf8)!
        
        await dataCache.set(oldData, forKey: key)
        await dataCache.set(newData, forKey: key)
        
        let retrievedData = await dataCache.data(for: key)
        #expect(retrievedData == newData)
    }

    @Test func retrieveFromDisk() async {
        let keys = ["key1", "key2", "key3"]
        for (index, key) in keys.enumerated() {
            let data = "data\(index)".data(using: .utf8)!
            await dataCache.set(data, forKey: key)
        }
        var retrievedKey = await dataCache.getOrderedKeys()
        #expect(retrievedKey.first == "key3")
        await dataCache.saveDiskCacheToFile()
        
        dataCache = nil
        dataCache = DefaultDataCache()
        await dataCache.loadCacheFromDisk()
        retrievedKey = await dataCache.getOrderedKeys()
        #expect(retrievedKey.first == "key3")
    }
}
