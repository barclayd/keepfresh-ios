import Foundation

public enum OSVersion {
    /// Check if running on iOS with minimum version.
    ///
    /// - Parameters:
    ///   - major: The major version number to check against
    ///   - minor: The minor version number to check against (defaults to 0)
    /// - Returns: `true` if the current iOS version is equal to or greater than the specified version
    ///
    /// Example:
    /// ```swift
    /// if OSVersion.iOS(26) {
    ///     // Use iOS 26+ features
    /// }
    ///
    /// if OSVersion.iOS(26, 2) {
    ///     // Use iOS 26.2+ features
    /// }
    /// ```
    public static func iOS(_ major: Int, _ minor: Int = 0) -> Bool {
        if #available(iOS 18.0, *) {
            let current = ProcessInfo.processInfo.operatingSystemVersion
            return (current.majorVersion, current.minorVersion) >= (major, minor)
        }
        return false
    }
}
