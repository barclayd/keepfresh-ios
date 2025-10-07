import SwiftUI

public struct BottomActionButton: View {
    private let title: String
    private let action: () async throws -> Void
    private let safeAreaInsets: EdgeInsets

    public init(
        title: String,
        safeAreaInsets: EdgeInsets,
        action: @escaping () async throws -> Void
    ) {
        self.title = title
        self.safeAreaInsets = safeAreaInsets
        self.action = action
    }

    private var cornerRadius: CGFloat {
        safeAreaInsets.bottom > 20 ? 40 : 0
    }

    public var body: some View {
        ZStack(alignment: .bottom) {
            UnevenRoundedRectangle(
                cornerRadii: RectangleCornerRadii(
                    topLeading: 0,
                    bottomLeading: cornerRadius,
                    bottomTrailing: cornerRadius,
                    topTrailing: 0
                )
            )
            .fill(.white200)
            .shadow(
                color: Color(.sRGBLinear, white: 0, opacity: 0.25),
                radius: 4,
                x: 0,
                y: -4
            )
            .frame(height: 80)

            Button {
                Task {
                    try await action()
                }
            } label: {
                Text(title)
                    .font(.title2)
                    .foregroundStyle(.blue600)
                    .fontWeight(.medium)
                    .padding()
                    .padding(.vertical, safeAreaInsets.bottom > 20 ? 0 : 10)
            }
        }
    }
}
