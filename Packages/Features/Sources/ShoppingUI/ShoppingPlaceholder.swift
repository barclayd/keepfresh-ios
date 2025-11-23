import DesignSystem
import Models
import Router
import SwiftUI

public struct ShoppingPlaceholderView: View {
    let storageLocation: StorageLocation?
    let onTap: () -> Void

    public var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: "cart.fill.badge.plus").resizable()
                    .frame(width: 24).foregroundColor(storageLocation?.panelForegroundColor.0 ?? .white200).fontWeight(.bold)
                Text("Tap to add to shopping list").foregroundStyle(storageLocation?.panelForegroundColor.1 ?? .white200).font(.caption)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 20)
            .padding(.vertical, 30)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 11)
                .stroke(
                    (storageLocation?.panelForegroundColor.2 ?? .black800).opacity(0.2),
                    style: StrokeStyle(
                        lineWidth: 1,
                        dash: [11, 6])))
    }
}
