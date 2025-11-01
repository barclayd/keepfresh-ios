import Models
import SharedUI
import SwiftUI

public struct MoveInventoryItemSheet: View {
    @State private var date: Date = .init()

    var inventoryItem: InventoryItem
    var storageLocation: StorageLocation

    let onMove: (_ storageLocation: StorageLocation, _ expiryDate: Date) -> Void

    public init(
        inventoryItem: InventoryItem,
        storageLocation: StorageLocation,
        onMove: @escaping (_ storageLocation: StorageLocation, _ expiryDate: Date) -> Void)
    {
        self.inventoryItem = inventoryItem
        self.storageLocation = storageLocation
        self.onMove = onMove
    }

    var title: AttributedString {
        var result = AttributedString("Move ")

        result.append(AttributedString(inventoryItem.product.name.truncated(to: 25)))

        return result
    }

    public var body: some View {
        VStack(spacing: 20) {
            Text(title)
                .lineLimit(2).multilineTextAlignment(.center).fontWeight(.bold).padding(.horizontal, 20).font(.title2).padding(.top, 10)

            InventoryCategory(
                type: .compactExpiry(date: $date, isRecommended: true, expiryType: inventoryItem.expiryType),
                storageLocation: storageLocation,
                forceExpanded: true,
                customColor: storageLocation == .freezer ? (.white200, .blue800) : nil)

            InventoryCategory(
                type: .readOnlyStorage(location: storageLocation, isRecommended: true),
                storageLocation: storageLocation,
                forceExpanded: false,
                customColor: storageLocation == .freezer ? (.white200, .blue800) : nil)

            Spacer()

            Button(action: {
                onMove(storageLocation, Date())
            }) {
                HStack(spacing: 10) {
                    Image(systemName: "house.fill")
                        .font(.system(size: 18))
                        .frame(width: 20, alignment: .center)
                    Text("Move")
                        .font(.headline)
                }
                .foregroundStyle(.blue600)
                .fontWeight(.bold)
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.green300))
            }

        }.frame(maxWidth: .infinity)
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
    }
}
