//
//  ImageCacheProtocol.swift
//  MLOImageCache
//
//  Created by 정종찬 on 2/23/26.
//

import Foundation

// MARK: - ImageCacheProtocol
protocol ImageCacheProtocol {
    func loadImage(forKey key: String) throws -> Data?
    func saveImage(_ data: Data, forKey key: String) throws
    func remove(forKey key: String) throws
    func removeAll() throws
}
