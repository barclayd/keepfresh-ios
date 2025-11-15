import Foundation
import Models
import SwiftUI

@Observable
public final class ShoppingViewModel {
    public var items: [ShoppingListItem]

    public init(items: [ShoppingListItem] = []) {
        self.items = items
    }

    // Filter items by storage location
    public func items(for storageLocation: StorageLocation) -> [ShoppingListItem] {
        items.filter { $0.storageLocation == storageLocation }
    }

    // Move item within same storage location (for within-list reordering)
    public func moveItem(itemId: Int, toIndex targetIndex: Int, in storageLocation: StorageLocation) {
        // Get the current filtered list
        var filteredItems = items(for: storageLocation)

        // Find the source index in the filtered list
        guard let sourceIndex = filteredItems.firstIndex(where: { $0.id == itemId }) else { return }

        // Don't move if source and target are the same
        if sourceIndex == targetIndex { return }

        // Remove from source position
        let item = filteredItems.remove(at: sourceIndex)

        // Insert at target position
        // Adjust target index if we removed an item before the target
        let adjustedTargetIndex = sourceIndex < targetIndex ? targetIndex - 1 : targetIndex
        filteredItems.insert(item, at: adjustedTargetIndex)

        // Update the main array with new order
        items.removeAll { $0.storageLocation == storageLocation }
        items.append(contentsOf: filteredItems)
    }

    // Move item to a new storage location at a specific index
    public func moveItemToLocation(itemId: Int, to newLocation: StorageLocation, atIndex targetIndex: Int) {
        guard let sourceIndex = items.firstIndex(where: { $0.id == itemId }) else { return }
        let item = items[sourceIndex]

        // Create updated item with new storage location
        let updatedItem = ShoppingListItem(
            id: item.id,
            createdAt: item.createdAt,
            updatedAt: Date(),
            source: item.source,
            status: item.status,
            storageLocation: newLocation,
            product: item.product
        )

        // Remove from original location
        items.remove(at: sourceIndex)

        // Get items for the target location
        var targetItems = items.filter { $0.storageLocation == newLocation }

        // Insert at specified index
        let safeTargetIndex = min(targetIndex, targetItems.count)
        targetItems.insert(updatedItem, at: safeTargetIndex)

        // Update the main array
        items.removeAll { $0.storageLocation == newLocation }
        items.append(contentsOf: targetItems)
    }
}
