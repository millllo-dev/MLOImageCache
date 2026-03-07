# MLOImageCache

A Swift Concurrency-based image caching library for iOS. Provides a two-tier cache (memory + disk), automatic download deduplication, and a Kingfisher-style API.

## Features

- **Actor-based concurrency safety** — All cache operations run inside Swift actors, eliminating data races without manual locking
- **Two-tier cache** — Memory cache (NSCache-backed) is checked first; disk cache serves as a fallback and persistence layer
- **Download deduplication** — Concurrent requests for the same URL share a single in-flight `Task`; no duplicate network calls
- **LRU & expiration policy** — Memory cache evicts by count/size; disk cache removes expired files and enforces a total size limit
- **Kingfisher-style API** — `.mlo.setImage(with:)` extension on `UIImageView`
- **SwiftUI support** — `MLOImage` view with content/placeholder builder pattern

## Architecture

```
Public API
  ├── UIImageView.mlo.setImage(with:)   (ImageCacheWrapper)
  ├── MLOImage (SwiftUI View)
  └── ImageLoader.shared

          ↓

Pipeline Layer
  └── ImagePipeline (actor)
        ├── Memory hit  → return immediately
        ├── Disk hit    → promote to memory, return
        └── Network miss → deduplicate → download → save to both caches

          ↓

Cache Layer              Network Layer
  ├── MemoryCache        └── ImageDownloader
  └── DiskCache
```

## Installation

### Swift Package Manager

Add the package to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/your-username/MLOImageCache.git", from: "1.0.0")
]
```

Or in Xcode: **File → Add Package Dependencies** and paste the repository URL.

## Usage

### UIKit

```swift
import MLOImageCache

// Basic usage
imageView.mlo.setImage(with: "https://example.com/image.jpg")

// With placeholder
imageView.mlo.setImage(
    with: "https://example.com/image.jpg",
    placeholder: UIImage(named: "placeholder")
)
```

### SwiftUI

```swift
import MLOImageCache

MLOImage(url: "https://example.com/image.jpg") { image in
    image
        .resizable()
        .aspectRatio(contentMode: .fill)
} placeholder: {
    ProgressView()
}
```

### Direct usage

```swift
import MLOImageCache

let image = try await ImageLoader.shared.load(from: "https://example.com/image.jpg")
```

## Configuration

Customize the cache by creating your own `CacheConfiguration` and initializing a dedicated `ImageLoader`:

```swift
let config = CacheConfiguration(
    memoryCountLimit: 200,
    memorySizeLimit: 100 * 1024 * 1024,   // 100 MB
    diskSizeLimit: 500 * 1024 * 1024,      // 500 MB
    diskExpiration: 14 * 24 * 60 * 60,     // 14 days
    diskCleanupInterval: 30 * 60           // 30 minutes
)

let loader = ImageLoader(configuration: config)
let image = try await loader.load(from: url)
```

| Parameter | Default | Description |
|-----------|---------|-------------|
| `memoryCountLimit` | 100 | Max number of images in memory cache |
| `memorySizeLimit` | 50 MB | Max total byte size of memory cache |
| `diskSizeLimit` | 100 MB | Max total byte size of disk cache |
| `diskExpiration` | 7 days | Time before a cached file expires |
| `diskCleanupInterval` | 1 hour | How often to run the disk cleanup sweep |

## Tech Stack

- **Swift 6.2** with strict concurrency (`Sendable`, `actor`)
- **Swift Concurrency** — `async/await`, `Task`, structured concurrency
- **CryptoKit** — SHA-256 hashing for cache keys
- **SwiftUI** — `MLOImage` view
- **UIKit** — `UIImageView` extension
- Minimum deployment target: **iOS 16**
