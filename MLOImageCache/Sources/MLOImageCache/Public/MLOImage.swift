//
//  MLOImage.swift
//  MLOImageCache
//
//  Created by 정종찬 on 2/27/26.
//

import Foundation
import SwiftUI

enum ImageLoadingState {
    case idle
    case loading
    case success(PlatformImage)
    case failure(Error)
}

public struct MLOImage<Content: View, Placeholder: View>: View {
    private let url: String
    private let loader: ImageLoader
    private let content: (Image) -> Content
    private let placeholder: () -> Placeholder
    
    @State private var state: ImageLoadingState = .idle
    
    init(
        url: String,
        configuration: CacheConfiguration = .default,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.url = url
        self.loader = ImageLoader(configuration: configuration)
        self.content = content
        self.placeholder = placeholder
    }
    
    public var body: some View {
        Group {
            switch state {
            case .idle, .loading:
                placeholder()
            case .success(let platformImage):
                content(Image(uiImage: platformImage))
            case .failure:
                placeholder()
            }
        }
        .task {
            await loadImage()
        }
    }
    
    private func loadImage() async {
        state = .loading
        
        do {
            let image = try await loader.load(from: url)
            state = .success(image)
        } catch {
            state = .failure(error)
        }
    }
}
