import DesignSystem
import SwiftUI

@MainActor
public struct CheckToggleStyle: ToggleStyle {
    @Environment(\.isEnabled) var isEnabled

    public var customColor: Color?

    public init(customColor: Color? = nil) {
        self.customColor = customColor
    }

    public func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            Label {} icon: {
                Image(systemName: configuration.isOn ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 21))
                    .fontWeight(.bold)
                    .foregroundStyle(customColor ?? .blue700)
                    .accessibility(label: Text(configuration.isOn ? "Checked" : "Unchecked"))
                    .imageScale(.large)
            }
        }
    }
}
