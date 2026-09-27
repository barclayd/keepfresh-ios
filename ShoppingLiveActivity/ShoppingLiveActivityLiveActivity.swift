import ActivityKit
import Models
import SwiftUI
import WidgetKit

struct ShoppingLiveActivityLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: ShoppingActivityAttributes.self) { context in
            ShoppingActivityCard(state: context.state, sessionID: context.attributes.sessionID)
                .activityBackgroundTint(.clear)
                .activitySystemActionForegroundColor(.white)
                .widgetURL(context.state.isComplete ? ShoppingActivityController.basketURL : ShoppingActivityController.shoppingURL)
        } dynamicIsland: { context in
            let accent = ShoppingActivityStyle.accent(for: context.state)
            return DynamicIsland {
                // Let WidgetKit reserve the camera area instead of guessing its dimensions.
                DynamicIslandExpandedRegion(.leading) {
                    ActivityMetadata(item: context.state.current, tint: accent, isIsland: true)
                        .padding(.leading, 12)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    ShoppingActivityContent(state: context.state, sessionID: context.attributes.sessionID, isIsland: true)
                        .fixedSize(horizontal: false, vertical: true)
                }
            } compactLeading: {
                ActivityArtwork(item: context.state.current, size: 25, tint: accent)
            } compactTrailing: {
                Group {
                    if context.state.isComplete {
                        Image(systemName: "checkmark")
                    } else {
                        Text("\(context.state.remainingCount) left")
                            .monospacedDigit()
                    }
                }
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(accent)
                .accessibilityLabel(
                    context.state
                        .isComplete ? "Everything is in your basket" : "\(context.state.remainingCount) items left")
            } minimal: {
                ShoppingActivityRing(state: context.state, tint: accent)
            }
            .contentMargins(.vertical, 14, for: .expanded)
            .contentMargins(.horizontal, 20, for: .expanded)
            .widgetURL(context.state.isComplete ? ShoppingActivityController.basketURL : ShoppingActivityController.shoppingURL)
            .keylineTint(accent)
        }
    }
}

private struct ShoppingActivityRing: View {
    let state: ShoppingActivityAttributes.ContentState
    let tint: Color

    var body: some View {
        ZStack {
            Circle().stroke(.white.opacity(0.2), lineWidth: 2)
            Circle().trim(from: 0, to: min(1, max(0, state.progress)))
                .stroke(tint, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Group {
                if state.isComplete {
                    Image(systemName: "checkmark")
                } else {
                    Text("\(state.remainingCount)")
                        .monospacedDigit()
                        .minimumScaleFactor(0.65)
                        .lineLimit(1)
                        .padding(.horizontal, 3)
                }
            }
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(tint)
        }
        .frame(width: 25, height: 25)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(state.isComplete ? "Everything is in your basket" : "\(state.remainingCount) items left")
        .accessibilityValue("\(state.collectedCount) of \(state.totalCount) items in basket")
    }
}

#if DEBUG
    private extension ShoppingActivityAttributes {
        static var preview: Self { .init(sessionID: "preview", startedAt: .now) }

