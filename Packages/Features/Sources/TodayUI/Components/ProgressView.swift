import SwiftUI

struct ProgressRing: View {
    let progress: Double
    let lineWidth: CGFloat
    let backgroundColor: Color
    let foregroundColor: Color

    @State private var animatedProgress: Double = 0

    init(
        progress: Double,
        lineWidth: CGFloat = 5,
        backgroundColor: Color = Color.gray.opacity(0.2),
        foregroundColor: Color = .blue)
    {
        self.progress = min(max(progress, 0), 1)
        self.lineWidth = lineWidth
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    backgroundColor,
                    lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    foregroundColor,
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 2.0), value: animatedProgress)
        }
        .onAppear {
            Task {
                do {
                    try await Task.sleep(for: .seconds(0.5))
                    animatedProgress = progress

                } catch {}
            }
        }
        .onChange(of: progress) { _, newValue in
            animatedProgress = newValue
        }
    }
}
