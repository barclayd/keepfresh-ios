import DesignSystem
import Models
import SwiftUI

struct CheckToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            Label {} icon: {
                Image(systemName: configuration.isOn ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 21))
                    .fontWeight(.bold)
                    .foregroundStyle(.blue800)
                    .accessibility(label: Text(configuration.isOn ? "Checked" : "Unchecked"))
                    .imageScale(.large)
            }
        }
        .buttonStyle(.plain)
    }
}

enum ConsumableCategoryType: String, Codable {
    case ExpiryDate = "Expiry Date"
    case Storage
    case Status
    case Quantity
}

enum ExpiryType: String, Codable, Identifiable, CaseIterable {
    var id: Self { self }

    case UseBy = "Use By"
    case BestBefore = "Best Before"
}

private extension ConsumableCategoryType {
    var isExapndable: Bool {
        switch self {
        case .ExpiryDate, .Storage, .Status:
            true
        case .Quantity:
            false
        }
    }

    var icon: String {
        switch self {
        case .ExpiryDate:
            "hourglass"
        case .Storage:
            "house"
        case .Status:
            "door.right.hand.open"
        case .Quantity:
            "list.number"
        }
    }
}

private extension Date {
    var formattedWithOrdinal: String {
        let day = Calendar.current.component(.day, from: self)
        let suffix: String

        switch day {
        case 1, 21, 31: suffix = "st"
        case 2, 22: suffix = "nd"
        case 3, 23: suffix = "rd"
        default: suffix = "th"
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "d'\(suffix)' MMMM"
        return formatter.string(from: self)
    }

    var expiryDescription: String {
        let days = daysFromNow
        switch days {
        case ..<(-1):
            return "Expiry has past"
        case -1:
            return "Expired yesterday"
        case 0:
            return "Expires today"
        case 1:
            return "Expires tomorrow"
        default:
            return "Expires in \(days) days"
        }
    }

    private var daysFromNow: Int {
        let calendar = Calendar.current

        // Start of day for both dates
        let startOfToday = calendar.startOfDay(for: Date.now)
        let startOfTarget = calendar.startOfDay(for: self)

        let components = calendar.dateComponents([.day], from: startOfToday, to: startOfTarget)
        return components.day ?? 0
    }

    func isSameDay(as other: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(self, equalTo: other, toGranularity: .day)
    }
}

private extension ConsumableCategoryType {
    @MainActor
    @ViewBuilder
    func overviewLabel(
        quantity: Binding<Int>,
        status: Binding<ConsumableStatus>,
        expiryDate: Binding<Date>,
        inventoryStore: Binding<InventoryStore>,
        didUpdateExpiryDate: Bool,
        didUpdateInventoryStore: Bool
    ) -> some View {
        switch self {
        case .ExpiryDate:
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 0) {
                    Text(expiryDate.wrappedValue.formattedWithOrdinal).foregroundStyle(.gray600)
                    if !didUpdateExpiryDate {
                        Image(systemName: "sparkles").font(.system(size: 16)).foregroundColor(.yellow500)
                            .offset(y: -8)
                    }
                }
                Text(expiryDate.wrappedValue.expiryDescription).foregroundStyle(.black800).font(.footnote)
                    .fontWeight(
                        .thin)
            }
            .frame(width: 150, alignment: .leading)

        case .Status:
            VStack(alignment: .leading, spacing: 0) {
                Text(status.wrappedValue.rawValue.capitalized).foregroundStyle(.gray600)
            }
            .frame(width: 150, alignment: .leading)

        case .Storage:
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .lastTextBaseline, spacing: 0) {
                    Image(systemName: inventoryStore.wrappedValue.icon).font(.system(size: 24))
                        .foregroundStyle(.gray600).padding(.trailing, 2)
                    Text(inventoryStore.wrappedValue.rawValue.capitalized).foregroundStyle(.gray600)
                    if !didUpdateInventoryStore {
                        Image(systemName: "sparkles").font(.system(size: 16)).foregroundColor(.yellow500)
                            .offset(y: -8)
                    }
                }
            }
            .frame(width: 150, alignment: .leading)

        case .Quantity:
            VStack(alignment: .leading, spacing: 0) {
                Text("\(quantity.wrappedValue)").foregroundStyle(.gray600)
            }
            .frame(width: 100, alignment: .leading)
        }
    }

    @ViewBuilder
    func overviewSwitch(isToggled: Binding<Bool>, quantity: Binding<Int>) -> some View {
        switch self {
        case .ExpiryDate, .Status, .Storage:
            Toggle("Selected Expiry Date", isOn: isToggled)
                .toggleStyle(CheckToggleStyle())
                .labelsHidden()
        case .Quantity:
            Stepper(value: quantity, in: 1 ... 10, step: 1) {}.tint(.blue800)
        }
    }

    @MainActor
    @ViewBuilder
    func expandedContent(
        status: Binding<ConsumableStatus>, inventoryStore: Binding<InventoryStore>,
        expiryDate: Binding<Date>
    ) -> some View {
        switch self {
        case .ExpiryDate:
            ConsumableCategoryExpiryDateContent(expiryDate: expiryDate)
        case .Status:
            ConsumableCategoryStatusContent(status: status)
        case .Storage:
            ConsumableCategoryStorageContent(inventoryStore: inventoryStore)
        default:
            EmptyView()
        }
    }
}

