import DesignSystem
import Models
import SharedUI
import SwiftUI

public struct StorageLocationPanel: View {
    @State private var isToggled: Bool = false

    @State private var shoppingListItems: [ShoppingListItem] = [
        ShoppingListItem(id: 1, createdAt: Date(), updatedAt: Date(), source: .userAdded, status: .added, storageLocation: .fridge, product: Product(id: 1, name: "Semi Skimmed Milk", unit: "pts", brand: .tesco, amount: 4, category: CategoryDetails(icon: "milk", id: 1, name: "Milk", pathDisplay: "Fresh Food > Dairy > Milk"))),
        ShoppingListItem(id: 2, createdAt: Date(), updatedAt: Date(), source: .userAdded, status: .added, storageLocation: .fridge, product: Product(id: 1, name: "Whole Milk", unit: "pts", brand: .tesco, amount: 4, category: CategoryDetails(icon: "milk", id: 1, name: "Milk", pathDisplay: "Fresh Food > Dairy > Milk"))),
        ShoppingListItem(id: 3, createdAt: Date(), updatedAt: Date(), source: .userAdded, status: .added, storageLocation: .fridge, product: Product(id: 1, name: "Skimmed Milk", unit: "pts", brand: .tesco, amount: 4, category: CategoryDetails(icon: "milk", id: 1, name: "Milk", pathDisplay: "Fresh Food > Dairy > Milk"))),
    ]

    let storageLocation: StorageLocation

    public init(storageLocation: StorageLocation) {
        self.storageLocation = storageLocation
    }

    var textColor: Color {
        storageLocation == .freezer ? .white200 : .blue800
    }

    func move(indexSet: IndexSet, int: Int) {
        shoppingListItems.move(fromOffsets: indexSet, toOffset: int)
    }

    public var body: some View {
        VStack(spacing: 0) {
            HStack {
                HStack(alignment: .firstTextBaseline) {
                    Image(systemName: storageLocation.iconFilled)
                        .frame(width: 18).foregroundColor(textColor).fontWeight(.bold)

                    Text(storageLocation.rawValue.capitalized)
                        .fontWeight(.bold)
                        .foregroundStyle(textColor)
                        .font(.headline)
                        .lineLimit(1)
                        .alignmentGuide(.firstTextBaseline) { d in
                            d[.bottom] * 0.75
                        }
                }

                Spacer()

                HStack {
                    Image(systemName: "5.square.fill")
                        .frame(width: 18).foregroundColor(textColor)
                    Image(systemName: "chevron.down")
                        .rotationEffect(.degrees(isToggled ? -180 : 0))
                        .frame(width: 18).foregroundColor(textColor)
                }.fontWeight(.bold)
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 15)
            .frame(maxWidth: .infinity)
            .background(
                UnevenRoundedRectangle(cornerRadii: RectangleCornerRadii(
                    topLeading: 10,
                    bottomLeading: isToggled ? 0 : 10,
                    bottomTrailing: isToggled ? 0 : 10,
                    topTrailing: 10)).fill(LinearGradient(stops: storageLocation.viewGradientStopsReversed, startPoint: .leading, endPoint: .trailing)))
            .onTapGesture {
                //                withAnimation(.easeInOut) {
                isToggled.toggle()
                //                }
            }
            //            .transition(.move(edge: .top))
            if isToggled {
                VStack {
                    RoundedRectangle(cornerRadius: 10).fill(Color.black).opacity(0.15).frame(maxWidth: .infinity, maxHeight: 1).offset(y: -10)

                    List {
                        ForEach(shoppingListItems, id: \.self) { shoppingListItem in
                            ShoppingListItemView(shoppingListItem: shoppingListItem)
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
//                                        store.delete(message)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                    Button {
//                                        store.flag(message)
                                    } label: {
                                        Label("Flag", systemImage: "flag")
                                    }
                                }
                        }
                        .onMove(perform: move)
                        .listRowInsets(EdgeInsets())
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    }
                    .frame(height: 250)
                    .listStyle(.plain)
                    .listRowSpacing(20)
                    .scrollContentBackground(.hidden)

                }.padding(.vertical, 10).padding(.horizontal, 15).frame(maxWidth: .infinity)
                    .background(
                        UnevenRoundedRectangle(cornerRadii: RectangleCornerRadii(
                            topLeading: 0,
                            bottomLeading: 10,
                            bottomTrailing: 10,
                            topTrailing: 0))
                            .fill(LinearGradient(stops: storageLocation.viewGradientStopsReversed, startPoint: .leading, endPoint: .trailing)))
            }
        }
    }
}
