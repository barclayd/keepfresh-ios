import DesignSystem
import Models
import SwiftUI
import WidgetKit

/// Light accents retain the app's storage colours on these dark surfaces.
enum ShoppingActivityStyle {
    static let background = Color(red: 16 / 255, green: 23 / 255, blue: 30 / 255)
    static let secondary = Color(red: 178 / 255, green: 191 / 255, blue: 206 / 255)
    static let complete = Color(red: 207 / 255, green: 246 / 255, blue: 209 / 255)

    static func accent(for location: StorageLocation?) -> Color {
        switch location {
        case .pantry: Color(red: 233 / 255, green: 192 / 255, blue: 146 / 255)
        case .fridge: Color(red: 144 / 255, green: 201 / 255, blue: 255 / 255)
        case .freezer: Color(red: 183 / 255, green: 224 / 255, blue: 255 / 255)
        case nil: Color(red: 203 / 255, green: 213 / 255, blue: 225 / 255)
        }
    }

    static func accent(for state: ShoppingActivityAttributes.ContentState) -> Color {
        state.isComplete ? complete : accent(for: state.current?.storageLocation)
    }
}

struct ShoppingActivityCard: View {
    let state: ShoppingActivityAttributes.ContentState
    let sessionID: String
    @Environment(\.isLuminanceReduced) private var isLuminanceReduced
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    private var accent: Color { ShoppingActivityStyle.accent(for: state) }

    var body: some View {
        ShoppingActivityContent(state: state, sessionID: sessionID, isIsland: false)
            .padding(14)
            .background {
                if isLuminanceReduced {
                    Color.black
                } else {
                    ShoppingActivityStyle.background
                    if !reduceTransparency {
                        RadialGradient(
                            colors: [accent.opacity(0.27), .clear],
                            center: .topLeading,
                            startRadius: 0,
                            endRadius: 290)
                    }
                }
            }
    }
}

/// Keeping the product and action in one row gives them a shared centre line.
/// The Island owns the camera-safe metadata region; the Lock Screen owns it here.
struct ShoppingActivityContent: View {
    let state: ShoppingActivityAttributes.ContentState
    let sessionID: String
    let isIsland: Bool
    @ScaledMetric(relativeTo: .title3) private var titleSize: CGFloat = 23

    private var accent: Color { ShoppingActivityStyle.accent(for: state) }
    private var artworkSize: CGFloat { isIsland ? 44 : 48 }
    private var columnSpacing: CGFloat { isIsland ? 10 : 12 }

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: columnSpacing) {
                ActivityArtwork(item: state.current, size: artworkSize, tint: accent)
                VStack(alignment: .leading, spacing: 4) {
                    Text(state.current?.title ?? (state.isComplete ? "Basket ready" : "Your list is clear"))
                        .font(.system(size: min(titleSize, 32) - (isIsland ? 2 : 0), weight: .semibold))
                        .tracking(-0.4)
                        .foregroundStyle(.white)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                        .fixedSize(horizontal: false, vertical: true)
                    if !isIsland {
                        ActivityMetadata(item: state.current, tint: accent)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityElement(children: .combine)
                if let current = state.current {
                    CollectButton(item: current, sessionID: sessionID, tint: accent)
                } else {
                    ReviewBasketButton(tint: accent)
                }
            }
            if let next = state.next {
                NextShoppingItem(
                    item: next,
                    currentLocation: state.current?.storageLocation,
                    artworkColumnWidth: artworkSize,
                    columnSpacing: columnSpacing,
                    isIsland: isIsland)
                    .padding(.top, 5)
            }
            ShoppingProgress(state: state, tint: accent)
                .padding(.top, isIsland ? 12 : 11)
                .padding(.horizontal, 3)
        }
        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
    }
}

struct ActivityMetadata: View {
    let item: ShoppingActivityAttributes.Item?
    let tint: Color
    var isIsland = false

    private var amount: String? {
        guard let item, let brand = item.brand else { return nil }
        let prefix = brand + " • "
        return item.detail.hasPrefix(prefix) ? String(item.detail.dropFirst(prefix.count)) : nil
    }

    var body: some View {
        if item?.detail.isEmpty != true {
            HStack(spacing: 4) {
                if let brand = item?.brand {
                    Text(brand).foregroundStyle(tint).lineLimit(1)
                    if let amount {
                        Text("•").fixedSize()
                        Text(amount).lineLimit(1).fixedSize()
                    }
                } else {
                    Text(item?.detail ?? "Review").lineLimit(1)
                }
            }
            .font(.system(size: isIsland ? 11 : 12, weight: .medium))
            .foregroundStyle(ShoppingActivityStyle.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(item?.detail ?? "Review")
        }
    }
}

struct NextShoppingItem: View {
    let item: ShoppingActivityAttributes.Item
    let currentLocation: StorageLocation?
    let artworkColumnWidth: CGFloat
    let columnSpacing: CGFloat
    let isIsland: Bool

    private var changesCategory: Bool { item.storageLocation != currentLocation }

    var body: some View {
        HStack(spacing: columnSpacing) {
            ActivityArtwork(item: item, size: 13, tint: ShoppingActivityStyle.accent(for: item.storageLocation))
                .frame(width: artworkColumnWidth)
            HStack(spacing: 6) {
                Text("Next · \(item.title)")
                    .font(.system(size: isIsland ? 12 : 13, weight: .medium))
                    .foregroundStyle(ShoppingActivityStyle.secondary)
                    .lineLimit(1)
                if changesCategory {
                    Image(systemName: item.storageLocation?.icon ?? "bag")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(ShoppingActivityStyle.accent(for: item.storageLocation))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(minHeight: 18)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Next item: \(item.title)")
        .accessibilityValue(changesCategory ? "\(item.storageLocation?.rawValue ?? "Other items") section" : "")
    }
}

struct ActivityArtwork: View {
    let item: ShoppingActivityAttributes.Item?
    let size: CGFloat
    let tint: Color
    @Environment(\.isLuminanceReduced) private var isLuminanceReduced

    var body: some View {
        Group {
            if let name = item?.imageName, let url = ShoppingActivityImages.url(for: name),
               let data = try? Data(contentsOf: url), let image = UIImage(data: data)
            {
                Image(uiImage: image).resizable().scaledToFit()
                    .saturation(isLuminanceReduced ? 0.35 : 1)
            } else {
                Image(systemName: item == nil ? "basket" : item?.storageLocation?.icon ?? "bag")
                    .resizable().scaledToFit()
                    .padding(size * 0.16)
                    .foregroundStyle(tint)
            }
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}

struct ShoppingProgress: View {
    let state: ShoppingActivityAttributes.ContentState
    let tint: Color
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(spacing: 6) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule().fill(.white.opacity(0.11))
                    Capsule().fill(tint)
                        .frame(width: geometry.size.width * min(1, max(0, state.progress)))
                }
            }
            .frame(height: 5)
            Text("\(state.collectedCount)/\(state.totalCount) items")
                .font(.system(size: 11, weight: .medium).monospacedDigit())
                .foregroundStyle(ShoppingActivityStyle.secondary)
                .contentTransition(reduceMotion ? .identity : .numericText())
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Shopping progress")
        .accessibilityValue("\(state.collectedCount) of \(state.totalCount) items in basket")
    }
}
