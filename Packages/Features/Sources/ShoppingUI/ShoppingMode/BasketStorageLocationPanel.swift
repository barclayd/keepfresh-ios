import DesignSystem
import Environment
import Models
import SwiftUI

struct BasketStorageLocationPanel: View {
    @Environment(Shopping.self) var shopping

    let storageLocation: StorageLocation
    let items: [ShoppingItem]

    @State private var isExpanded: Bool = true
    
    @Namespace private var animation

    private var textColor: Color {
        storageLocation == .freezer ? .white200 : .blue800
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                HStack(alignment: .firstTextBaseline) {
                    Image(systemName: storageLocation.iconFilled)
                        .frame(width: 22)
                        .foregroundColor(textColor)
                        .fontWeight(.bold)

                    Text(storageLocation.rawValue.capitalized)
                        .fontWeight(.bold)
                        .foregroundStyle(textColor)
                        .font(.title3)
                        .lineLimit(1)
                        .alignmentGuide(.firstTextBaseline) { d in
                            d[.bottom] * 0.75
                        }
                }

                Spacer()

                HStack {
                    Image(systemName: "\(items.count).square.fill")
                        .frame(width: 20)
                        .foregroundColor(textColor)

                    Image(systemName: "chevron.down")
                        .rotationEffect(.degrees(isExpanded ? -180 : 0))
                        .frame(width: 20)
                        .foregroundColor(textColor)
                }
                .fontWeight(.bold)
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 15)
            .frame(maxWidth: .infinity)
            .background(
                UnevenRoundedRectangle(
                    cornerRadii: RectangleCornerRadii(
                        topLeading: 10,
                        bottomLeading: isExpanded ? 0 : 10,
                        bottomTrailing: isExpanded ? 0 : 10,
                        topTrailing: 10
                    )
                )
                .fill(
                    LinearGradient(
                        stops: storageLocation.viewGradientStopsReversed,
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            )
            .onTapGesture {
                withAnimation(.easeInOut) {
                    isExpanded.toggle()
                }
            }

            if isExpanded {
                VStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.black)
                        .opacity(0.15)
                        .frame(maxWidth: .infinity, maxHeight: 1)
                    
                    List {
                        ForEach(items, id: \.self) { shoppingItem in
                            ShoppingModeConfirmItemView(shoppingItem: shoppingItem, animation: animation)
                                .containerRelativeFrame(.horizontal, alignment: .trailing) { length, _ in
                                    length * 0.95
                                }
                                .frame(maxWidth: .infinity, alignment: .center)
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        withAnimation {
                                            shopping.deleteItem(id: shoppingItem.id)
                                        }
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }.tint(Color.red500)
                                    Button {
                                        Task {
                                            await shopping.addItem(
                                                request: AddShoppingItemRequest(
                                                    title: shoppingItem.title,
                                                    source: .user,
                                                    storageLocation: shoppingItem.storageLocation,
                                                    productId: shoppingItem.product?.id,
                                                    quantity: 1),
                                                categoryId: shoppingItem.product?.category.id)
                                        }
                                    } label: {
                                        Label("Add another", systemImage: "plus.rectangle.fill.on.rectangle.fill")
                                    }.tint(Color.green500)
                                }
                        }
                        .listRowInsets(EdgeInsets())
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    }
                    .padding(.horizontal, -15)
                    .frame(height: CGFloat(items.count) * 75)
                    .listStyle(.plain)
                    .scrollDisabled(true)
                    .listRowSpacing(10)
                    .scrollContentBackground(.hidden)
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 15)
                .frame(maxWidth: .infinity)
                .background(
                    UnevenRoundedRectangle(
                        cornerRadii: RectangleCornerRadii(
                            topLeading: 0,
                            bottomLeading: 10,
                            bottomTrailing: 10,
                            topTrailing: 0
                        )
                    )
                    .fill(
                        LinearGradient(
                            stops: storageLocation.viewGradientStopsReversed,
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                )
            }
        }
        .padding(.horizontal)
    }
}
