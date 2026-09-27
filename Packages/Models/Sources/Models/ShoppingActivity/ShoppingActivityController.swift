import ActivityKit
import Foundation
import OSLog

@MainActor
public final class ShoppingActivityController {
    public static let shared = ShoppingActivityController()
    public static let shoppingURL = URL(string: "keepfresh://shopping")!
    public static let basketURL = URL(string: "keepfresh://shopping/basket")!
    private static let sessionKey = "shoppingLiveActivitySession"
    private let logger = Logger(subsystem: "dev.danbarclay.keepfresh", category: "ShoppingActivity")
    private var updateTask: Task<Void, Never>?

    public struct Session: Codable, Sendable {
        public let id: String
        public let startedAt: Date
        public var lastCollectedID: Int?

        public init(id: String, startedAt: Date, lastCollectedID: Int? = nil) {
            self.id = id
            self.startedAt = startedAt
            self.lastCollectedID = lastCollectedID
        }

        /// Identity-bound actions remain safe when an older view is still on screen.
        public mutating func changeBasket(sessionID: String, itemID: Int, undo: Bool, items: inout [ShoppingItem]) -> Bool {
            guard id == sessionID, itemID > 0, let index = items.firstIndex(where: { $0.id == itemID }) else { return false }
            if undo {
                guard lastCollectedID == itemID, items[index].status == .pendingCompletion else { return false }
                items[index].status = .created
                lastCollectedID = nil
            } else {
                guard items[index].status == .created else { return false }
                items[index].status = .pendingCompletion
                lastCollectedID = itemID
            }
            items[index].updatedAt = .now
            return true
        }
    }

    public var session: Session? {
        guard let data = UserDefaults.standard.data(forKey: Self.sessionKey) else { return nil }
        return try? JSONDecoder().decode(Session.self, from: data)
    }

    private func save(_ session: Session) {
        UserDefaults.standard.set(try? JSONEncoder().encode(session), forKey: Self.sessionKey)
    }

    /// Called synchronously by the user's Play action, while the app is foregrounded.
    public func start(startedAt: Date) {
        finish()
        let session = Session(id: UUID().uuidString, startedAt: startedAt)
        save(session)
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        let state = ShoppingActivityAttributes.ContentState(items: ShoppingCache.shared.items)
        guard state.totalCount > 0 else { return }
        do {
            _ = try Activity.request(
                attributes: ShoppingActivityAttributes(sessionID: session.id, startedAt: startedAt),
                content: ActivityContent(state: state, staleDate: startedAt.addingTimeInterval(8 * 60 * 60)),
                pushType: nil)
        } catch {
            logger.error("Unable to start shopping activity: \(error.localizedDescription)")
        }
    }

    /// Serial updates read the latest persisted basket, so rapid taps can't publish older snapshots.
    public func update() async {
        let previous = updateTask
        let task = Task { @MainActor in
            await previous?.value
            guard let session = self.session else { return }
            let state = ShoppingActivityAttributes.ContentState(
                items: ShoppingCache.shared.items, lastCollectedID: session.lastCollectedID)
            for activity in Activity<ShoppingActivityAttributes>.activities where activity.attributes.sessionID == session.id {
                await activity.update(ActivityContent(state: state, staleDate: session.startedAt.addingTimeInterval(8 * 60 * 60)))
            }
        }
        updateTask = task
        await task.value
    }

    /// Never restart an activity the user dismissed. Play is the only automatic start point.
    public func finish() {
        UserDefaults.standard.removeObject(forKey: Self.sessionKey)
        let activityIDs = Set(Activity<ShoppingActivityAttributes>.activities.map(\.id))
        let previous = updateTask
        updateTask = Task {
            await previous?.value
            for activity in Activity<ShoppingActivityAttributes>.activities where activityIDs.contains(activity.id) {
                await activity.end(activity.content, dismissalPolicy: .immediate)
            }
        }
    }

    public func changeBasket(sessionID: String, itemID: Int, undo: Bool) async throws {
        guard var session, session.id == sessionID else { return }
        let cache = ShoppingCache.shared
        var items = cache.load()
        guard session.changeBasket(sessionID: sessionID, itemID: itemID, undo: undo, items: &items) else { return }
        try cache.saveImmediately(items)
        save(session)
        cache.onExternalChange?(items)
        await update()
    }
}
