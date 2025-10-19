import Authentication
import DesignSystem
import Environment
import Models
import Router
import SwiftData
import SwiftUI

@main
struct KeepFreshApp: App {
    @State var router: Router = .init()
    @State var inventory: Inventory = .init()

    init() {
        FontRegistration.registerFonts()
    }

    var body: some Scene {
        WindowGroup {
            AppTabRootView()
                .environment(router)
                .environment(inventory)
                .modelContainer(for: [RecentSearch.self, GenmojiCache.self])
                .task {
                    try? await Authentication.shared.signInAnonymously()

                    await inventory.fetchItems()

                    Task.detached {
                        await SuggestionsCache.shared.load()
                    }
                }
                .preferredColorScheme(.light)
        }
    }
}
