import DesignSystem
import Models
import SwiftUI

@MainActor let consumableItem: ConsumableItem = .init(id: UUID(), icon: "waterbottle", name: "Semi Skimmed Milk", category: "Dairy", brand: "Sainburys", amount: 4, unit: "pints", inventoryStore: .fridge, status: .open, wasteScore: 17, expiryDate: Date())

struct StatsView: View {
    var body: some View {
        HStack {
            VStack {
                Text("Location")
                    .textCase(.uppercase)
                    .foregroundStyle(.gray400)
                    .font(.caption)
                Text(consumableItem.inventoryStore.rawValue)
                    .fontWeight(.bold)
                    .foregroundStyle(.green600)
                    .font(.headline)
            }
            Spacer()

            VStack {
                Text("Status")
                    .textCase(.uppercase)
                    .foregroundStyle(.gray400)
                    .font(.caption)
                Text(consumableItem.status.rawValue)
                    .fontWeight(.bold)
                    .foregroundStyle(.green600)
                    .font(.headline)
            }
            Spacer()

            VStack {
                Text("Expiry")
                    .textCase(.uppercase)
                    .foregroundStyle(.gray400)
                    .font(.caption)
                HStack(spacing: 3) {
                    Image(systemName: "hourglass")
                        .font(.system(size: 18))
                        .foregroundStyle(.green600)
                    Text("3 days")
                        .fontWeight(.bold)
                        .foregroundStyle(.green600)
                        .font(.headline)
                }
            }
        }
        .padding(.vertical, 15)
        .padding(.horizontal, 20)
        .background(
            UnevenRoundedRectangle(
                topLeadingRadius: 0,
                bottomLeadingRadius: 20,
                bottomTrailingRadius: 20,
                topTrailingRadius: 0,
                style: .continuous
            )
        )
        .foregroundStyle(.green300)
    }
}

struct WideStatsView: View {
    var body: some View {
        HStack {
            VStack {
                Text("Location")
                    .textCase(.uppercase)
                    .foregroundStyle(.gray400)
                    .font(.caption)
                Text(consumableItem.inventoryStore.rawValue.capitalized)
                    .fontWeight(.bold)
                    .foregroundStyle(.green600)
                    .font(.headline)
            }
            Spacer()

            VStack {
                Text("Status")
                    .textCase(.uppercase)
                    .foregroundStyle(.gray400)
                    .font(.caption)
                Text(consumableItem.status.rawValue.capitalized)
                    .fontWeight(.bold)
                    .foregroundStyle(.green600)
                    .font(.headline)
            }
            Spacer()

            VStack {
                Text("Waste %")
                    .textCase(.uppercase)
                    .foregroundStyle(.gray400)
                    .font(.caption)
                Text("\(String(format: "%.0f", consumableItem.amount))")
                    .fontWeight(.bold)
                    .foregroundStyle(.green600)
                    .font(.headline)
            }
            Spacer()

            VStack {
                Text("EXPIRY")
                    .textCase(.uppercase)
                    .foregroundStyle(.gray400)
                    .font(.caption)
                HStack(spacing: 3) {
                    Image(systemName: "hourglass")
                        .font(.system(size: 18))
                        .foregroundStyle(.green600)
                    Text("3 days")
                        .fontWeight(.bold)
                        .foregroundStyle(.green600)
                        .font(.headline)
                }
            }
        }
        .padding(.vertical, 15)
        .padding(.horizontal, 20)
        .background(
            UnevenRoundedRectangle(
                topLeadingRadius: 0,
                bottomLeadingRadius: 20,
                bottomTrailingRadius: 20,
                topTrailingRadius: 0,
                style: .continuous
            )
        )
        .foregroundStyle(.green300)
    }
}

public struct TodayView: View {
    public init() {}

    @State private var selectedConsumableItem: ConsumableItem? = nil

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private func getSheetFraction(height: CGFloat) -> CGFloat {
        if dynamicTypeSize >= .xxLarge {
            return 0.8
        }

        switch height {
        case ..<668:
            return 1 // iPhone SE
        case ..<845:
            return 0.9 // iPhone 13
        case ..<957:
            return 0.8 // iPhone 16 Pro Max
        default:
            return 0.7
        }
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 0) {
                HStack {
                    Image(systemName: consumableItem.icon)
                        .font(.system(size: 36))
                    VStack(spacing: 5) {
                        Text(consumableItem.name)
                            .font(.title2)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        HStack {
                            Text(consumableItem.category)
                                .font(.footnote).foregroundStyle(.gray600)
                            Circle()
                                .frame(width: 4, height: 4)
                                .foregroundStyle(.gray600)
                            Text(consumableItem.brand)
                                .font(.footnote)
                                .foregroundStyle(.brandSainsburys)
                            Circle()
                                .frame(width: 4, height: 4)
                                .foregroundStyle(.gray600)
                            Text("\(String(format: "%.0f", consumableItem.amount)) \(consumableItem.unit)").foregroundStyle(.gray600)
                                .font(.footnote)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    Spacer()
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 10)
                .background(Color.white)
                .cornerRadius(20)

                ViewThatFits {
                    WideStatsView()
                    StatsView()
                }
            }
            .padding(.bottom, 4)
            .padding(.horizontal, 4)
            .background(Color.white)
            .cornerRadius(20)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .shadow(color: .shadow, radius: 2, x: 0, y: 4)
            .onTapGesture {
                // need to add haptics
                selectedConsumableItem = consumableItem
            }
            .sheet(item: $selectedConsumableItem) { _ in
                ConsumableItemSheetView(consumableItem: $selectedConsumableItem)
                    .presentationDetents([.fraction(getSheetFraction(height: UIScreen.main.bounds.size.height))])
                    .presentationDragIndicator(.visible)
                    .presentationCornerRadius(25)
            }
        }.padding(.vertical, 10).background(.white200)
    }
}
