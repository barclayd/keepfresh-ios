import Environment
import Intelligence
import Models
import Router
import SharedUI
import SwiftUI

public struct OtherShoppingItemView: View {
    @Environment(Router.self) var router
    @Environment(Shopping.self) var shopping

    @State private var status: ShoppingItemStatus = .created
    @State private var shoppingItem: ShoppingItem
    @State private var verticalOffset: CGFloat = 0
    @State private var fadeOpacity: CGFloat = 1

    @State private var dismissTask: Task<Void, Never>?

    @FocusState.Binding var editingTitleFocus: UUID?

    public init(shoppingItem: ShoppingItem, editingTitleFocus: FocusState<UUID?>.Binding) {
        self.shoppingItem = shoppingItem
        _editingTitleFocus = editingTitleFocus
    }

    private var isSetToComplete: Binding<Bool> {
        Binding(
            get: {
                status == .pendingCompletion || status == .completed
            },
            set: { newValue in
                if newValue {
                    status = .pendingCompletion
                    triggerDismissAnimation()
                } else {
                    dismissTask?.cancel()
                    status = .created
                }
            })
    }

    private func triggerDismissAnimation() {
        dismissTask?.cancel()

        dismissTask = Task {
            try? await Task.sleep(for: .seconds(2))

            guard !Task.isCancelled else {
                return
            }

            withAnimation(.smooth(duration: 0.6)) {
                verticalOffset = -100
                fadeOpacity = 0
            }

            try? await Task.sleep(for: .seconds(0.6))

            status = .completed

            shopping.updateItemWithoutStorageLocationStatus(uuid: shoppingItem.uuid, to: .completed)
        }
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
                    .highPriorityGesture(TapGesture().onEnded {
                        isSetToComplete.wrappedValue.toggle()
                    })
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
        .offset(y: verticalOffset)
        .opacity(fadeOpacity)
    }
}
