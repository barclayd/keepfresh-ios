import Models
import KeepFreshNetwork
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
    @State private var isAdding = false
    @State private var errorMessage: String?

    var shoppingItem: ShoppingItem

    let onAdd: @MainActor (_ expiryDate: Date) async throws -> Void

    public init(
        shoppingItem: ShoppingItem,
        onAdd: @escaping @MainActor (_ expiryDate: Date) async throws -> Void)
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
                guard !isAdding else { return }
                isAdding = true
                Task {
                    defer { isAdding = false }
                    do {
                        try await onAdd(expiryDate)
                    } catch {
                        print("Completing shopping item \(shoppingItem.id) failed: \(String(reflecting: error))")
                        if let apiError = error as? APIError,
                           case let .httpError(statusCode, _) = apiError
                        {
                            errorMessage = "The server couldn't confirm the item was added (HTTP \(statusCode)). Refresh your inventory and shopping list before trying again."
                        } else if error is DecodingError {
                            errorMessage = "The server returned item details the app couldn't read. Refresh your inventory before trying again."
                        } else {
                            errorMessage = error.localizedDescription
                        }
                    }
                }
            }) {
                HStack(spacing: 10) {
                    if isAdding {
                        SwiftUI.ProgressView()
                            .tint(.blue600)
                    } else {
                        Image(systemName: shoppingItem.storageLocation!.iconFilled)
                            .font(.system(size: 18))
                            .frame(width: 20, alignment: .center)
                    }
                    Text(isAdding ? "Adding…" : "Add")
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
            .disabled(isAdding)

        }.frame(maxWidth: .infinity)
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
            .interactiveDismissDisabled(isAdding)
            .alert("Couldn't add to inventory", isPresented: Binding(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }))
            {
                Button("OK", role: .cancel) { errorMessage = nil }
            } message: {
                Text(errorMessage ?? "Please try again.")
            }
    }
}
