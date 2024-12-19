import Router
import SwiftUI

struct AppTabRootView: View {
    @Environment(Router.self) var router

    let tab: AppTab

    var body: some View {
        @Bindable var router = router

        GeometryReader { _ in
            NavigationStack(path: $router[tab]) {
                tab.rootView
                    .navigationBarHidden(true)
            }
        }
        .ignoresSafeArea()
    }
}

@MainActor
private extension AppTab {
    @ViewBuilder
    var rootView: some View {
        switch self {
        case .search:
            Text("Hello")
        }
    }
}
