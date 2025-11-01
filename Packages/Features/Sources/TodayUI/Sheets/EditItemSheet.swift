import Models
import SharedUI
import SwiftUI

public struct EditInventoryItemSheet: View {
    @State private var expiryDate: Date

    var inventoryItem: InventoryItem

    let onEdit: (_ expiryDate: Date) -> Void

    public init(
        inventoryItem: InventoryItem,
        onEdit: @escaping (_ expiryDate: Date) -> Void)
    {
        self.inventoryItem = inventoryItem
        self.onEdit = onEdit
        _expiryDate = State(initialValue: inventoryItem.expiryDate)
    }

    public var body: some View {
        VStack(spacing: 20) {
            Text(
                "\(Text("Edit").foregroundStyle(.gray600)) \(Text(inventoryItem.product.name.truncated(to: 25)).foregroundStyle(.blue700))")
                .lineLimit(2).multilineTextAlignment(.center).fontWeight(.bold).padding(.horizontal, 20).font(.title2).padding(.top, 10)

            InventoryCategory(
                type: .compactExpiry(date: $expiryDate, isRecommended: false, expiryType: inventoryItem.expiryType),
                storageLocation: inventoryItem.storageLocation,
                forceExpanded: true,
                customColor: inventoryItem.storageLocation == .freezer ? (.white200, .blue800) : nil)

            Spacer()

            Button(action: {
                onEdit(expiryDate)
            }) {
                HStack(spacing: 10) {
                    Image(systemName: "calendar")
                        .font(.system(size: 18))
                        .frame(width: 20, alignment: .center)
                    Text("Save")
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
