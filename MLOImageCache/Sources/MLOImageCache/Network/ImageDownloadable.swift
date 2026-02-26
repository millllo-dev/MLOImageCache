//
//  ImageDownloadable.swift
//  MLOImageCache
//
//  Created by 정종찬 on 2/23/26.
//

import Foundation

protocol ImageDownloadable: Sendable {
    func download(from url: String) async throws -> Data
}
