import DesignSystem
import Environment
import Models
import Router
import SwiftUI

public struct ShoppingView: View {
    @Environment(Router.self) var router
    @Environment(Shopping.self) var shopping

    @State private var currentPage: Int = 3

    public init() {}

    public var body: some View {
        VStack {
            ScrollView {
                LazyVStack(spacing: 20) {
                    if shopping.shoppingMode == .initial {
                        ForEach(StorageLocation.allCases) { storageLocation in
                            StorageLocationPanel(storageLocation: storageLocation)
                                .transition(.move(edge: .bottom))
                        }
                    } else {
                        UpNextPanel(storageLocation: .pantry)
                        
                        ForEach(StorageLocation.allCases) { storageLocation in
                            ForEach(shopping.categoriesByStorageLocation[storageLocation] ?? [], id: \.id) { category in
                                CategoryPanel(storageLocation: storageLocation, category: category)
                                    .transition(.move(edge: .bottom))
                            }
                        }
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