struct ConsumableCategoryOverview: View {
    @Binding var isExpiryDateToggled: Bool
    @Binding var isMarkedAsReady: Bool
    @Binding var quantity: Int
    @Binding var status: ConsumableStatus
    @Binding var inventoryStore: InventoryStore
    @Binding var expiryDate: Date
    var didUpdateExpiryDate: Bool
    var didUpdateInventoryStore: Bool

    let type: ConsumableCategoryType

    var body: some View {
        Image(systemName: type.icon)
            .font(.system(size: 21))
            .fontWeight(.bold)
            .foregroundColor(.blue800)
            .frame(width: 40, height: 40)
            .background(Circle().fill(.blue200))

        Text(type.rawValue)
            .fontWeight(.bold)
            .foregroundStyle(.blue800)
            .font(.headline)
            .lineLimit(1)
            .frame(width: 105, alignment: .leading)

        type.overviewLabel(
            quantity: $quantity, status: $status, expiryDate: $expiryDate,
            inventoryStore: $inventoryStore,
            didUpdateExpiryDate: didUpdateExpiryDate, didUpdateInventoryStore: didUpdateInventoryStore
        )

        Spacer()

        type.overviewSwitch(isToggled: $isMarkedAsReady, quantity: $quantity)
    }
}

struct ConsumableCategoryStatusContent: View {
    @Binding var status: ConsumableStatus

    @State private var showStoragePicker = false

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "house")
                    .font(.system(size: 21))
                    .fontWeight(.bold)
                    .foregroundColor(.blue800)
                    .frame(width: 40, height: 40)

                Text("Status")
                    .foregroundStyle(.blue800)
                    .font(.callout)
                    .lineLimit(1)
                    .frame(width: 105, alignment: .leading)

                Picker("Select consumable item status", selection: $status) {
                    ForEach(ConsumableStatus.allCases) { statusType in
                        Text(statusType.rawValue).foregroundStyle(.gray600)
                            .font(.callout)
                            .lineLimit(1).border(.yellow)
                    }
                }.labelsHidden().tint(.gray600).padding(.horizontal, -12).frame(
                    width: 150, alignment: .leading
                )

                Spacer()
            }

        }.padding(.vertical, 10).padding(.horizontal, 10).frame(maxWidth: .infinity).background(
            UnevenRoundedRectangle(
                cornerRadii: RectangleCornerRadii(
                    topLeading: 0, bottomLeading: 20, bottomTrailing: 20, topTrailing: 0
                )
            ).fill(.white))
    }
}

struct ConsumableCategoryStorageContent: View {
    @Binding var inventoryStore: InventoryStore

    @State private var showStoragePicker = false

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "house")
                    .font(.system(size: 21))
                    .fontWeight(.bold)
                    .foregroundColor(.blue800)
                    .frame(width: 40, height: 40)

                Text("Location")
                    .foregroundStyle(.blue800)
                    .font(.callout)
                    .lineLimit(1)
                    .frame(width: 105, alignment: .leading)

                Picker("Select storage location", selection: $inventoryStore) {
                    ForEach(InventoryStore.allCases) { inventoryStore in
                        Text(inventoryStore.rawValue.capitalized).foregroundStyle(.gray600)
                            .font(.callout)
                            .lineLimit(1).border(.yellow)
                    }
                }.labelsHidden().tint(.gray600).padding(.horizontal, -12).frame(
                    width: 150, alignment: .leading
                )

                Spacer()
            }

        }.padding(.vertical, 10).padding(.horizontal, 10).frame(maxWidth: .infinity).background(
            UnevenRoundedRectangle(
                cornerRadii: RectangleCornerRadii(
                    topLeading: 0, bottomLeading: 20, bottomTrailing: 20, topTrailing: 0
                )
            ).fill(.white))
    }
}

