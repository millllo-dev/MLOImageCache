//
//  ImagePipeline.swift
//  MLOImageCache
//
//  Created by 정종찬 on 2/23/26.
//

import Foundation

final actor ImagePipeline {
    private let memoryCache: MemoryCacheProtocol
    private let diskCache: DiskCacheProtocol
    private let downloader: ImageDownloadable
    private let configuration: CacheConfiguration
    
    private var inFlightTask: [String: Task<Data, Error>] = [:]
    private var lastCleanupDate: Date = .distantPast
    
    init(
        memoryCache: MemoryCacheProtocol,
        diskCache: DiskCacheProtocol,
        downloader: ImageDownloadable,
        configuration: CacheConfiguration = .default
    ) {
        self.memoryCache = memoryCache
        self.diskCache = diskCache
        self.downloader = downloader
        self.configuration = configuration
    }
    
    func image(for url: String) async throws -> PlatformImage {
        let key = url.sha256Hash()
        
        if let image = memoryCache.loadImage(forKey: key) {
            return image
        }
        
        if let data = try diskCache.loadImage(forKey: key) {
            guard let image = PlatformImage(data: data) else {
                throw ImageCacheError.decodingFailed
            }
            memoryCache.saveImage(image, forKey: key)
            return image
        }
        
        let data = try await downloadWithDeduplication(url: url)
        
        guard let image = PlatformImage(data: data) else {
            throw ImageCacheError.decodingFailed
        }
        
        cleanupIfNeeded()
        memoryCache.saveImage(image, forKey: key)
        try diskCache.saveImage(data, forKey: key)
        
        return image
    }
    
    // MARK: - download deduplication
    private func downloadWithDeduplication(url: String) async throws -> Data {
        if let existingTask = inFlightTask[url] {
            return try await existingTask.value
        }
        
        let task = Task {
            try await downloader.download(from: url)
        }
        
        inFlightTask[url] = task
        
        do {
            let data = try await task.value
            inFlightTask[url] = nil
            return data
        } catch {
            inFlightTask[url] = nil
            throw error
        }
    }
    
    private func cleanupIfNeeded() {
        let now = Date()
        guard now.timeIntervalSince(lastCleanupDate) > configuration.diskCleanupInterval else {return}
        
        lastCleanupDate = now
        try? diskCache.cleanup()
    }
}
