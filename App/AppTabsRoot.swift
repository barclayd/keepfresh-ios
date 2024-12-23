import DesignSystem
import KitchenUI
import Router
import SearchUI
import SwiftUI
import SwiftUIIntrospect
import TodayUI

struct AppTabRootView: View {
    @Environment(Router.self) var router
    @State private var searchText = ""

    var body: some View {
        @Bindable var router = router

        TabView(selection: $router.selectedTab) {
            ForEach(AppTab.allCases) { tab in
                NavigationStack(path: $router[tab]) {
                    tab.rootView()
                        .withAppRouter()
                        .environment(\.currentTab, tab)
                }
                .tint(.white200)
                .tabItem { tab.label }
                .tag(tab)
            }
        }
    }
}

@MainActor
private extension AppTab {
    @ViewBuilder
    func rootView() -> some View {
        switch self {
        case .today:
            TodayView()
        case .search:
            SearchView()
        case .kitchen:
            KitchenView()
        }
    }
}

public extension AppTab {
    @ViewBuilder
    var label: some View {
        Label(title, systemImage: icon)
            .environment(\.symbolVariants, self == .today ? .none : .fill)
    }

    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        switch self {
        case .today, .kitchen:
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
                    .foregroundColor(.green500).font(
                        Font.custom("Shrikhand-Regular", size: 32, relativeTo: .title))
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

        case .search:
            ToolbarItem(placement: .topBarLeading) {
                Text("Search")
                    .foregroundColor(.white200).font(
                        Font.custom("Shrikhand-Regular", size: 28, relativeTo: .title))
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    print("Barcode scan")
                }) {
                    Image(systemName: "barcode.viewfinder").resizable()
                        .frame(width: 24, height: 24).foregroundColor(.white200)
                }
            }
        }
    }
}
