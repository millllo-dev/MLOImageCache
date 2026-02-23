//
//  Configuration.swift
//  MLOImageCache
//
//  Created by 정종찬 on 2/23/26.
//

import Foundation

public struct CacheConfiguration: Sendable {
    public var memoryCountLimit: Int
    public var diskSizeLimit: Int
    public var diskExpiration: TimeInterval
    
    public static let `default` = CacheConfiguration(
        memoryCountLimit: 100,
        diskSizeLimit: 100 * 1024 * 1024,
        diskExpiration: 7 * 24 * 60 * 60
    )
}
