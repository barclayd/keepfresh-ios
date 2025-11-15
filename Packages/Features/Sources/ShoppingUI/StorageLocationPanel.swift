import DesignSystem
import Environment
import Models
import SharedUI
import SwiftUI

public struct StorageLocationPanel: View {
    @Environment(Shopping.self) var shopping
    @State private var isExpanded: Bool = true

    let storageLocation: StorageLocation

    private var items: [ShoppingItem] {
        shopping.itemsByStorageLocation[storageLocation] ?? []
    }

    public init(storageLocation: StorageLocation) {
        self.storageLocation = storageLocation
    }

    private func handleItemMove(sourceIndices: IndexSet, destinationIndex: Int) {
        guard let sourceIndex = sourceIndices.first else { return }
        guard sourceIndex < items.count else { return }
        let itemId = items[sourceIndex].id
        shopping.moveItem(itemId: itemId, toIndex: destinationIndex, in: storageLocation)
    }

    private var onMoveHandler: (IndexSet, Int) -> Void {
        handleItemMove
    }

    var textColor: Color {
        storageLocation == .freezer ? .white200 : .blue800
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
                    Image(systemName: "\(items.count).square.fill")
                        .frame(width: 18).foregroundColor(textColor)

                    if items.isEmpty {
                        Rectangle().fill(Color.clear).frame(width: 18)
                    } else {
                        Image(systemName: "chevron.down")
                            .rotationEffect(.degrees(isExpanded ? -180 : 0))
                            .frame(width: 18).foregroundColor(textColor)
                    }

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
                    stops: storageLocation.viewGradientStopsReversed,
                    startPoint: .leading,
                    endPoint: .trailing)))
            .onTapGesture {
                withAnimation(.easeInOut) {
                    if !items.isEmpty {
                        isExpanded.toggle()
                    }
                }
            }
            //            .transition(.move(edge: .top))
            if isExpanded {
                VStack {
                    RoundedRectangle(cornerRadius: 10).fill(Color.black).opacity(0.15).frame(maxWidth: .infinity, maxHeight: 1)
                        .offset(y: -10)

                    List {
                        ForEach(items, id: \.self) { shoppingItem in
                            ShoppingItemView(shoppingItem: shoppingItem)
                                .draggable(shoppingItem)
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {} label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                    Button {} label: {
                                        Label("Flag", systemImage: "flag")
                                    }
                                }
                        }
                        .onMove(perform: onMoveHandler)
                        .listRowInsets(EdgeInsets())
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)

                        if !items.isEmpty {
                            Color.clear
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .listRowInsets(EdgeInsets())
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                                .dropDestination(for: ShoppingItem.self) { droppedItems, _ in
                                    guard let droppedItem = droppedItems.first else { return false }

                                    let targetIndex = items.count

                                    if droppedItem.storageLocation == storageLocation {
                                        shopping.moveItem(itemId: droppedItem.id, toIndex: targetIndex, in: storageLocation)
                                    } else {
                                        shopping.moveItemToLocation(itemId: droppedItem.id, to: storageLocation, atIndex: targetIndex)
                                    }

                                    return true
                                }
                        }
                    }

                    .frame(height: CGFloat(items.count) * 75)
                    .listStyle(.plain)
                    .scrollDisabled(true)
                    .listRowSpacing(10)
                    .scrollContentBackground(.hidden)

                }.padding(.vertical, 10).padding(.horizontal, 15).frame(maxWidth: .infinity)
                    .background(
                        UnevenRoundedRectangle(cornerRadii: RectangleCornerRadii(
                            topLeading: 0,
                            bottomLeading: 10,
                            bottomTrailing: 10,
                            topTrailing: 0))
                            .fill(LinearGradient(
                                stops: storageLocation.viewGradientStopsReversed,
                                startPoint: .leading,
                                endPoint: .trailing))
                            .dropDestination(for: ShoppingItem.self) { droppedItems, _ in
                                // Handle drop on empty space in list (append to end)
                                guard let droppedItem = droppedItems.first else { return false }

                                if droppedItem.storageLocation == storageLocation {
                                    // Within-list: already at the end, no action needed
                                    return false
                                } else {
                                    // Cross-list: move to this location and append to end
                                    let targetIndex = items.count
                                    shopping.moveItemToLocation(itemId: droppedItem.id, to: storageLocation, atIndex: targetIndex)
                                    return true
                                }
                            })
            }
        }
        .onAppear {
            if items.isEmpty {
                isExpanded = false
            }
        }
        .onChange(of: items.count) { oldValue, newValue in
            if newValue == 0, oldValue != 0 {
                isExpanded = false
            }

            if newValue > 0, oldValue == 0 {
                isExpanded = true
            }
        }
        .dropDestination(for: ShoppingItem.self) { droppedItems, _ in
            // Panel-wide drop handler (catches drops not handled by inner zones)
            guard let droppedItem = droppedItems.first else { return false }

            // If dropping within same location and panel is expanded,
            // let the more specific handlers deal with it
            if droppedItem.storageLocation == storageLocation, isExpanded {
                return false // Let List/Item handlers process this
            }

            // Otherwise, add to end of list
            let targetIndex = items.count

            if droppedItem.storageLocation == storageLocation {
                // Within-list move (when collapsed or dropping on non-list area)
                shopping.moveItem(itemId: droppedItem.id, toIndex: targetIndex, in: storageLocation)
            } else {
                // Cross-list move (always add to end)
                shopping.moveItemToLocation(itemId: droppedItem.id, to: storageLocation, atIndex: targetIndex)
            }

            return true
        }
    }
}
