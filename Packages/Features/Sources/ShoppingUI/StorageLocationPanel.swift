import DesignSystem
import Models
import SharedUI
import SwiftUI

public struct StorageLocationPanel: View {
    @State private var isToggled: Bool = false

    let viewModel: ShoppingViewModel
    let storageLocation: StorageLocation

    public init(storageLocation: StorageLocation, viewModel: ShoppingViewModel) {
        self.storageLocation = storageLocation
        self.viewModel = viewModel
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
                    Image(systemName: "\(viewModel.items(for: storageLocation).count).square.fill")
                        .frame(width: 18).foregroundColor(textColor)

                    if viewModel.items(for: storageLocation).isEmpty {
                        Rectangle().fill(Color.clear).frame(width: 18)
                    } else {
                        Image(systemName: "chevron.down")
                            .rotationEffect(.degrees(isToggled ? -180 : 0))
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
                    bottomLeading: isToggled ? 0 : 10,
                    bottomTrailing: isToggled ? 0 : 10,
                    topTrailing: 10)).fill(LinearGradient(stops: storageLocation.viewGradientStopsReversed, startPoint: .leading, endPoint: .trailing)))
            .onTapGesture {
                //                withAnimation(.easeInOut) {
                if !viewModel.items(for: storageLocation).isEmpty {
                    isToggled.toggle()
                }
                //                }
            }
            //            .transition(.move(edge: .top))
            if isToggled {
                VStack {
                    RoundedRectangle(cornerRadius: 10).fill(Color.black).opacity(0.15).frame(maxWidth: .infinity, maxHeight: 1).offset(y: -10)

                    List {
                        ForEach(viewModel.items(for: storageLocation), id: \.self) { shoppingListItem in
                            ShoppingListItemView(shoppingListItem: shoppingListItem)
                                .draggable(shoppingListItem)
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
                        .listRowInsets(EdgeInsets())
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)

                        // Spacer row for drop target when list has items
                        if !viewModel.items(for: storageLocation).isEmpty {
                            Color.clear
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .listRowInsets(EdgeInsets())
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                                .dropDestination(for: ShoppingListItem.self) { droppedItems, _ in
                                    // Handle drop on bottom empty space (append to end)
                                    guard let droppedItem = droppedItems.first else { return false }

                                    let targetIndex = viewModel.items(for: storageLocation).count

                                    if droppedItem.storageLocation == storageLocation {
                                        // Within-list: move to end
                                        viewModel.moveItem(itemId: droppedItem.id, toIndex: targetIndex, in: storageLocation)
                                    } else {
                                        // Cross-list: move to this location and append to end
                                        viewModel.moveItemToLocation(itemId: droppedItem.id, to: storageLocation, atIndex: targetIndex)
                                    }

                                    return true
                                }
                        }
                    }

                    .frame(height: CGFloat(viewModel.items(for: storageLocation).count) * 75)
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
                            .fill(LinearGradient(stops: storageLocation.viewGradientStopsReversed, startPoint: .leading, endPoint: .trailing))
                            .dropDestination(for: ShoppingListItem.self) { droppedItems, _ in
                                // Handle drop on empty space in list (append to end)
                                guard let droppedItem = droppedItems.first else { return false }

                                if droppedItem.storageLocation == storageLocation {
                                    // Within-list: already at the end, no action needed
                                    return false
                                } else {
                                    // Cross-list: move to this location and append to end
                                    let targetIndex = viewModel.items(for: storageLocation).count
                                    viewModel.moveItemToLocation(itemId: droppedItem.id, to: storageLocation, atIndex: targetIndex)
                                    return true
                                }
                            })
            }
        }
        .onChange(of: viewModel.items(for: storageLocation).count) { oldValue, newValue in
            if newValue == 0 && oldValue != 0 {
                isToggled = false
            }
            
            if newValue > 0 && oldValue == 0 {
                isToggled = true
            }
        }
        .dropDestination(for: ShoppingListItem.self) { droppedItems, _ in
            // Panel-wide drop handler (catches drops not handled by inner zones)
            guard let droppedItem = droppedItems.first else { return false }

            // If dropping within same location and panel is expanded,
            // let the more specific handlers deal with it
            if droppedItem.storageLocation == storageLocation && isToggled {
                return false // Let List/Item handlers process this
            }

            // Otherwise, add to end of list
            let targetIndex = viewModel.items(for: storageLocation).count

            if droppedItem.storageLocation == storageLocation {
                // Within-list move (when collapsed or dropping on non-list area)
                viewModel.moveItem(itemId: droppedItem.id, toIndex: targetIndex, in: storageLocation)
            } else {
                // Cross-list move (always add to end)
                viewModel.moveItemToLocation(itemId: droppedItem.id, to: storageLocation, atIndex: targetIndex)
            }

            return true
        }
    }
}
