import Foundation

public enum SheetDestination: Hashable, Identifiable {
    public var id: Int { hashValue }

    case barcodeScan
}
