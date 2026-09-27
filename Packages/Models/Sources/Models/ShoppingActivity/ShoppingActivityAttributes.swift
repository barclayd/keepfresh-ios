import ActivityKit
import Foundation

public struct ShoppingActivityAttributes: ActivityAttributes, Sendable {
    public struct Item: Codable, Hashable, Sendable, Identifiable {
        public var id: Int
        public var title: String
        public var detail: String
        // Optional so activities created before the visual refresh still decode.
        public var brand: String?
        public var storageLocation: StorageLocation?
        public var imageName: String?

        public init(_ item: ShoppingItem) {
            id = item.id
            let customTitle = item.title?.trimmingCharacters(in: .whitespacesAndNewlines)
            title = String((customTitle?.isEmpty == false ? customTitle! : item.product?.name ?? "Shopping item").prefix(120))
            brand = item.product?.brand.name.activityDetail(limit: 40)
            detail = [brand, item.product?.amountUnitFormatted?.activityDetail(limit: 28)]
                .compactMap(\.self).joined(separator: " • ")
            storageLocation = item.storageLocation
            imageName = item.product?.category.icon.mapToActivityImageName
        }
    }

    public struct ContentState: Codable, Hashable, Sendable {
        public var current: Item?
        public var next: Item?
        public var lastCollected: Item?
        public var collectedCount: Int
        public var totalCount: Int

        public var isComplete: Bool { totalCount > 0 && collectedCount == totalCount }
        public var progress: Double { totalCount > 0 ? Double(collectedCount) / Double(totalCount) : 0 }
        public var remainingCount: Int { max(0, totalCount - collectedCount) }

        public init(items: [ShoppingItem], lastCollectedID: Int? = nil) {
            // Match the app's order: pantry, fridge, freezer, then other items.
            let eligible = items
                .filter {
                    $0
                        .status != .completed &&
                        ($0.product != nil || $0.title?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false)
                }
            let remaining = StorageLocation.allCases.flatMap { location in
                eligible.filter { $0.storageLocation == location && $0.status == .created }
            } + eligible.filter { $0.storageLocation == nil && $0.status == .created }
            current = remaining.first.map(Item.init)
            next = remaining.dropFirst().first.map(Item.init)
            lastCollected = eligible.first { $0.id == lastCollectedID && $0.status == .pendingCompletion }.map(Item.init)
            collectedCount = eligible.filter { $0.status == .pendingCompletion }.count
            totalCount = eligible.count
        }
    }

    public var sessionID: String
    public var startedAt: Date

    public init(sessionID: String, startedAt: Date) {
        self.sessionID = sessionID
        self.startedAt = startedAt
    }
}

private extension String {
    func activityDetail(limit: Int) -> String? {
        let value = trimmingCharacters(in: .whitespacesAndNewlines)
        return value.isEmpty ? nil : String(value.prefix(limit))
    }

    var mapToActivityImageName: String? {
        let name = ShoppingActivityImages.fileName(for: self)
        guard let url = ShoppingActivityImages.url(for: name), FileManager.default.fileExists(atPath: url.path) else { return nil }
        return name
    }
}