        @MainActor
        static func sample(
            _ location: StorageLocation? = .fridge,
            lastItem: Bool = false,
            complete: Bool = false,
            sameCategory: Bool = false,
            longTitle: Bool = false) -> ContentState
        {
            // Preview-only copies of the app's artwork exercise the same shared cache as a real shop.
            for name in ["Milk", "Peas", "Bread"] {
                if let data = UIImage(named: "Preview\(name)")?.pngData() {
                    try? ShoppingActivityImages.save(data, named: "preview-\(name)")
                }
            }
            let fixture: (title: String, detail: String, image: String?) = switch location {
            case .pantry: ("Sourdough bread", "Tesco • 800g", "Bread")
            case .fridge: ("Whole milk", "Tesco • 2 pints", "Milk")
            case .freezer: ("Frozen peas", "Tesco • 900g", "Peas")
            case nil: ("Kitchen roll", "", nil)
            }
            let nextLocation: StorageLocation? = sameCategory || location == nil ? location : location == .pantry ? .fridge : .freezer
            let nextTitle = location == nil ? "Bin bags" : sameCategory ? "Greek yoghurt" : location == .pantry ? "Whole milk" :
                "Frozen peas"
            var items = (1...6).map { id in
                ShoppingItem(
                    id: id,
                    title: "Collected item",
                    createdAt: .now,
                    updatedAt: .now,
                    source: .user,
                    status: .pendingCompletion,
                    storageLocation: .pantry,
                    product: nil)
            }
            items.append(ShoppingItem(
                id: 7,
                title: longTitle ? "Organic British whole milk with added vitamins" : fixture.title,
                createdAt: .now,
                updatedAt: .now,
                source: .user,
                status: complete ? .pendingCompletion : .created,
                storageLocation: location,
                product: nil))
            items.append(ShoppingItem(
                id: 8,
                title: nextTitle,
                createdAt: .now,
                updatedAt: .now,
                source: .user,
                status: complete || lastItem ? .pendingCompletion : .created,
                storageLocation: nextLocation,
                product: nil))
            var state = ContentState(items: items)
            state.current?.detail = fixture.detail
            state.current?.brand = fixture.detail.isEmpty ? nil : "Tesco"
            state.current?.imageName = fixture.image.map { ShoppingActivityImages.fileName(for: "preview-\($0)") }
            if !sameCategory, location != nil {
                state.next?.imageName = ShoppingActivityImages.fileName(for: location == .pantry ? "preview-Milk" : "preview-Peas")
            }
            return state
        }
    }

    #Preview("Lock Screen", as: .content, using: ShoppingActivityAttributes.preview) {
        ShoppingLiveActivityLiveActivity()
    } contentStates: {
        ShoppingActivityAttributes.sample()
        ShoppingActivityAttributes.sample(.pantry)
        ShoppingActivityAttributes.sample(sameCategory: true)
        ShoppingActivityAttributes.sample(.freezer, lastItem: true)
        ShoppingActivityAttributes.sample(complete: true)
        ShoppingActivityAttributes.sample(nil)
        ShoppingActivityAttributes.sample(longTitle: true)
    }

    #Preview("Dynamic Island", as: .dynamicIsland(.expanded), using: ShoppingActivityAttributes.preview) {
        ShoppingLiveActivityLiveActivity()
    } contentStates: {
        ShoppingActivityAttributes.sample()
        ShoppingActivityAttributes.sample(.freezer, lastItem: true)
        ShoppingActivityAttributes.sample(complete: true)
        ShoppingActivityAttributes.sample(longTitle: true)
        ShoppingActivityAttributes.sample(nil, lastItem: true)
    }

    #Preview("Compact", as: .dynamicIsland(.compact), using: ShoppingActivityAttributes.preview) {
        ShoppingLiveActivityLiveActivity()
    } contentStates: {
        ShoppingActivityAttributes.sample()
        ShoppingActivityAttributes.sample(complete: true)
    }

    #Preview("Minimal", as: .dynamicIsland(.minimal), using: ShoppingActivityAttributes.preview) {
        ShoppingLiveActivityLiveActivity()
    } contentStates: {
        ShoppingActivityAttributes.sample()
        ShoppingActivityAttributes.sample(complete: true)
    }

    #Preview("Final item", as: .dynamicIsland(.expanded), using: ShoppingActivityAttributes.preview) {
        ShoppingLiveActivityLiveActivity()
    } contentStates: {
        ShoppingActivityAttributes.sample(.freezer, lastItem: true)
    }

    #Preview("Basket ready", as: .dynamicIsland(.expanded), using: ShoppingActivityAttributes.preview) {
        ShoppingLiveActivityLiveActivity()
    } contentStates: {
        ShoppingActivityAttributes.sample(complete: true)
    }
#endif
