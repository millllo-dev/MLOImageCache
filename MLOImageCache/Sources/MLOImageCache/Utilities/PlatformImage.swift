//
//  PlatformImage.swift
//  MLOImageCache
//
//  Created by 정종찬 on 2/26/26.
//

#if canImport(UIKit)
import UIKit
public typealias PlatformImage = UIImage
#elseif canImport(AppKit)
public typealias PlatformImage = NSImage
#endif

