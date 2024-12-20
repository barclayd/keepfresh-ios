import SwiftUI

public struct CustomSpacingLabel: LabelStyle {
    let spacing: Double

    public init(spacing: Double = 0.0) {
        self.spacing = spacing
    }

    public func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: spacing) {
            configuration.icon
            configuration.title
        }
    }
}

public extension LabelStyle where Self == CustomSpacingLabel {
    static func customSpacing(_ spacing: Double) -> Self {
        CustomSpacingLabel(spacing: spacing)
    }
}
