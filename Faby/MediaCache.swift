import UIKit

class ImageCache {
    static let shared = ImageCache()
    
    private let memoryCache = NSCache<NSString, UIImage>()
    private let fileManager = FileManager.default

    private init() {}

    private func cacheDirectory() -> URL {
        fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }

    private func filePath(forKey key: String) -> URL {
        let safeFileName = key.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? UUID().uuidString
        return cacheDirectory().appendingPathComponent(safeFileName)
    }

    func getImage(forKey key: String) -> UIImage? {
        // Check memory cache first
        if let image = memoryCache.object(forKey: key as NSString) {
            return image
        }

        // Check disk cache
        let path = filePath(forKey: key)
        if let image = UIImage(contentsOfFile: path.path) {
            // Store in memory for quicker access next time
            memoryCache.setObject(image, forKey: key as NSString)
            return image
        }

        return nil
    }

    func setImage(_ image: UIImage, forKey key: String) {
        // Memory cache
        memoryCache.setObject(image, forKey: key as NSString)

        // Disk cache
        let path = filePath(forKey: key)
        if let data = image.jpegData(compressionQuality: 0.9) {
            try? data.write(to: path)
        }
    }

    func removeImage(forKey key: String) {
        memoryCache.removeObject(forKey: key as NSString)
        let path = filePath(forKey: key)
        try? fileManager.removeItem(at: path)
    }

    func clearDiskCache() {
        let cacheDir = cacheDirectory()
        if let files = try? fileManager.contentsOfDirectory(at: cacheDir, includingPropertiesForKeys: nil) {
            for file in files {
                try? fileManager.removeItem(at: file)
            }
        }
    }
}

class VideoCache {
    static let shared = VideoCache()

    private let memoryCache = NSCache<NSString, NSURL>()
    private let fileManager = FileManager.default

    private init() {}

    private func cacheDirectory() -> URL {
        fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }

    private func filePath(forKey key: String) -> URL {
        let safeFileName = key.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? UUID().uuidString
        return cacheDirectory().appendingPathComponent(safeFileName)
    }

    func getVideoURL(forKey key: String) -> URL? {
        // Check memory cache first
        if let videoURL = memoryCache.object(forKey: key as NSString) {
            return videoURL as URL
        }

        // Check disk cache
        let path = filePath(forKey: key)
        let videoURL = NSURL(fileURLWithPath: path.path)
        if fileManager.fileExists(atPath: path.path) {
            memoryCache.setObject(videoURL, forKey: key as NSString)
            return videoURL as URL
        }

        return nil
    }

    func setVideoURL(_ url: URL, forKey key: String) {
        // Memory cache
        memoryCache.setObject(url as NSURL, forKey: key as NSString)

        // Disk cache
        let path = filePath(forKey: key)
        do {
            let data = try Data(contentsOf: url)
            try data.write(to: path)
        } catch {
            print("❌ Error saving video to disk cache: \(error.localizedDescription)")
        }
    }

    func removeVideo(forKey key: String) {
        memoryCache.removeObject(forKey: key as NSString)
        let path = filePath(forKey: key)
        try? fileManager.removeItem(at: path)
    }

    func clearDiskCache() {
        let cacheDir = cacheDirectory()
        if let files = try? fileManager.contentsOfDirectory(at: cacheDir, includingPropertiesForKeys: nil) {
            for file in files {
                try? fileManager.removeItem(at: file)
            }
        }
    }
}
