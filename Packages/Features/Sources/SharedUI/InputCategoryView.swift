import DesignSystem
import Models
import SwiftUI

struct CheckToggleStyle: ToggleStyle {
    @Environment(\.isEnabled) var isEnabled
    
    var customColor: Color?

    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            Label {} icon: {
                Image(systemName: configuration.isOn ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 21))
                    .fontWeight(.bold)
                    .foregroundStyle(customColor ?? .blue700)
                    .accessibility(label: Text(configuration.isOn ? "Checked" : "Unchecked"))
                    .imageScale(.large)
            }
        }
    }
}

public enum InventoryItemFormType {
    case expiry(date: Binding<Date>, isRecommended: Bool)
    case compactExpiry(date: Binding<Date>, isRecommended: Bool, expiryType: ExpiryType)
    case storage(location: Binding<StorageLocation>, isRecommended: Bool)
    case readOnlyStorage(location: StorageLocation, isRecommended: Bool)
    case status(status: Binding<ProductSearchItemStatus>)
    case quantity(quantity: Binding<Int>)
}

private extension InventoryItemFormType {
    var isExapndable: Bool {
        switch self {
        case .expiry, .storage, .status, .compactExpiry:
            true
        case .quantity, .readOnlyStorage:
            false
        }
    }

    var icon: String {
        switch self {
        case .expiry, .compactExpiry:
            "hourglass"
        case .storage, .readOnlyStorage:
            "house"
        case .status:
            "tin.open"
        case .quantity:
            "list.number"
        }
    }

    var title: String {
        switch self {
        case .expiry, .compactExpiry:
            "Expiry"
        case .storage, .readOnlyStorage:
            "Storage"
        case .status:
            "Status"
        case .quantity:
            "Quantity"
        }
    }
}

private extension Date {
    var formattedWithOrdinal: String {
        let calendar = Calendar.current
        let dayNum = calendar.component(.day, from: self)
        let showYear = !calendar.isDate(self, equalTo: .now, toGranularity: .year)

        let ordinal = NumberFormatter.localizedString(
            from: NSNumber(value: dayNum),
            number: .ordinal)

        let month = formatted(.dateTime.month(.wide))
        let year = showYear ? " \(formatted(.dateTime.year(.twoDigits)))" : ""

        return "\(ordinal) \(month)\(year)"
    }

    var formattedAbbreviation: String {
        let calendar = Calendar.current
        let dayNum = calendar.component(.day, from: self)
        let showYear = !calendar.isDate(self, equalTo: .now, toGranularity: .year)

        let ordinal = NumberFormatter.localizedString(
            from: NSNumber(value: dayNum),
            number: .ordinal)

        let month = formatted(.dateTime.month(.abbreviated))
        let year = showYear ? " \(formatted(.dateTime.year(.twoDigits)))" : ""

        return "\(ordinal) \(month)\(year)"
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

        let startOfToday = calendar.startOfDay(for: Date.now)
        let startOfTarget = calendar.startOfDay(for: self)

        let components = calendar.dateComponents([.day], from: startOfToday, to: startOfTarget)
        return components.day ?? 0
    }
}

