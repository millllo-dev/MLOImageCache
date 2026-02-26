//
//  ImageDownloader.swift
//  MLOImageCache
//
//  Created by 정종찬 on 2/23/26.
//

import Foundation

final class ImageDownloader: ImageDownloadable {
    private let session: URLSessionProtocol
    
    init(session: URLSessionProtocol = URLSession.shared) {
        self.session = session
    }
    
    func download(from str: String) async throws -> Data {
        guard let url = URL(string: str) else {
            throw ImageCacheError.invalidURL
        }
        
        let data: Data
        let response: URLResponse
        
        do {
            (data, response) = try await session.data(from: url)
        } catch {
            throw ImageCacheError.networkFailure(underlying: error)
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ImageCacheError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw ImageCacheError.httpError(statusCode: httpResponse.statusCode)
        }
        
        return data
    }
}
