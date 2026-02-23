//
//  String+Extension.swift
//  MLOImageCache
//
//  Created by 정종찬 on 2/23/26.
//

import Foundation
import CryptoKit

extension String {
    func sha256Hash() -> String {
        let data = Data(self.utf8)
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
}
