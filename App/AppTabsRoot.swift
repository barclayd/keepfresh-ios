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
                    tab.rootView(searchText: $searchText)
                        .environment(\.currentTab, tab)
                        .navigationBarSearch(searchText: $searchText)
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
    func rootView(searchText: Binding<String>) -> some View {
        switch self {
        case .today:
            TodayView()
        case .search:
            SearchView(searchText: searchText)
        case .kitchen:
            KitchenView()
        }
    }
}

public struct NavigatationBarSearch: ViewModifier {
    @Binding var searchText: String
    @Environment(Router.self) var router

    public func body(content: Content) -> some View {
        switch router.selectedTab {
        case .search:
            content.searchable(
                text: $searchText,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "What do you want to track next?"
            )
            .onAppear {
                UISearchTextField.appearance().backgroundColor = .blue400
                UISearchTextField.appearance().tintColor = .white200

                UISearchTextField.appearance().borderStyle = .none
                UISearchTextField.appearance().layer.cornerRadius = 10

                UISearchTextField.appearance().attributedPlaceholder = NSAttributedString(
                    string: "What do you want to track next?",
                    attributes: [.foregroundColor: UIColor.gray200]
                )

                func searchBarImage() -> UIImage {
                    let image = UIImage(systemName: "magnifyingglass")
                    return image!.withTintColor(UIColor(.white200), renderingMode: .alwaysOriginal)
                }

                func clearButtonImage() -> UIImage {
                    let image = UIImage(systemName: "xmark.circle.fill")
                    return image!.withTintColor(UIColor(.blue800), renderingMode: .alwaysOriginal)
                }

                UISearchTextField.appearance(whenContainedInInstancesOf: [UISearchBar.self])
                    .attributedPlaceholder = NSAttributedString(
                        string: "What do you want to track next?",
                        attributes: [.foregroundColor: UIColor(.white200)]
                    )

                UISearchBar.appearance(whenContainedInInstancesOf: [UINavigationBar.self]).setImage(
                    searchBarImage(), for: .search, state: .normal
                )
                UISearchBar.appearance(whenContainedInInstancesOf: [UINavigationBar.self]).setImage(
                    clearButtonImage(), for: .clear, state: .normal
                )

                UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self])
                    .setTitleTextAttributes([.foregroundColor: UIColor.white400], for: .normal)
            }.foregroundColor(.white200)
        case .today, .kitchen:
            content
        }
    }
}

public extension View {
    func navigationBarSearch(searchText: Binding<String>) -> some View {
        modifier(NavigatationBarSearch(searchText: searchText))
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
