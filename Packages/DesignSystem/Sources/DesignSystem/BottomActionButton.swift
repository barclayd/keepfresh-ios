import SwiftUI

public struct BottomActionButton: View {
    private let title: String
    private let action: () async throws -> Void
    private let safeAreaInsets: EdgeInsets

    public init(
        title: String,
        safeAreaInsets: EdgeInsets,
        action: @escaping () async throws -> Void)
    {
        self.title = title
        self.safeAreaInsets = safeAreaInsets
        self.action = action
    }

    private var cornerRadius: CGFloat {
        safeAreaInsets.bottom > 20 ? 40 : 0
    }

    public var body: some View {
        ZStack(alignment: .bottom) {
            LiquidGlassBackground(cornerRadius: cornerRadius)

            ActionButton(
                title: title,
                safeAreaInsets: safeAreaInsets,
                action: action)
        }
    }
}

public struct BottomActionCustomButton: View {
    @State private var markAsDonePressed = false

    private let title: String
    private let action: () async throws -> Void
    private let safeAreaInsets: EdgeInsets

    public init(
        title: String,
        safeAreaInsets: EdgeInsets,
        action: @escaping () async throws -> Void)
    {
        self.title = title
        self.safeAreaInsets = safeAreaInsets
        self.action = action
    }

    private var cornerRadius: CGFloat {
        safeAreaInsets.bottom > 20 ? 40 : 0
    }

    public var body: some View {
        ZStack(alignment: .center) {
            LiquidGlassBackground(cornerRadius: cornerRadius, height: 120)

            Button(action: {
                markAsDonePressed.toggle()
//                showSheet = .remove
            }) {
                HStack(spacing: 10) {
                    Image(systemName: "cart.fill.badge.plus")
                        .font(.system(size: 18))
                        .frame(width: 20, alignment: .center)
                    Text(title)
                        .font(.headline)
                        .frame(width: 175, alignment: .center)
                }
                .foregroundStyle(.blue600)
                .fontWeight(.bold)
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.green300))
            }
            .sensoryFeedback(.impact(flexibility: .soft, intensity: 0.7), trigger: markAsDonePressed)
            .padding(.horizontal, 20)
        }
    }
}

// MARK: - Liquid Glass Background

public struct LiquidGlassBackground: View {
    let cornerRadius: CGFloat

    let height: CGFloat

    public init(cornerRadius: CGFloat, height: CGFloat = 80) {
        self.cornerRadius = cornerRadius
        self.height = height
    }

    public var body: some View {
        Color.clear
            .frame(height: height)
            .glassEffect(
                .regular.interactive(),
                in: UnevenRoundedRectangle(
                    cornerRadii: RectangleCornerRadii(
                        topLeading: 0,
                        bottomLeading: cornerRadius,
                        bottomTrailing: cornerRadius,
                        topTrailing: 0)))
            .shadow(
                color: Color(.sRGBLinear, white: 0, opacity: 0.08),
                radius: 12,
                x: 0,
                y: -4)
            .shadow(
                color: Color(.sRGBLinear, white: 0, opacity: 0.04),
                radius: 24,
                x: 0,
                y: -8)
    }
}

private struct ActionButton: View {
    let title: String
    let safeAreaInsets: EdgeInsets
    let action: () async throws -> Void

    @State private var isProcessing = false

    private var verticalPadding: CGFloat {
        safeAreaInsets.bottom > 20 ? 0 : 10
    }

    var body: some View {
        Button {
            guard !isProcessing else { return }

            isProcessing = true
            Task {
                do {
                    try await action()
                } catch {}
                isProcessing = false
            }
        } label: {
            ButtonLabel(
                title: title,
                isProcessing: isProcessing)
        }
        .disabled(isProcessing)
        .padding(.vertical, verticalPadding)
        .sensoryFeedback(.impact, trigger: isProcessing)
    }
}

private struct ButtonLabel: View {
    let title: String
    let isProcessing: Bool

    var body: some View {
        HStack(spacing: 12) {
            Text(title)
                .font(.title2)
                .foregroundStyle(.blue600)
                .fontWeight(.medium)
                .opacity(isProcessing ? 0.6 : 1.0)

            if isProcessing {
                ProgressView()
                    .tint(.blue600)
            }
        }
        .padding()
        .animation(.easeInOut(duration: 0.2), value: isProcessing)
    }
}
