import Foundation
import Models

public enum SheetDestination: Hashable, Identifiable {
    public var id: Int { hashValue }

    case barcodeScan
    case inventoryItem(InventoryItem)
}
