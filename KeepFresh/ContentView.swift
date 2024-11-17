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
        NavigationStack {
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
                .toolbarRole(.browser)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: {
                            print("Profile click")
                        }) {
                            Image(systemName: "person.crop.circle.fill").resizable()
                                .frame(width: 24, height: 24).foregroundColor(.blue600)
                        }
                    }

                    ToolbarItem(placement: .principal) {
                        Text("Fresh")
                            .foregroundColor(.green500).font(Font.custom("Shrikhand-Regular", size: 32, relativeTo: .title))
                    }

                    ToolbarItemGroup {
                        Button(action: {
                            print("Add item")
                        }) {
                            Image(systemName: "plus.app").resizable()
                                .frame(width: 24, height: 24).foregroundColor(.blue600)
                        }
                        Button(action: {
                            print("Scan barcode")
                        }) {
                            Image(systemName: "barcode.viewfinder").resizable()
                                .frame(width: 24, height: 24).foregroundColor(.blue600)
                        }
                    }
                }.toolbarBackground(.white, for: .navigationBar)
                .toolbarBackgroundVisibility(.visible, for: .navigationBar)
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    ContentView()
}
