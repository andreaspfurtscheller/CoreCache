// MIT License
//
// Copyright (c) 2017 Oliver Borchert (borchero@in.tum.de)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import UIKit
import CorePromises
import CoreUtility

/// `CCImageCache` provides a three-level cache for images that are loaded from the web.
///
/// The class has been highly optimized to avoid blocking the user interface. As a result, there should not be any
/// delays, even if quickly scrolling through a table view full of images.
public final class CCImageCache {
    
    #if DEBUG
        var shouldPrintCacheSize = true
    #endif
    
    /// The default cache. The use of the default cache is enough for most applications as it provides a ubiquitous
    /// cache for the entire application.
    public private(set) static var `default`: CCImageCache = {
        return CCImageCache(id: nil)
    }()
    
    /// The image fetcher used to fetch images for the cache. The default is set to the `CCAlamofireFetcher`.
    /// The cache holds a strong reference to the fetcher. Consequently, it is advised not to implement the
    /// `CCImageFetching` protocol in a view controller.
    ///
    /// - Note: If multiple image fetchers are required (e.g. images have to be downloaded from Urls using Alamofire,
    ///         as well as from your Firebase Storage), currently, the only option is to declare another image cache.
    public var imageFetcher: CCImageFetching = CCAlamofireFetcher()
    
    public var imageUploader: CCImageUploading = CCAlamofireUploader()
    
    /// Returns a promise for the image at the given url. The fetching process is performed as follows:
    /// 1. An in-memory `NSCache` is asked for the image for the given url.
    /// 2. If the image could not be found in the in-memory cache, the persistent cache is asked for the image at
    ///    the given url. The image is subsequently loaded into the in-memory cache.
    /// 3. If the image could not be found in the persistent cache, a network request to retrieve the image is made.
    /// In case the image could not be loaded from the web, the promise is rejected. Otherwise, the downloaded image
    /// is cached in the persistent cache as well as the in-memory cache for subsequent usage.
    ///
    /// - Parameter url: The url of the image to retrieve.
    /// - Returns: A promise for the image at the given url.
    public func image(forUrl url: String, progressHandler: @escaping (Double) -> Void = { _ in return }) -> CPPromise<UIImage> {
        return CPPromise { resolve, reject in
            if let image = self.cache.object(forKey: url as NSString) {
                resolve(image)
                return
            } else {
                let backgroundContext = self.manager.createBackgroundChildContext()
                backgroundContext.async {
                    do {
                        if let imageObject = CCImage.object(forPrimaryKey: url, in: backgroundContext) {
                            let image = try UIImage(data: imageObject.data).unwrap()
                            self.cache.setObject(image, forKey: url as NSString)
                            resolve(image)
                            return
                        }
                    } catch let error {
                        reject(error)
                        return
                    }
                    self.imageFetcher.fetchImage(forUrl: url, progressHandler: progressHandler)
                        .then { image in
                            self.setImage(image, forUrl: url, on: backgroundContext)
                            backgroundContext.write()
                            resolve(image)
                        }.catch { error in
                            reject(error)
                    }
                }
            }
        }
    }
    
    public func uploadImage(_ image: UIImage, toUrl url: String, progressHandler: @escaping (Double) -> Void = { _ in return }) -> CPPromise<Void> {
        self.setImage(image, forUrl: url)
        return imageUploader.uploadImageData(compression.data(from: image), toUrl: url, progressHandler: progressHandler)
    }
    
    /// Inserts the image into the cache (both into the in-memory as well as the on-disk cache). If an image for the
    /// specified URL already exists, it is replaced with the new one.
    public func setImage(_ image: UIImage, forUrl url: String) {
        self.setImage(image, forUrl: url, on: manager.context)
        manager.write()
    }
    
    private func setImage(_ image: UIImage, forUrl url: String, on context: CCContext) {
        cache.setObject(image, forKey: url as NSString)
        if let oldObject = CCImage.object(forPrimaryKey: url, in: context) {
            self.size -= oldObject.size
        }
        let object = CCImage.createIfNeeded(forPrimaryKey: url, in: context)
            .update(.imageData(compression.data(from: image)))
        self.size += object.size
    }
    
    /// The capacity of the cache in bytes. The capacity is an upper bound for the cache's size.
    ///
    /// - Note: The default is set to 150MiB.
    public var capacity: Int {
        return 157286400
    }
    
    /// The compression level used for all images in the cache.
    ///
    /// - Note: The default is set to JPEG 50. If multiple compressions are needed, currently, the only option is to
    ///         declare another image cache.
    public var compression: CUImageCompression {
        return .jpeg(0.5)
    }
    
    /// The current size of the cache in bytes.
    public private(set) var size: Int {
        get {
            return UserDefaults.standard.integer(forKey: CCImageCache.filePath(forIdentifier: identifier) + "_size")
        } set {
            #if DEBUG
                if shouldPrintCacheSize {
                    print(">>> CCImageCache: Current cache size...")
                    print("    Bytes:     \(newValue)")
                    print("    Kilobytes: \(newValue / 1_000)")
                    print("    Megabytes: \(newValue / 1_000_000)")
                    print("<<< ... end of cache size.")
                }
            #endif
            UserDefaults.standard.set(newValue, forKey: CCImageCache.filePath(forIdentifier: identifier) + "_size")
            if newValue > capacity {
                thinCache()
            }
        }
    }
    
    private func thinCache() {
        let context = manager.createBackgroundChildContext()
        context.async {
            let results = CCImage.request()
                .sorted(by: .lastAccessed, .ascending)
                .with(fetchBatchSize: 10)
                .fetch(in: context)
            var currentSize = self.size
            let maximumSize = self.capacity / 4 * 3
            for result in results {
                if currentSize < maximumSize {
                    break
                }
                currentSize -= result.size
                result.delete(in: context)
            }
            self.size = currentSize
            context.write()
        }
    }
    
    private static func filePath(forIdentifier identifier: String?) -> String {
        switch identifier {
        case .none:
            return "cc_cache_default"
        case .some(let id):
            return "cc_cache_custom_\(id)"
        }
    }
    
    private let identifier: String?
    private lazy var cache = NSCache<NSString, UIImage>()
    private lazy var manager: CCManager = {
        CCImageDataManager(filePath: CCImageCache.filePath(forIdentifier: self.identifier))
    }()
    
    public convenience init(identifier: String) {
        self.init(id: identifier)
    }
    
    private init(id: String?) {
        self.identifier = id
    }
    
}

