import Environment
import SwiftUI

struct EditableText: View {
    @Environment(Shopping.self) var shopping
    
    @Binding var text: String?
    
    @FocusState.Binding var editingTitleFocus: UUID?
    
    let shoppingItemUUID: UUID
    
    var isFocused: Bool {
        editingTitleFocus == shoppingItemUUID
    }
    
    private var textBinding: Binding<String> {
        Binding(
            get: { text ?? "" },
            set: { text = $0.isEmpty ? nil : $0 }
        )
    }
    
    var body: some View {
        ZStack(alignment: .leading) {
            Text(text ?? "")
                .opacity(isFocused ? 0 : 1)
            
            TextField("Shopping list item", text: textBinding)
                .tint(.gray700)
                .labelsHidden()
                .opacity(isFocused ? 1 : 0)
                .focused($editingTitleFocus, equals: shoppingItemUUID)
                .onSubmit {
                    withAnimation {
                        guard let currentText = text, !currentText.isEmpty else {
                            shopping.deleteItemByUUID(uuid: shoppingItemUUID)
                            editingTitleFocus = nil
                            return
                        }
                        
                        shopping.updateItemByUUID(uuid: shoppingItemUUID, title: currentText)
                        editingTitleFocus = nil
                    }
                }
        }
        .onTapGesture {
            if !isFocused {
                editingTitleFocus = shoppingItemUUID
            }
        }
        .onChange(of: isFocused) { oldValue, newValue in
            if !newValue, let text, !text.isEmpty {
                shopping.updateItemByUUID(uuid: shoppingItemUUID, title: text)
            }
            if !newValue, text == nil {
                shopping.deleteItemByUUID(uuid: shoppingItemUUID)
            }
        }
    }
}
