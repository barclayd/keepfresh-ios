import Authentication
import DesignSystem
import Environment
import Models
import Router
import SwiftData
import SwiftUI

public class FontRegistration {
    public static func registerFonts() {
        let bundle = Bundle(for: FontRegistration.self)

        guard let bundleURL = bundle.url(forResource: "Shrikhand-Regular", withExtension: "ttf") else {
            return
        }

        CTFontManagerRegisterFontsForURL(bundleURL as CFURL, .process, nil)
    }
}

@main
struct KeepFreshApp: App {
    @State var router: Router = .init()
    @State var inventory: Inventory = .init()

    let authClient = AuthenticationClient(
        supabaseURL: URL(string: "https://ajvsqwbowwilmcqyynye.supabase.co")!,
        supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFqdnNxd2Jvd3dpbG1jcXl5bnllIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTcxNTIxMjAsImV4cCI6MjA3MjcyODEyMH0.usZ16otRQ8_FZt-uu2fkzqZq7fZZm1oWS5kK6-gm94M")

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
                    try? await authClient.signInAnonymously()

                    await inventory.fetchItems()
                }
                .preferredColorScheme(.light)
        }
    }
}
