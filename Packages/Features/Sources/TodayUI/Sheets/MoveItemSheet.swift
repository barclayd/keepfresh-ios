import DesignSystem
import Models
import SharedUI
import SwiftUI

public struct MoveInventoryItemSheet: View {
    @State private var expiryDate: Date

    var inventoryItem: InventoryItem
    var storageLocation: StorageLocation

    let recommendedExpiryDate: Date?

    let onMove: (_ storageLocation: StorageLocation?, _ expiryDate: Date) -> Void

    public init(
        inventoryItem: InventoryItem,
        storageLocation: StorageLocation,
        recommendedExpiryDate: Date? = nil,
        onMove: @escaping (_ storageLocation: StorageLocation?, _ expiryDate: Date) -> Void)
    {
        self.inventoryItem = inventoryItem
        self.storageLocation = storageLocation
        self.onMove = onMove
        _expiryDate = State(initialValue: recommendedExpiryDate ?? inventoryItem.expiryDate)
        self.recommendedExpiryDate = recommendedExpiryDate
    }

    var isRecommendedExpiryDate: Bool {
        guard let recommendedExpiryDate else { return false }

        return recommendedExpiryDate.isSameDay(as: expiryDate)
    }

    var isRecommendedStorageLocation: Bool {
        recommendedExpiryDate != nil
    }

    public var body: some View {
        VStack(spacing: 20) {
            Text(
                "\(Text("Move").foregroundStyle(.gray600)) \(Text(inventoryItem.product.name.truncated(to: 25)).foregroundStyle(.blue700))")
                .lineLimit(2).multilineTextAlignment(.center).fontWeight(.bold).padding(.horizontal, 20).font(.title2).padding(.top, 10)

            InventoryCategory(
                type: .compactExpiry(
                    date: $expiryDate,
                    isRecommended: isRecommendedExpiryDate,
                    expiryType: inventoryItem.expiryType,
                    storageLocation: inventoryItem.storageLocation),
                storageLocation: storageLocation,
                forceExpanded: true,
                customColor: storageLocation == .freezer ? (.white200, .blue800) : nil)

            InventoryCategory(
                type: .readOnlyStorage(location: storageLocation, isRecommended: isRecommendedStorageLocation),
                storageLocation: storageLocation,
                customColor: storageLocation == .freezer ? (.white200, .blue800) : nil)

            Spacer()

            Button(action: {
                onMove(storageLocation, expiryDate)
            }) {
                HStack(spacing: 10) {
                    Image(systemName: storageLocation.iconFilled)
                        .font(.system(size: 18))
                        .frame(width: 20, alignment: .center)
                    Text("Move to \(storageLocation.rawValue.capitalized)")
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