private extension InventoryItemFormType {
    @MainActor
    @ViewBuilder
    func overviewLabel(customColor: Color? = nil) -> some View {
        switch self {
        case .expiry(let date, let isRecommended), .compactExpiry(let date, let isRecommended, _):
            VStack(alignment: .leading, spacing: 0) {
                ViewThatFits(in: .horizontal) {
                    HStack(spacing: 0) {
                        Text(date.wrappedValue.formattedWithOrdinal).foregroundStyle(customColor ?? .gray600)
                        if isRecommended {
                            Image(systemName: "sparkles").font(.system(size: 16)).foregroundColor(.yellow500)
                                .offset(y: -8)
                        }
                    }
                    HStack(spacing: 0) {
                        Text(date.wrappedValue.formattedAbbreviation).foregroundStyle(customColor ?? .gray600)
                        if isRecommended {
                            Image(systemName: "sparkles").font(.system(size: 16)).foregroundColor(.yellow500)
                                .offset(y: -8)
                        }
                    }
                }
                Text(date.wrappedValue.expiryDescription).foregroundStyle(customColor ?? .black800).font(.footnote)
                    .fontWeight(.thin)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

        case .status(let status):
            VStack(alignment: .leading, spacing: 0) {
                Text(status.wrappedValue.rawValue.capitalized).foregroundStyle(.gray600)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

        case .storage(let location, let isRecommended):
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .lastTextBaseline, spacing: 0) {
                    Image(systemName: location.wrappedValue.icon).font(.system(size: 24))
                        .foregroundStyle(.gray600).padding(.trailing, 2)
                    Text(location.wrappedValue.rawValue.capitalized).foregroundStyle(.gray600)
                    if isRecommended {
                        Image(systemName: "sparkles").font(.system(size: 16)).foregroundColor(.yellow500)
                            .offset(y: -8)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

        case .readOnlyStorage(let location, let isRecommended):
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .lastTextBaseline, spacing: 0) {
                    Image(systemName: location.icon).font(.system(size: 24))
                        .foregroundStyle(customColor ?? .gray600).padding(.trailing, 2)
                    Text(location.rawValue.capitalized).foregroundStyle(customColor ?? .gray600)
                    if isRecommended {
                        Image(systemName: "sparkles").font(.system(size: 16)).foregroundColor(.yellow500)
                            .offset(y: -8)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

        case .quantity(let quantity):
            VStack(alignment: .leading, spacing: 0) {
                Text("\(quantity.wrappedValue)").foregroundStyle(.gray600)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    @ViewBuilder
    func overviewSwitch(isToggled: Binding<Bool>, customColor: Color? = nil) -> some View {
        switch self {
        case .expiry, .compactExpiry, .status, .storage, .readOnlyStorage:
            Toggle("Selected Expiry Date", isOn: isToggled)
                .toggleStyle(CheckToggleStyle(customColor: customColor))
                .labelsHidden()
                .disabled(true)
        case .quantity(let quantity):
            Stepper(value: quantity, in: 1 ... 10, step: 1) {}.tint(.blue700)
        }
    }

    @MainActor
    @ViewBuilder
    func expandedContent(forceExpanded: Bool) -> some View {
        switch self {
        case .expiry(let date, _):
            InventoryItemExpiryDateContent(expiryDate: date)
        case .compactExpiry(let date, _, let expiryType):
            InventoryItemExpiryDateCompactContent(expiryDate: date, expiryType: expiryType)
        case .status(let status):
            IventoryItemStatusContent(status: status)
        case .storage(let location, _):
            InventoryItemStorageContent(storageLocation: location)
        case .readOnlyStorage(let location, _):
            InventoryItemReadOnlyStorageContent(storageLocation: location)
        case .quantity:
            EmptyView()
        }
    }
}

struct InventoryItemOverview: View {
    @Binding var isExpiryDateToggled: Bool
    @Binding var isMarkedAsReady: Bool

    let type: InventoryItemFormType
    let customColor: Color?

    var body: some View {
        Group {
            if type.icon == "tin.open" {
                Image("tin.open")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 23, height: 23)
            } else {
                Image(systemName: type.icon)
                    .font(.system(size: 21))
                    .fontWeight(.bold)
            }
        }
        .foregroundColor(.blue700)
        .frame(width: 40, height: 40)
        .background(Circle().fill(.blue200))

        Text(type.title)
            .fontWeight(.bold)
            .foregroundStyle(customColor ?? .blue700)
            .font(.headline)
            .lineLimit(1)
            .frame(width: 105, alignment: .leading)

        type.overviewLabel(customColor: customColor)

        Spacer()

        type.overviewSwitch(isToggled: $isMarkedAsReady, customColor: customColor)
    }
}

struct IventoryItemStatusContent: View {
    @Binding var status: ProductSearchItemStatus

    @State private var showStoragePicker = false

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "door.right.hand.open")
                    .font(.system(size: 21))
                    .fontWeight(.bold)
                    .foregroundColor(.blue700)
                    .frame(width: 40, height: 40)

                Text("Status")
                    .foregroundStyle(.blue700)
                    .font(.callout)
                    .lineLimit(1)
                    .frame(width: 105, alignment: .leading)

                Picker("Select inventory item status", selection: $status) {
                    ForEach(ProductSearchItemStatus.allCases) { statusType in
                        Text(statusType.rawValue.capitalized).foregroundStyle(.gray600)
                            .font(.callout)
                            .lineLimit(1).border(.yellow)
                    }
                }.labelsHidden().tint(.gray600).padding(.horizontal, -12).frame(maxWidth: .infinity, alignment: .leading)

                Spacer()
            }

        }.padding(.vertical, 10).padding(.horizontal, 10).frame(maxWidth: .infinity)
            .background(
                UnevenRoundedRectangle(cornerRadii: RectangleCornerRadii(
                    topLeading: 0,
                    bottomLeading: 20,
                    bottomTrailing: 20,
                    topTrailing: 0))
                    .fill(.white100))
    }
}

struct InventoryItemStorageContent: View {
    @Binding var storageLocation: StorageLocation

    @State private var showStoragePicker = false

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "house")
                    .font(.system(size: 21))
                    .fontWeight(.bold)
                    .foregroundColor(.blue700)
                    .frame(width: 40, height: 40)

                Text("Location")
                    .foregroundStyle(.blue700)
                    .font(.callout)
                    .lineLimit(1)
                    .frame(width: 105, alignment: .leading)

                Picker("Select storage location", selection: $storageLocation) {
                    ForEach(StorageLocation.allCases) { storageLocation in
                        Text(storageLocation.rawValue.capitalized).foregroundStyle(.gray600)
                            .font(.callout)
                            .lineLimit(1).border(.yellow)
                    }
                }.labelsHidden().tint(.gray600).padding(.horizontal, -12).frame(maxWidth: .infinity, alignment: .leading)

                Spacer()
            }

        }.padding(.vertical, 10).padding(.horizontal, 10).frame(maxWidth: .infinity)
            .background(
                UnevenRoundedRectangle(cornerRadii: RectangleCornerRadii(
                    topLeading: 0,
                    bottomLeading: 20,
                    bottomTrailing: 20,
                    topTrailing: 0))
                    .fill(.white100))
    }
}

