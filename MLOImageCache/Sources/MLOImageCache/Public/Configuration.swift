//
//  Configuration.swift
//  MLOImageCache
//
//  Created by 정종찬 on 2/23/26.
//

import Foundation

public struct CacheConfiguration: Sendable {
    public let memoryCountLimit: Int
    public let memorySizeLimit: Int
    
    public let diskSizeLimit: Int
    public let diskExpiration: TimeInterval         // file expiration time
    public let diskCleanupInterval: TimeInterval    // cleanup time
    
    public static let `default` = CacheConfiguration(
        memoryCountLimit: 100,
        memorySizeLimit: 50 * 1024 * 1024,          // 50MB
        diskSizeLimit: 100 * 1024 * 1024,           // 100MB
        diskExpiration: 7 * 24 * 60 * 60,           // 7 days
        diskCleanupInterval: 60 * 60                // 1 hour
    )
    
    private static func deviceAvailableStorage() -> Int64 {
        let homeURL = URL(filePath: NSHomeDirectory())
        
        guard let values = try? homeURL.resourceValues(
            forKeys: [.volumeAvailableCapacityForImportantUsageKey]
        ),
        let available = values.volumeAvailableCapacityForImportantUsage else {
            return 100 * 1024 * 1024
        }
        
        return available
    }
}
