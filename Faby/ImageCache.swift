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