struct InventoryItemReadOnlyStorageContent: View {
    let storageLocation: StorageLocation

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "house")
                    .font(.system(size: 21))
                    .fontWeight(.bold)
                    .foregroundColor(.blue700)
                    .frame(width: 40, height: 40)

                Text("Location")
                    .foregroundStyle(.blue700)
                    .font(.callout)
                    .lineLimit(1)
                    .frame(width: 105, alignment: .leading)

                HStack {
                    Text(storageLocation.rawValue.capitalized).foregroundStyle(.gray600)
                        .font(.callout)
                        .lineLimit(1).border(.yellow)
                }.tint(.gray600).padding(.horizontal, -12).frame(maxWidth: .infinity, alignment: .leading)

                Spacer()
            }

        }.padding(.vertical, 10).padding(.horizontal, 10).frame(maxWidth: .infinity)
            .background(
                UnevenRoundedRectangle(cornerRadii: RectangleCornerRadii(
                    topLeading: 0,
                    bottomLeading: 20,
                    bottomTrailing: 20,
                    topTrailing: 0))
                    .fill(.white100))
    }
}

struct InventoryItemExpiryDateContent: View {
    @Binding var expiryDate: Date

    @State private var showDatePicker = false

    @State private var expiryType: ExpiryType = .BestBefore

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "calendar.badge.exclamationmark")
                    .font(.system(size: 21))
                    .fontWeight(.bold)
                    .foregroundColor(.blue700)
                    .frame(width: 40, height: 40)

                Text(expiryType.rawValue)
                    .foregroundStyle(.blue700)
                    .font(.callout)
                    .lineLimit(1)
                    .frame(width: 105, alignment: .leading)

                Button(action: {
                    showDatePicker.toggle()
                }) {
                    Text(expiryDate.formattedWithOrdinal)
                        .foregroundStyle(.gray600)
                        .font(.callout)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                Spacer()
            }

            if showDatePicker {
                DatePicker(
                    "Expiry",
                    selection: $expiryDate,
                    displayedComponents: [.date])
                    .datePickerStyle(.graphical).colorInvert().colorMultiply(.blue400)
            }

            HStack {
                Image(systemName: "calendar.badge.exclamationmark")
                    .font(.system(size: 21))
                    .fontWeight(.bold)
                    .foregroundColor(.blue700)
                    .frame(width: 40, height: 40)

                Text("Expiry type")
                    .foregroundStyle(.blue700)
                    .font(.callout)
                    .lineLimit(1)
                    .frame(width: 105, alignment: .leading)

                Picker("Select expiry type", selection: $expiryType) {
                    ForEach(ExpiryType.allCases) { expiryType in
                        Text(expiryType.rawValue).foregroundStyle(.gray600)
                            .font(.callout)
                            .lineLimit(1).border(.yellow)
                    }
                }.labelsHidden().tint(.gray600).padding(.horizontal, -12).frame(maxWidth: .infinity, alignment: .leading)

                Spacer()
            }

        }.padding(.vertical, 10).padding(.horizontal, 10).frame(maxWidth: .infinity)
            .background(
                UnevenRoundedRectangle(cornerRadii: RectangleCornerRadii(
                    topLeading: 0,
                    bottomLeading: 20,
                    bottomTrailing: 20,
                    topTrailing: 0))
                    .fill(.white100))
    }
}

