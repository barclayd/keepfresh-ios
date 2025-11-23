import DesignSystem
import Environment
import Models
import SharedUI
import SwiftUI

public struct OtherItemsPanel: View {
    @Environment(Shopping.self) var shopping
        
    @State private var isExpanded: Bool = true
    
    @FocusState private var editingTitleFocus: UUID?
    
    private var items: [ShoppingItem] {
        shopping.itemsWithoutStorageLocation
    }
    
    private func handleItemMove(sourceIndices: IndexSet, destinationIndex: Int) {
        guard let sourceIndex = sourceIndices.first else { return }
        guard sourceIndex < items.count else { return }
        
        let itemId = items[sourceIndex].id
        
        let adjustedDestination = sourceIndex < destinationIndex
            ? destinationIndex - 1
            : destinationIndex
        
        shopping.moveNonStorageLocationItem(
            itemId: itemId,
            fromIndex: sourceIndex,
            toIndex: adjustedDestination)
    }
    
    private var onMoveHandler: (IndexSet, Int) -> Void {
        handleItemMove
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            HStack {
                HStack(alignment: .firstTextBaseline) {
                    Image(systemName: "list.bullet")
                        .frame(width: 22).foregroundColor(.white200).fontWeight(.bold)
                    
                    Text("Other")
                        .fontWeight(.bold)
                        .foregroundStyle(.white200)
                        .font(.title3)
                        .lineLimit(1)
                        .alignmentGuide(.firstTextBaseline) { d in
                            d[.bottom] * 0.75
                        }
                }
                
                Spacer()
                
                HStack {
                    Image(systemName: "\(items.count).square.fill")
                        .frame(width: 20).foregroundColor(.white200)
                    
                    Image(systemName: "chevron.down")
                        .rotationEffect(.degrees(isExpanded ? -180 : 0))
                        .frame(width: 20).foregroundColor(.white200)
                    
                }.fontWeight(.bold)
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 15)
            .frame(maxWidth: .infinity)
            .background(
                UnevenRoundedRectangle(cornerRadii: RectangleCornerRadii(
                    topLeading: 10,
                    bottomLeading: isExpanded ? 0 : 10,
                    bottomTrailing: isExpanded ? 0 : 10,
                    topTrailing: 10)).fill(LinearGradient(
                    stops: [
                        Gradient.Stop(color: .gray500, location: 0),
                        Gradient.Stop(color: .gray700, location: 1),
                    ],
                    startPoint: .leading,
                    endPoint: .trailing)))
            .onTapGesture {
                withAnimation(.easeInOut) {
                    isExpanded.toggle()
                }
            }
            
            if isExpanded {
                VStack {
                    RoundedRectangle(cornerRadius: 10).fill(Color.black).opacity(0.15).frame(maxWidth: .infinity, maxHeight: 1)
                        .offset(y: -10)
                    
                    VStack(spacing: 0) {
                        List {
                            ForEach(items, id: \.uuid) { shoppingItem in
                                OtherShoppingItemView(shoppingItem: shoppingItem, editingTitleFocus: $editingTitleFocus)
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
                                            shopping.addItem(
                                                request: AddShoppingItemRequest(
                                                    title: shoppingItem.title,
                                                    source: .user,
                                                    storageLocation: shoppingItem.storageLocation,
                                                    productId: shoppingItem.product?.id,
                                                    quantity: 1),
                                                categoryId: shoppingItem.product?.category.id)
                                        } label: {
                                            Label("Add another", systemImage: "plus.rectangle.fill.on.rectangle.fill")
                                        }.tint(Color.green500)
                                    }
                            }
                            .onMove(perform: onMoveHandler)
                            .listRowInsets(EdgeInsets())
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .scrollDismissesKeyboard(.immediately)
                        }
                        .padding(.horizontal, -15)
                        .frame(height: CGFloat(items.count) * 75)
                        .listStyle(.plain)
                        .scrollDisabled(true)
                        .listRowSpacing(10)
                        .scrollContentBackground(.hidden)
                        .scrollDismissesKeyboard(.immediately)
                        
                        ShoppingPlaceholderView(storageLocation: nil, onTap: {
                            shopping.addItemWithoutStorageLocation()
                        }).padding(.bottom, 20)
                    }
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 15)
                .frame(maxWidth: .infinity)
                .background(
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture {
                            editingTitleFocus = nil
                        })
                .background(
                    UnevenRoundedRectangle(cornerRadii: RectangleCornerRadii(
                        topLeading: 0,
                        bottomLeading: 10,
                        bottomTrailing: 10,
                        topTrailing: 0))
                        .fill(LinearGradient(
                            stops: [
                                Gradient.Stop(color: .gray500, location: 0),
                                Gradient.Stop(color: .gray700, location: 1),
                            ],
                            startPoint: .leading,
                            endPoint: .trailing))
                )
            }
        }
        .onChange(of: items.count) { oldValue, newValue in
            print("fired: \(oldValue), \(newValue)")
            if newValue == 0, oldValue != 0 {
                isExpanded = false
            }
            
            if newValue > 0, oldValue == 0 {
                isExpanded = true
            }
            
            if newValue > oldValue {
                editingTitleFocus = items.last?.uuid
            }
        }
    }
}
