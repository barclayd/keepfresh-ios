import Intelligence
import Models
import Router
import SharedUI
import SwiftUI

public struct OtherShoppingItemView: View {
    @Environment(Router.self) var router
    
    @State private var status: ShoppingItemStatus = .created
    @State private var shoppingItem: ShoppingItem
    
    @FocusState.Binding var editingTitleFocus: UUID?
    
    public init(shoppingItem: ShoppingItem, editingTitleFocus: FocusState<UUID?>.Binding) {
        self.shoppingItem = shoppingItem
        self._editingTitleFocus = editingTitleFocus
    }

    private var isSetToComplete: Binding<Bool> {
        Binding(
            get: {
                status == .pendingCompletion || status == .completed
            },
            set: { newValue in
                if newValue {
                    status = .pendingCompletion
                }
            })
    }
    
    public var body: some View {
        HStack(spacing: 0) {
            HStack {
                HStack {
                    EditableText(text: $shoppingItem.title, editingTitleFocus: $editingTitleFocus, shoppingItemUUID: shoppingItem.uuid)
                        .font(.headline)
                        .foregroundStyle(.blue800)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .lineLimit(1)
                        
                    
                    Spacer()
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    editingTitleFocus = shoppingItem.uuid
                }
                
                Toggle("Selected Expiry Date", isOn: isSetToComplete)
                    .toggleStyle(CheckToggleStyle(customColor: .gray700))
                    .labelsHidden()
            }
            .frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 5)
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 9)
        .background(.white100)
        .opacity(status == .created ? 1 : 0.25)
        .background(.white100)
        .cornerRadius(22)
        .frame(maxWidth: .infinity, alignment: .center)
        .shadow(color: .shadow, radius: 2, x: 0, y: 4)
        .contentShape(.dragPreview, RoundedRectangle(cornerRadius: 22))
    }
}