struct InventoryItemExpiryDateCompactContent: View {
    @Binding var expiryDate: Date

    let expiryType: ExpiryType

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "calendar.badge.exclamationmark")
                    .font(.system(size: 21))
                    .fontWeight(.bold)
                    .foregroundColor(.blue700)
                    .frame(width: 40, height: 40)

                Text(expiryType.rawValue)
                    .foregroundStyle(.blue700)
                    .font(.callout)
                    .lineLimit(1)
                    .frame(width: 105, alignment: .leading)

                DatePicker(
                    "Expiry",
                    selection: $expiryDate,
                    displayedComponents: [.date])
                    .datePickerStyle(.compact).labelsHidden()

                Spacer()
            }
        }.padding(.vertical, 10).padding(.horizontal, 10).frame(maxWidth: .infinity)
            .background(
                UnevenRoundedRectangle(cornerRadii: RectangleCornerRadii(
                    topLeading: 0,
                    bottomLeading: 20,
                    bottomTrailing: 20,
                    topTrailing: 0))
                    .fill(.white100))
    }
}

public struct InventoryCategory: View {
    @State private var isExpandedToggled: Bool = false
    @State private var isMarkedAsReady: Bool = true

    let type: InventoryItemFormType
    let storageLocation: StorageLocation
    let forceExpanded: Bool
    let customColor: (Color, Color)?

    public init(type: InventoryItemFormType, storageLocation: StorageLocation, forceExpanded: Bool = false, customColor: (Color, Color)? = nil) {
        self.type = type
        self.storageLocation = storageLocation
        self.forceExpanded = forceExpanded
        self.customColor = customColor
    }

    var isToggable: Bool {
        forceExpanded || (isExpandedToggled && type.isExapndable)
    }

    public var body: some View {
        VStack(spacing: 0) {
            HStack {
                InventoryItemOverview(
                    isExpiryDateToggled: forceExpanded ? .constant(true) : $isExpandedToggled,
                    isMarkedAsReady: $isMarkedAsReady,
                    type: type, customColor: customColor?.0)
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 10)
            .frame(maxWidth: .infinity)
            .background(
                UnevenRoundedRectangle(cornerRadii: RectangleCornerRadii(
                    topLeading: 20,
                    bottomLeading: isToggable ? 0 : 20,
                    bottomTrailing: isToggable ? 0 : 20,
                    topTrailing: 20)).fill(customColor?.1 ?? storageLocation.statsBackgroundTint))
            .onTapGesture {
                withAnimation(.easeInOut) {
                    isExpandedToggled.toggle()
                }
            }
            if isToggable {
                type.expandedContent(forceExpanded: forceExpanded)
            }
        }
        .transition(.move(edge: .top))
    }
}
