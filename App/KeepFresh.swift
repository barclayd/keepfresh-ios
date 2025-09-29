import DesignSystem
import Environment
import Router
import SwiftUI
import FoundationModels

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

    init() {
        FontRegistration.registerFonts()
    }

    var body: some Scene {
        WindowGroup {
            AppTabRootView()
                .environment(router)
                .environment(inventory)
                .task {
                    await inventory.fetchItems()
                }
                .onAppear {
                    Task {
                        let session = LanguageModelSession(instructions: """
                            You are an expert in predicting food wastage. For each set of data, calculate and return only the most likely waste percentage for the user's next purchase of a given food item.
                                Consumed - means 0% food waste for a given food waste
                            """)
                        let response = try await session.respond(to: """
                            Food Name: Chicken Thighs
                            Purchased Count: 8
                            Consumed Count: 4
                            Discard Count: 4
                            Average percentage wasted of product when discarded: 25%
                            """)
                        
                        print("response: \(response)")
                    }
                    
                }
        }
    }
}
