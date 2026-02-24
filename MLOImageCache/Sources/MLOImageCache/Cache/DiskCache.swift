//
//  DiskCache.swift
//  MLOImageCache
//
//  Created by 정종찬 on 2/23/26.
//

import Foundation

final class DiskCache: DiskCacheProtocol {
    private let fileManager: FileManager
    private let directoryURL: URL
    private let configuration: CacheConfiguration
    
    init(
        fileManager: FileManager = FileManager.default,
        directoryURL: URL? = nil,
        configuration: CacheConfiguration = .default
    ) {
        self.fileManager = fileManager
        self.configuration = configuration
        
        if let directoryURL = directoryURL {
            self.directoryURL = directoryURL
        } else {
            let cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            self.directoryURL = cacheDirectory.appending(path: "image-cache", directoryHint: .isDirectory)
        }
        
        createDirectory()
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
    
    func cleanup() throws {
        let files = try cachedFiles()
        var totalSize: Int = 0
        var validFiles: [(url: URL, date: Date, size: Int)] = []
        
        let now = Date()
        for file in files {
            if now.timeIntervalSince(file.date) > configuration.diskExpiration {
                try? fileManager.removeItem(at: file.url)
            } else {
                validFiles.append(file)
                totalSize += file.size
            }
        }
        
        validFiles.sort { $0.date < $1.date }
        
        while totalSize > configuration.diskSizeLimit, let oldest = validFiles.first {
            try? fileManager.removeItem(at: oldest.url)
            totalSize -= oldest.size
            validFiles.removeFirst()
        }
    }
    
    func totalSize() throws -> Int {
        let files = try cachedFiles()
        return files.reduce(0) { $0 + $1.size }
    }
    
    private func createDirectory() {
        guard !fileManager.fileExists(atPath: directoryURL.path()) else { return }
        do {
            try fileManager.createDirectory(
                at: directoryURL,
                withIntermediateDirectories: true
            )
        } catch {
            NSLog("Create directory failed: \(error.localizedDescription)")
        }
    }
    
    private func fileURL(forKey key: String) -> URL {
        let fileName = key.sha256Hash()
        return directoryURL.appending(path: fileName, directoryHint: .notDirectory)
    }
    
    private func cachedFiles() throws -> [(url: URL, date: Date, size: Int)] {
        guard fileManager.fileExists(atPath: directoryURL.path()) else {
            return []
        }
        
        let resourceKeys: Set<URLResourceKey> = [
            .contentModificationDateKey,
            .fileSizeKey
        ]
        
        guard let fileURLs = try? fileManager.contentsOfDirectory(
            at: directoryURL,
            includingPropertiesForKeys: Array(resourceKeys)
        ) else {
            return []
        }
        
        return fileURLs.compactMap { url in
            guard let resources = try? url.resourceValues(
                forKeys: resourceKeys
            ),
                  let date = resources.contentModificationDate,
                  let size = resources.fileSize else {
                return nil
            }
            
            return (url: url, date: date, size: size)
        }
    }
}

