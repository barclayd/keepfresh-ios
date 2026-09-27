import CryptoKit
import Foundation
import UIKit

/// The extension cannot fetch images. The app prepares small local copies of its existing artwork.
public enum ShoppingActivityImages {
    public static let appGroup = "group.dev.danbarclay.keepfresh"

    public static func fileName(for name: String) -> String {
        SHA256.hash(data: Data(name.utf8)).map { String(format: "%02x", $0) }.joined() + ".png"
    }

    public static func url(for fileName: String) -> URL? {
        guard fileName == URL(fileURLWithPath: fileName).lastPathComponent else { return nil }
        return FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup)?
            .appendingPathComponent("ShoppingActivityImages", isDirectory: true)
            .appendingPathComponent(fileName)
    }

    public static func contains(_ name: String) -> Bool {
        guard let url = url(for: fileName(for: name)) else { return false }
        return FileManager.default.fileExists(atPath: url.path)
    }

    @MainActor
    public static func save(_ data: Data, named name: String) throws {
        guard let image = UIImage(data: data), image.size.width > 0, image.size.height > 0,
              let url = url(for: fileName(for: name)) else { return }
        let maximumDimension: CGFloat = 144
        let scale = min(maximumDimension / image.size.width, maximumDimension / image.size.height, 1)
        let size = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let thumbnail = UIGraphicsImageRenderer(size: size, format: format).image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
        guard let png = thumbnail.pngData() else { return }
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try png.write(to: url, options: [.atomic, .completeFileProtectionUntilFirstUserAuthentication])
    }
}
