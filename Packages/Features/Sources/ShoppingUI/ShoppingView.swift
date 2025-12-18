import DesignSystem
import Environment
import Models
import Router
import SwiftUI

public struct ShoppingView: View {
    @Environment(Router.self) var router
    @Environment(Shopping.self) var shopping

    @State private var currentPage: Int = 3
    @Namespace private var shoppingAnimation

    public init() {}

    public var body: some View {
        VStack {
            ScrollView {
                LazyVStack(spacing: 20) {
                    if shopping.shoppingMode == .initial {
                        ForEach(StorageLocation.allCases) { storageLocation in
                            StorageLocationPanel(storageLocation: storageLocation, animation: shoppingAnimation)
                                .transition(.move(edge: .bottom))
                        }
                    } else {
                        ShoppingMode(animation: shoppingAnimation)
                    }

                    if shopping.shoppingMode == .initial || !shopping.itemsWithoutStorageLocation.isEmpty {
                        OtherItemsPanel()
                    }
                }
                .animation(.easeInOut, value: shopping.shoppingMode)
                .padding(.horizontal, 12.5)
                .padding(.top, 20)
                .padding(.bottom, 10)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.white200)
        .sensoryFeedback(.selection, trigger: router.presentedSheet == .shopppingSearch)
    }
}
