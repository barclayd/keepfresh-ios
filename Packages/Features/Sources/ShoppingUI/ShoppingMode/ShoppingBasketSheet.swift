import DesignSystem
import Environment
import Models
import SwiftUI

public struct ShoppingBasketSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(Shopping.self) var shopping

    public init() {}

    private var pendingItems: [ShoppingItem] {
        shopping.items.filter { $0.status == .pendingCompletion }
    }

    private var pendingItemsByLocation: [StorageLocation: [ShoppingItem]] {
        Dictionary(
            grouping: pendingItems.filter { $0.storageLocation != nil },
            by: { $0.storageLocation! })
    }

    public var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        Text("\(pendingItems.count) items to be added")
                            .font(.title3)
                            .foregroundStyle(.blue800)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)

                        ForEach(StorageLocation.allCases) { location in
                            if let items = pendingItemsByLocation[location], !items.isEmpty {
                                BasketStorageLocationPanel(
                                    storageLocation: location,
                                    items: items)
                            }
                        }

                        if !shopping.itemsWithoutStorageLocation.filter({ $0.status == .pendingCompletion }).isEmpty {
                            OtherBasketStorageLocationPanel()
                        }
                    }
                    .padding(.vertical)
                    .padding(.bottom, 100)
                }
                .overlay(alignment: .bottom) {
                    BottomActionCustomButton(
                        title: "Finish shop",
                        safeAreaInsets: geometry.safeAreaInsets,
                        action: {})
                }
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "chevron.down")
                                .font(.system(size: 24))
                                .foregroundStyle(.gray600)
                        }
                        .buttonStyle(.borderless)
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            // Empty for now - batch API coming soon
                        } label: {
                            Image(systemName: "checkmark")
                                .fontWeight(.semibold)
                        }
                        .buttonStyle(.glassProminent)
                        .tint(.green500)
                    }
                }
            }.edgesIgnoringSafeArea(.bottom)
        }
    }
}
