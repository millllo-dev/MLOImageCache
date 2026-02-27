//
//  ImageCacheWrapper.swift
//  MLOImageCache
//
//  Created by 정종찬 on 2/27/26.
//

import Foundation
import UIKit

public struct ImageCacheWrapper<Base> {
    public let base: Base
    public init(_ base: Base) {
        self.base = base
    }
}

public protocol ImageCacheCompatible {
    associatedtype CompatibleType
    var mlo: ImageCacheWrapper<CompatibleType> { get }
}

extension ImageCacheCompatible {
    public var mlo: ImageCacheWrapper<Self> {
        ImageCacheWrapper(self)
    }
}

extension ImageCacheWrapper where Base: UIImageView {
    @discardableResult
    public func setImage(
        with url: String,
        placeholder: PlatformImage? = nil,Add
        configuration: CacheConfiguration = .default
    ) -> Task<PlatformImage?, Never> {
        let imageView = base
        
        return Task { @MainActor in
            if let placeholder = placeholder {
                imageView.image = placeholder
            }
            
            let loader = ImageLoader(configuration: configuration)
            
            do {
                let image = try await loader.load(from: url)
                imageView.image = image
                return image
            } catch {
                return nil
            }
        }
    }
}
