import DesignSystem
import Models
import SwiftData
import SwiftUI

// MARK: - Genmoji Confetti Cache

/// Static cache for genmoji images used in confetti animation.
/// Must be pre-populated before confetti triggers to ensure synchronous rendering.
@MainActor
public enum GenmojiConfettiCache {
    public static var images: [String: UIImage] = [:]

    /// Preload genmoji images from SwiftData cache into memory.
    /// Call this before confetti can be triggered.
    public static func preload(names: [String], modelContext: ModelContext) {
        for name in names {
            guard images[name] == nil else { continue }

            let descriptor = FetchDescriptor<GenmojiCache>(
                predicate: #Predicate { $0.name == name })

            if let cached = try? modelContext.fetch(descriptor).first,
               let image = UIImage(data: cached.imageData) {
                images[name] = image
            }
        }
    }
}

/// Synchronous genmoji view for confetti animation.
/// NO @State, NO .task - just reads from pre-populated cache.
private struct SyncGenmojiView: View {
    let name: String
    let size: CGFloat

    var body: some View {
        if let image = GenmojiConfettiCache.images[name] {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
        } else {
            // Fallback: colored circle if not cached
            Circle()
                .fill(.orange)
                .frame(width: size, height: size)
        }
    }
}

// MARK: - Confetti Types

public enum ConfettiType: CaseIterable, Hashable {
    public enum Shape: CaseIterable {
        case circle, triangle, rectangle
    }

    case shape(Shape)
    case text(String)
    case genmoji(String)

    public static var allCases: [ConfettiType] {
        Shape.allCases.map { .shape($0) }
    }

    @MainActor @ViewBuilder
    func view(color: Color, size: CGFloat) -> some View {
        switch self {
        case .shape(.circle):
            Circle()
                .fill(color)
                .frame(width: size, height: size)
        case .shape(.triangle):
            Triangle()
                .fill(color)
                .frame(width: size, height: size)
        case .shape(.rectangle):
            RoundedRectangle(cornerRadius: 2)
                .fill(color)
                .frame(width: size, height: size * 0.6)
        case .text(let text):
            Text(text)
                .font(.system(size: size))
        case .genmoji(let name):
            SyncGenmojiView(name: name, size: size)
        }
    }
}

private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

private struct ConfettiAnimationView: View {
    let confettiView: AnyView
    let spinDirX: CGFloat
    let spinDirZ: CGFloat

    @State private var move = false
    @State private var xSpeed = Double.random(in: 0.5...2.2)
    @State private var zSpeed = Double.random(in: 0.5...2.2)
    @State private var anchor = CGFloat.random(in: 0...1).rounded()

    var body: some View {
        confettiView
            .rotation3DEffect(.degrees(move ? 360 : 0), axis: (x: spinDirX, y: 0, z: 0))
            .animation(.linear(duration: xSpeed).repeatCount(10, autoreverses: false), value: move)
            .rotation3DEffect(.degrees(move ? 360 : 0), axis: (x: 0, y: 0, z: spinDirZ), anchor: UnitPoint(x: anchor, y: anchor))
            .animation(.linear(duration: zSpeed).repeatForever(autoreverses: false), value: move)
            .onAppear { move = true }
    }
}

private struct ConfettiParticleView: View {
    let confettiType: ConfettiType
    let color: Color
    let size: CGFloat
    let openingAngle: Angle
    let closingAngle: Angle
    let radius: CGFloat
    let rainHeight: CGFloat

    @State private var location = CGPoint.zero
    @State private var opacity: Double = 0

    private let spinDirX: CGFloat = [-1, 1].randomElement()!
    private let spinDirZ: CGFloat = [-1, 1].randomElement()!

    private var explosionDuration: Double { Double(radius / 1300) }
    private var rainDuration: Double { Double((rainHeight + radius) / 200) }

    var body: some View {
        ConfettiAnimationView(
            confettiView: AnyView(confettiType.view(color: color, size: size)),
            spinDirX: spinDirX,
            spinDirZ: spinDirZ
        )
        .offset(x: location.x, y: location.y)
        .opacity(opacity)
        .onAppear {
            let randomAngle = CGFloat.random(in: openingAngle.degrees...closingAngle.degrees)
            let distance = pow(CGFloat.random(in: 0.01...1), 2.0 / 7.0) * radius
            let variation = CGFloat.random(in: 0...0.5)

            withAnimation(.timingCurve(0.1, 0.8, 0, 1, duration: 0.2 + explosionDuration + variation)) {
                opacity = 1.0
                location.x = distance * cos(deg2rad(randomAngle))
                location.y = -distance * sin(deg2rad(randomAngle))
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + explosionDuration * 0.1) {
                withAnimation(.timingCurve(0.12, 0, 0.39, 0, duration: rainDuration)) {
                    location.y += rainHeight
                    opacity = 0
                }
            }
        }
    }

    private func deg2rad(_ degrees: CGFloat) -> CGFloat {
        degrees * .pi / 180
    }
}

private struct ConfettiCannon<T: Equatable>: View {
    @Binding var trigger: T
    let confettis: [ConfettiType]
    let colors: [Color]
    let num: Int
    let confettiSize: CGFloat
    let rainHeight: CGFloat
    let openingAngle: Angle
    let closingAngle: Angle
    let radius: CGFloat

    @State private var animate: [UUID] = []
    @State private var finishedCount = 0
    @State private var didAppear = false

    private var animationDuration: Double {
        Double(radius / 1300) + Double((rainHeight + radius) / 200)
    }

    var body: some View {
        ZStack {
            ForEach(animate.dropFirst(finishedCount), id: \.self) { _ in
                ForEach(0..<num, id: \.self) { _ in
                    ConfettiParticleView(
                        confettiType: (confettis.isEmpty ? ConfettiType.allCases : confettis).randomElement()!,
                        color: colors.randomElement()!,
                        size: CGFloat.random(in: confettiSize...confettiSize * 1.5),
                        openingAngle: openingAngle,
                        closingAngle: closingAngle,
                        radius: radius,
                        rainHeight: rainHeight
                    )
                }
            }
        }
        .onAppear { didAppear = true }
        .onChange(of: trigger) { _, _ in
            guard didAppear else { return }
            animate.append(UUID())
            DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
                finishedCount += 1
            }
        }
    }
}

private struct ConfettiModifier<T: Equatable>: ViewModifier {
    @Binding var trigger: T
    let confettis: [ConfettiType]

    @State private var containerHeight: CGFloat = 800

    func body(content: Content) -> some View {
        content
            .onGeometryChange(for: CGFloat.self) { proxy in
                proxy.size.height
            } action: { newHeight in
                containerHeight = newHeight
            }
            .overlay(alignment: .bottom) {
                ConfettiCannon(
                    trigger: $trigger,
                    confettis: confettis,
                    colors: [.red, .orange, .yellow, .green, .blue, .purple],
                    num: 40,
                    confettiSize: 10,
                    rainHeight: containerHeight * 1.25,
                    openingAngle: .degrees(60),
                    closingAngle: .degrees(120),
                    radius: containerHeight
                )
                .allowsHitTesting(false)
            }
            .sensoryFeedback(.success, trigger: trigger)
    }
}

public extension View {
    func confetti<T: Equatable>(trigger: Binding<T>, confettis: [ConfettiType] = []) -> some View {
        modifier(ConfettiModifier(trigger: trigger, confettis: confettis))
    }
}
