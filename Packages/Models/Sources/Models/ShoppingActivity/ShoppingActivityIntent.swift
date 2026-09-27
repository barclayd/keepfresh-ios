import AppIntents

public struct ShoppingActivityIntents: AppIntentsPackage {}

public struct CollectShoppingItemIntent: LiveActivityIntent {
    public static let title: LocalizedStringResource = "Put item in basket"
    public static let description = IntentDescription("Mark a shopping item as in your basket, or undo the most recent pickup.")
    public static let openAppWhenRun = false
    public static let isDiscoverable = false

    @Parameter(title: "Shopping session") public var sessionID: String
    @Parameter(title: "Item") public var itemID: Int
    @Parameter(title: "Undo") public var undo: Bool

    public init() {}

    public init(sessionID: String, itemID: Int, undo: Bool = false) {
        self.sessionID = sessionID
        self.itemID = itemID
        self.undo = undo
    }

    @MainActor
    public func perform() async throws -> some IntentResult {
        try await ShoppingActivityController.shared.changeBasket(sessionID: sessionID, itemID: itemID, undo: undo)
        return .result()
    }
}
