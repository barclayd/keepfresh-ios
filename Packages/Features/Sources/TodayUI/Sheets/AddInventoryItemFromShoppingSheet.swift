import Models
import SharedUI
import SwiftUI

func addDaysToNow(_ days: Int) -> Date {
    let calendar: Calendar = .current
    return calendar.date(byAdding: .day, value: days, to: Date())!
}

@MainActor
func getExpiryDateForSelection(
    storageLocation: StorageLocation,
    status: ProductSearchItemStatus,
    shelfLife: ShelfLifeInDays) -> Date?
{
    guard let expiryInDays = shelfLife[status][storageLocation] else {
        return nil
    }

    return addDaysToNow(expiryInDays)
}

@MainActor
func getRecommendedExpiryDate(shoppingItem: ShoppingItem) -> Date? {
    guard let categoryId = shoppingItem.product?.category.id, let storageLocation = shoppingItem.storageLocation else {
        return nil
    }

    let suggestions = SuggestionsCache.shared.getSuggestions(for: categoryId)

    guard
        let shelfLife = suggestions?.shelfLifeInDays,
        let expiry = getExpiryDateForSelection(
            storageLocation: storageLocation,
            status: .unopened,
            shelfLife: shelfLife)
    else {
        return nil
    }
    return expiry
}

public struct AddInventoryItemFromShoppingSheet: View {
    @State private var expiryDate: Date

    var shoppingItem: ShoppingItem

    let onAdd: (_ expiryDate: Date) -> Void

    public init(
        shoppingItem: ShoppingItem,
        onAdd: @escaping (_ expiryDate: Date) -> Void)
    {
        self.shoppingItem = shoppingItem
        self.onAdd = onAdd
        _expiryDate = State(initialValue: getRecommendedExpiryDate(shoppingItem: shoppingItem) ?? Date())
    }

    public var body: some View {
        VStack(spacing: 20) {
            Text(
                "\(Text("Add").foregroundStyle(.gray600)) \(Text(shoppingItem.product!.name.truncated(to: 25)).foregroundStyle(.blue700))")
                .lineLimit(2).multilineTextAlignment(.center).fontWeight(.bold).padding(.horizontal, 20).font(.title2).padding(.top, 10)

            InventoryCategory(
                type: .compactExpiry(
                    date: $expiryDate,
                    isRecommended: false,
                    expiryType: shoppingItem.product!.category.expiryType,
                    storageLocation: shoppingItem.storageLocation!),
                storageLocation: shoppingItem.storageLocation!,
                forceExpanded: true,
                customColor: shoppingItem.storageLocation == .freezer ? (.white200, .blue800) : nil)

            Spacer()

            Button(action: {
                onAdd(expiryDate)
            }) {
                HStack(spacing: 10) {
                    Image(systemName: shoppingItem.storageLocation!.iconFilled)
                        .font(.system(size: 18))
                        .frame(width: 20, alignment: .center)
                    Text("Add")
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
