import SwiftUI

public extension View {
    @ViewBuilder
    func redacted(if condition: Bool) -> some View {
        redacted(reason: condition ? .placeholder : [])
    }

    func redactedShimmer(when isLoading: Bool) -> some View {
        Group {
            if isLoading {
                self
                    .redacted(reason: .placeholder)
                    .modifier(Shimmer())
            } else {
                self
            }
        }
    }
}

struct Shimmer: ViewModifier {
    @State private var isAnimating = false

    func body(content: Content) -> some View {
        content
            .mask(
                LinearGradient(
                    gradient: .init(colors: [
                        .black.opacity(0.4),
                        .black,
                        .black.opacity(0.4),
                    ]),
                    startPoint: isAnimating ? .init(x: -0.3, y: -0.3) : .init(x: 1, y: 1),
                    endPoint: isAnimating ? .init(x: 0, y: 0) : .init(x: 1.3, y: 1.3)))
            .animation(.linear(duration: 1.5).repeatForever(autoreverses: false), value: isAnimating)
            .onAppear { isAnimating = true }
            .disabled(isAnimating)
    }
}
