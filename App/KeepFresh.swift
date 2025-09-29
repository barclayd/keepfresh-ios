import DesignSystem
import Environment
import Router
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
        }
    }
}