struct ConsumableCategoryExpiryDateContent: View {
    @Binding var expiryDate: Date

    @State private var showDatePicker = false

    @State private var expiryType: ExpiryType = .BestBefore

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "calendar.badge.exclamationmark")
                    .font(.system(size: 21))
                    .fontWeight(.bold)
                    .foregroundColor(.blue800)
                    .frame(width: 40, height: 40)

                Text(expiryType.rawValue)
                    .foregroundStyle(.blue800)
                    .font(.callout)
                    .lineLimit(1)
                    .frame(width: 105, alignment: .leading)

                Button(action: { showDatePicker.toggle() }) {
                    Text(expiryDate.formattedWithOrdinal)
                        .foregroundStyle(.gray600)
                        .font(.callout)
                        .lineLimit(1)
                        .frame(width: 150, alignment: .leading)
                }

                Spacer()
            }

            if showDatePicker {
                DatePicker(
                    "Expiry date",
                    selection: $expiryDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical).colorInvert().colorMultiply(.blue400)
            }

            HStack {
                Image(systemName: "calendar.badge.exclamationmark")
                    .font(.system(size: 21))
                    .fontWeight(.bold)
                    .foregroundColor(.blue800)
                    .frame(width: 40, height: 40)

                Text("Expiry type")
                    .foregroundStyle(.blue800)
                    .font(.callout)
                    .lineLimit(1)
                    .frame(width: 105, alignment: .leading)

                Picker("Select expiry type", selection: $expiryType) {
                    ForEach(ExpiryType.allCases) { expiryType in
                        Text(expiryType.rawValue).foregroundStyle(.gray600)
                            .font(.callout)
                            .lineLimit(1).border(.yellow)
                    }
                }.labelsHidden().tint(.gray600).padding(.horizontal, -12).frame(
                    width: 150, alignment: .leading
                )

                Spacer()
            }

        }.padding(.vertical, 10).padding(.horizontal, 10).frame(maxWidth: .infinity).background(
            UnevenRoundedRectangle(
                cornerRadii: RectangleCornerRadii(
                    topLeading: 0, bottomLeading: 20, bottomTrailing: 20, topTrailing: 0
                )
            ).fill(.white))
    }
}

public struct ConsumableCategory: View {
    private static let initialInventoryStore: InventoryStore = .fridge
    private static let initialExpiryDate = Date()

    @State private var isExpandedToggled: Bool = false
    @State private var isMarkedAsReady: Bool = false
    @State private var quantity: Int = 1
    @State private var status: ConsumableStatus = .unopened
    @State private var expiryDate = initialExpiryDate
    @State private var inventoryStore: InventoryStore = initialInventoryStore

    let type: ConsumableCategoryType

    var isToggable: Bool {
        isExpandedToggled && type.isExapndable
    }

    var didUpdateInventoryStore: Bool {
        inventoryStore != ConsumableCategory.initialInventoryStore
    }

    var didUpdateExpiryDate: Bool {
        expiryDate.isSameDay(as: ConsumableCategory.initialExpiryDate) == false
    }

    public var body: some View {
        VStack(spacing: 0) {
            HStack {
                ConsumableCategoryOverview(
                    isExpiryDateToggled: $isExpandedToggled,
                    isMarkedAsReady: $isMarkedAsReady,
                    quantity: $quantity,
                    status: $status,
                    inventoryStore: $inventoryStore,
                    expiryDate: $expiryDate,
                    didUpdateExpiryDate: didUpdateExpiryDate,
                    didUpdateInventoryStore: didUpdateInventoryStore,
                    type: type
                )
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 10)
            .frame(maxWidth: .infinity)
            .background(
                UnevenRoundedRectangle(
                    cornerRadii: RectangleCornerRadii(
                        topLeading: 20,
                        bottomLeading: isToggable ? 0 : 20,
                        bottomTrailing: isToggable ? 0 : 20,
                        topTrailing: 20
                    )
                ).fill(.gray200)
            )
            .onTapGesture {
                withAnimation(.easeInOut) {
                    isExpandedToggled.toggle()
                }
            }
            if isToggable {
                type.expandedContent(
                    status: $status, inventoryStore: $inventoryStore, expiryDate: $expiryDate
                )
            }
        }
        .transition(.move(edge: .top))
    }
}
