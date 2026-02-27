//
//  ImageLoader.swift
//  MLOImageCache
//
//  Created by 정종찬 on 2/23/26.
//

import Foundation

public final class ImageLoader: Sendable {
    private let pipeline: ImagePipeline
    
    public init(configuration: CacheConfiguration = .default) {
        let memoryCache = MemoryCache(configuration: configuration)
        let diskCache = DiskCache(configuration: configuration)
        let downloader = ImageDownloader()
        
        self.pipeline = ImagePipeline(
            memoryCache: memoryCache,
            diskCache: diskCache,
            downloader: downloader,
            configuration: configuration
        )
    }
    
    public func load(from url: String) async throws -> PlatformImage {
        try await pipeline.image(for: url)
    }
}
