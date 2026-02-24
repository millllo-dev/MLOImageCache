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
    
    init(
        memoryCache: MemoryCacheProtocol,
        diskCache: DiskCacheProtocol,
        downloader: ImageDownloadable
    ) {
        self.memoryCache = memoryCache
        self.diskCache = diskCache
        self.downloader = downloader
    }
}
