import DesignSystem
import SwiftUI

public struct Suggestion: View {
    let icon: String
    let iconColor: Color
    let text: String
    let textColor: Color
    let alignment: VerticalAlignment

    public init(icon: String, iconColor: Color, text: String, textColor: Color, alignment: VerticalAlignment = VerticalAlignment.center) {
        self.icon = icon
        self.iconColor = iconColor
        self.text = text
        self.textColor = textColor
        self.alignment = alignment
    }

    public var body: some View {
        GridRow(alignment: alignment) {
            Image(systemName: icon).fontWeight(.bold)
                .foregroundStyle(iconColor)
                .font(.system(size: 32))
            Text(text)
                .font(.callout)
                .foregroundStyle(textColor)
                .multilineTextAlignment(.center)
                .lineLimit(2...2)

            Spacer()
        }
    }
}
