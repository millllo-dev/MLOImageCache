//
//  MemoryCache.swift
//  MLOImageCache
//
//  Created by 정종찬 on 2/23/26.
//

import Foundation

final class MemoryCache: MemoryCacheProtocol {
    private let cache: NSCache<NSString, PlatformImage>
    
    init(configuration: CacheConfiguration = .default) {
        self.cache = NSCache<NSString, PlatformImage>()
        self.cache.countLimit = configuration.memoryCountLimit
        self.cache.totalCostLimit = configuration.memorySizeLimit
    }
    
    func loadImage(forKey key: String) -> PlatformImage? {
       return cache.object(forKey: key as NSString)
    }
    
    func saveImage(_ image: PlatformImage, forKey key: String) {
        let cost = imageCost(image)
        cache.setObject(image, forKey: key as NSString, cost: cost)
    }
    
    func remove(forKey key: String) {
        cache.removeObject(forKey: key as NSString)
    }
    
    func removeAll() {
        cache.removeAllObjects()
    }
    
    private func imageCost(_ image: PlatformImage) -> Int {
        guard let cgImage = image.cgImage else { return 0 }
        return cgImage.bytesPerRow * cgImage.height
    }
}
