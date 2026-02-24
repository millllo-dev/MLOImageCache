//
//  MemoryCache.swift
//  MLOImageCache
//
//  Created by 정종찬 on 2/23/26.
//

import Foundation

final class MemoryCache: MemoryCacheProtocol {
    private let cache: NSCache<NSString, NSData>
    
    init(configuration: CacheConfiguration = .default) {
        self.cache = NSCache<NSString, NSData>()
        self.cache.countLimit = configuration.memoryCountLimit
        self.cache.totalCostLimit = configuration.memorySizeLimit
    }
    
    func loadImage(forKey key: String) -> Data? {
        guard let data = cache.object(forKey: NSString(string: key)) else {
            NSLog("Not found in memory cache: \(key)")
            return nil
        }
        
        return Data(data)
    }
    
    func saveImage(_ data: Data, forKey key: String) {
        let nsData = data as NSData
        cache.setObject(data as NSData, forKey: NSString(string: key), cost: nsData.length)
    }
    
    func remove(forKey key: String) {
        cache.removeObject(forKey: key as NSString)
    }
    
    func removeAll() {
        cache.removeAllObjects()
    }
}
