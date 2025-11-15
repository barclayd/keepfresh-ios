import DesignSystem
import Models
import Router
import SwiftUI

public struct ShoppingView: View {
    @Environment(Router.self) var router

    @State private var currentPage: Int = 3
    @State private var viewModel = ShoppingViewModel(items: ShoppingView.mockItems)

    public init() {}

    var shoppingListTabs: [String] {
        ["Fri 31st Oct", "Fri 7th", "Last Shop", "Today", "Tomorrow", "Mon 17th", "Mon 24th"]
    }

    public var body: some View {
        VStack {
            ZStack(alignment: .bottomTrailing) {
                ScrollView {
                    LazyVStack {
                        ForEach(StorageLocation.allCases) { storageLocation in
                            StorageLocationPanel(
                                storageLocation: storageLocation,
                                viewModel: viewModel)
                        }
                    }
                    .padding(.horizontal, 12.5)
                    .padding(.top, 20)
                    .padding(.bottom, 10)
                }

                Button(action: {
                    router.presentedSheet = .shopppingSearch
                }) {
                    Label("Add Exercise", systemImage: "plus")
                        .font(.title3)
                        .bold()
                        .labelStyle(.iconOnly)
                        .padding()
                        .tint(Color.white)
                }
                .glassEffect(.regular.tint(.green500))
                .scenePadding(.trailing)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.white200)
    }

    // Mock data for testing cross-list dragging
    static var mockItems: [ShoppingListItem] {
        [
            ShoppingListItem(
                id: 1,
                title: nil,
                createdAt: Date(),
                updatedAt: Date(),
                source: .userAdded,
                status: .added,
                storageLocation: .fridge,
                product: Product(
                    id: 1,
                    name: "Semi Skimmed Milk",
                    unit: "pts",
                    brand: .tesco,
                    amount: 4,
                    category: CategoryDetails(
                        icon: "milk",
                        id: 1,
                        name: "Milk",
                        pathDisplay: "Fresh Food > Dairy > Milk"))),
            ShoppingListItem(
                id: 2,
                title: nil,
                createdAt: Date(),
                updatedAt: Date(),
                source: .userAdded,
                status: .added,
                storageLocation: .fridge,
                product: Product(
                    id: 2,
                    name: "Whole Milk",
                    unit: "pts",
                    brand: .tesco,
                    amount: 4,
                    category: CategoryDetails(
                        icon: "milk",
                        id: 1,
                        name: "Milk",
                        pathDisplay: "Fresh Food > Dairy > Milk"))),
            ShoppingListItem(
                id: 3,
                title: nil,
                createdAt: Date(),
                updatedAt: Date(),
                source: .userAdded,
                status: .added,
                storageLocation: .freezer,
                product: Product(
                    id: 3,
                    name: "Ice Cream",
                    unit: "tubs",
                    brand: .tesco,
                    amount: 2,
                    category: CategoryDetails(
                        icon: "icecream",
                        id: 2,
                        name: "Desserts",
                        pathDisplay: "Frozen > Desserts"))),
        ]
    }
}
