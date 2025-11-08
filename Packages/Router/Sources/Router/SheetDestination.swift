import Foundation
import Models

public enum InventoryItemAction: Hashable, Identifiable {
    public var id: String {
        switch self {
        case .move: "move"
        case .open: "open"
        case .remove: "remove"
        case .edit: "edit"
        }
    }

    case move(StorageLocation)
    case open(Date)
    case remove
    case edit
}

public enum SheetDestination: Hashable, Identifiable {
    public var id: Int { hashValue }

    case barcodeScan
    case inventoryItem(InventoryItem, InventoryItemAction?)

    case moveInventoryItemDirect(InventoryItem, StorageLocation)
    case openInventoryItemDirect(InventoryItem, Date)
    case removeInventoryItemDirect(InventoryItem)
}
