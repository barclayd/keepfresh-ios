import DesignSystem
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

    init() {
        if UIDevice.current.userInterfaceIdiom == .phone {
            let tabBarAppearance = UITabBarAppearance()
            tabBarAppearance.configureWithOpaqueBackground()
            tabBarAppearance.backgroundColor = UIColor.white
            UITabBar.appearance().standardAppearance = tabBarAppearance
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        }
        FontRegistration.registerFonts()
    }

    var body: some Scene {
        WindowGroup {
//            NavigationStack {
            AppTabRootView()
                .environment(router)
//            }.tint(router.currentTabPathTint)
        }.environment(router)
    }
}
