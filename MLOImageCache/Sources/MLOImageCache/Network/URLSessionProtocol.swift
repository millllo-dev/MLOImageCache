//
//  URLSessionProtocol.swift
//  MLOImageCache
//
//  Created by 정종찬 on 2/23/26.
//

import Foundation

protocol URLSessionProtocol: Sendable {
    func data(from url: URL) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol {}
