//
//  ImageCacheError.swift
//  MLOImageCache
//
//  Created by 정종찬 on 2/23/26.
//

import Foundation

public enum ImageCacheError: Error {
    // Network
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case networkFailure(underlying: Error)
    
    // Cache
    case cacheSaveFailed
    case cacheReadFailed
    case cacheRemoveFailed
    
    // Decode
    case decodingFailed
}
