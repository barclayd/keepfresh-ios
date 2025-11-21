import DesignSystem
import Environment
import Models
import Router
import SwiftUI

public struct ShoppingView: View {
    @Environment(Router.self) var router

    @State private var currentPage: Int = 3

    public init() {}

    public var body: some View {
        VStack {
            ZStack(alignment: .bottomTrailing) {
                ScrollView {
                    LazyVStack(spacing: 20) {
                        ForEach(StorageLocation.allCases) { storageLocation in
                            StorageLocationPanel(storageLocation: storageLocation)
                        }
                    }
                    .padding(.horizontal, 12.5)
                    .padding(.top, 20)
                    .padding(.bottom, 10)
                }

                Button(action: {
                    router.presentedSheet = .shopppingSearch
                }) {
                    Label("Add item to shopping list", systemImage: "plus")
                        .font(.title3)
                        .bold()
                        .labelStyle(.iconOnly)
                        .padding()
                        .tint(Color.white)
                }
                .glassEffect(.regular.tint(.blue600))
                .scenePadding(.trailing)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.white200)
        .sensoryFeedback(.selection, trigger: router.presentedSheet == .shopppingSearch)
    }
}
