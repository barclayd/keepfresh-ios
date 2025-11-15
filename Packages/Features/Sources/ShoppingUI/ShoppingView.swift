import DesignSystem
import Models
import SwiftUI

public struct ShoppingView: View {
    @State private var currentPage: Int = 3

    public init() {}

    var shoppingListTabs: [String] {
        ["Fri 31st Oct", "Fri 7th", "Last Shop", "Today", "Tomorrow", "Mon 17th", "Mon 24th"]
    }

    public var body: some View {
        VStack {
            ScrollView {
                LazyVStack {
                    ForEach(StorageLocation.allCases) { storageLocation in
                        StorageLocationPanel(storageLocation: storageLocation)
                    }
                }
                .padding(.horizontal, 12.5)
                .padding(.top, 20)
                .padding(.bottom, 10)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.white200)
    }
}
