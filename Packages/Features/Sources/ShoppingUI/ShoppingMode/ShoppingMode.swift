import DesignSystem
import Environment
import Models
import SwiftUI

struct ShoppingMode: View {
    @Environment(Shopping.self) var shopping

    var animation: Namespace.ID

    var body: some View {
        if let storageLocation = shopping.upNextStorageLocation,
           let shoppingItem = shopping.upNextItem
        {
            UpNextPanel(storageLocation: storageLocation, shoppingItem: shoppingItem, animation: animation)
        }

        ForEach(StorageLocation.allCases) { storageLocation in
            ForEach(shopping.categoriesByStorageLocation[storageLocation] ?? [], id: \.id) { category in
                if !shopping.shoppingModeItems(for: storageLocation, category: category).isEmpty {
                    CategoryPanel(storageLocation: storageLocation, category: category, animation: animation)
                        .transition(.move(edge: .bottom))
                }
            }
        }

        if !shopping.itemsWithoutStorageLocation.isEmpty {
            ShoppingModeOtherItemsPanel()
        }

        if shopping.items.allSatisfy({ $0.status == .pendingCompletion }) {
            Text("All items completed")
        }
    }
}
