import Foundation

public final class ShaderCacheManager: @unchecked Sendable {
    public static let shared = ShaderCacheManager()
    private let fileManager = FileManager.default

    private init() {}

    /// Calculates total shader cache size for a bottle prefix and macOS Metal cache.
    public func calculateCacheSize(prefixURL: URL) -> Int64 {
        var total: Int64 = 0

        // Check dxvk caches in prefix
        if let enumerator = fileManager.enumerator(at: prefixURL, includingPropertiesForKeys: [.fileSizeKey]) {
            for case let fileURL as URL in enumerator {
                if fileURL.pathExtension == "dxvk-cache" || fileURL.lastPathComponent.contains(".metallib") {
                    let size = (try? fileURL.resourceValues(forKeys: [.fileSizeKey]))?.fileSize ?? 0
                    total += Int64(size)
                }
            }
        }

        // Metal cache
        let metalCache = fileManager.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/Caches/com.apple.metal", isDirectory: true)
        if let enumerator = fileManager.enumerator(at: metalCache, includingPropertiesForKeys: [.fileSizeKey]) {
            for case let fileURL as URL in enumerator {
                let size = (try? fileURL.resourceValues(forKeys: [.fileSizeKey]))?.fileSize ?? 0
                total += Int64(size)
            }
        }

        return total
    }

    /// Clears shader caches for a bottle and Metal to resolve stuttering.
    public func clearShaderCaches(prefixURL: URL) {
        if let enumerator = fileManager.enumerator(at: prefixURL, includingPropertiesForKeys: nil) {
            for case let fileURL as URL in enumerator {
                if fileURL.pathExtension == "dxvk-cache" || fileURL.lastPathComponent.hasSuffix(".metallib") {
                    try? fileManager.removeItem(at: fileURL)
                }
            }
        }

        let metalCache = fileManager.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/Caches/com.apple.metal", isDirectory: true)
        if fileManager.fileExists(atPath: metalCache.path) {
            try? fileManager.removeItem(at: metalCache)
        }
    }
}
