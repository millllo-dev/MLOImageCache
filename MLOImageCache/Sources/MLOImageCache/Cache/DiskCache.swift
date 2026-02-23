//
//  DiskCache.swift
//  MLOImageCache
//
//  Created by 정종찬 on 2/23/26.
//

import Foundation

final class DiskCache: ImageCacheProtocol {
    private let fileManager: FileManager
    private let directoryURL: URL
    
    init(
        fileManager: FileManager = FileManager.default,
        directoryURL: URL? = nil
    ) {
        self.fileManager = fileManager
        
        if let directoryURL = directoryURL {
            self.directoryURL = directoryURL
        } else {
            let cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            self.directoryURL = cacheDirectory.appending(path: "image-cache", directoryHint: .isDirectory)
        }
        
    }
    
    func loadImage(forKey key: String) throws -> Data? {
        let fileURL = fileURL(forKey: key)
        
        guard fileManager.fileExists(atPath: fileURL.path()) else {
            return nil
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            return data
        } catch {
            throw ImageCacheError.cacheReadFailed
        }
    }
    
    func saveImage(_ data: Data, forKey key: String) throws {
        let fileURL = fileURL(forKey: key)
        
        do {
            try data.write(to: fileURL, options: .atomic)
        } catch {
            throw ImageCacheError.cacheSaveFailed
        }
    }
    
    func remove(forKey key: String) throws {
        let fileURL = fileURL(forKey: key)
        
        guard fileManager.fileExists(atPath: fileURL.path()) else { return }
        
        do {
            try fileManager.removeItem(at: fileURL)
        } catch {
            throw ImageCacheError.cacheRemoveFailed
        }
    }
    
    func removeAll() throws {
        try fileManager.removeItem(atPath: directoryURL.path())
        createDirectory()
    }
    
    private func createDirectory() {
        guard !fileManager.fileExists(atPath: directoryURL.path()) else { return }
        try? fileManager.createDirectory(
            at: directoryURL,
            withIntermediateDirectories: true
        )
    }
    
    private func fileURL(forKey key: String) -> URL {
        let fileName = key.sha256Hash()
        return directoryURL.appending(path: fileName, directoryHint: .notDirectory)
    }
}

