import SwiftUI

struct ContentView: View {
    init() {
        if UIDevice.current.userInterfaceIdiom == .phone {
            let tabBarAppearance = UITabBarAppearance()
            tabBarAppearance.configureWithOpaqueBackground()
            tabBarAppearance.backgroundColor = UIColor.white
            UITabBar.appearance().standardAppearance = tabBarAppearance
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        }
    }

    var body: some View {
        TabView {
            TodayView().tabItem {
                Label("Today", systemImage: "text.rectangle.page").environment(\.symbolVariants, .none)
            }
            SearchView().tabItem {
                Label("Today", systemImage: "magnifyingglass")
            }
            InventoryView().tabItem {
                Label("Inventory", systemImage: "refrigerator")
            }
        }.accentColor(Color("blue-600"))
    }
}

#Preview {
    ContentView()
}
