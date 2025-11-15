import DesignSystem
import Extensions
import Models
import SwiftUI

public enum Overriden {
    case user
    case suggested
}

public enum InventoryItemFormType {
    case expiry(date: Binding<Date>, isRecommended: Bool, overriden: Binding<Overriden?>)
    case compactExpiry(date: Binding<Date>, isRecommended: Bool, expiryType: ExpiryType)
    case storage(location: Binding<StorageLocation>, isRecommended: Bool, overriden: Binding<Overriden?>)
    case readOnlyStorage(location: StorageLocation, isRecommended: Bool)
    case status(status: Binding<ProductSearchItemStatus>, overriden: Binding<Overriden?>)
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

private extension InventoryItemFormType {
    @MainActor
    @ViewBuilder
    func overviewLabel(customColor: Color? = nil) -> some View {
        switch self {
        case let .expiry(date, isRecommended, _), let .compactExpiry(date, isRecommended, _):
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

        case let .status(status, _):
            VStack(alignment: .leading, spacing: 0) {
                Text(status.wrappedValue.rawValue.capitalized).foregroundStyle(.gray600)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

        case let .storage(location, isRecommended, _):
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

        case let .readOnlyStorage(location, isRecommended):
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

        case let .quantity(quantity):
            VStack(alignment: .leading, spacing: 0) {
                Text("\(quantity.wrappedValue)").foregroundStyle(.gray600)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    @MainActor
    @ViewBuilder
    func overviewSwitch(isToggled: Binding<Bool>, customColor: Color? = nil) -> some View {
        switch self {
        case .expiry, .compactExpiry, .status, .storage, .readOnlyStorage:
            Toggle("Selected Expiry Date", isOn: isToggled)
                .toggleStyle(CheckToggleStyle(customColor: customColor))
                .labelsHidden()
                .disabled(true)
        case let .quantity(quantity):
            Stepper(value: quantity, in: 1...10, step: 1) {}.tint(.blue700)
        }
    }

    @MainActor
    @ViewBuilder
    func expandedContent(forceExpanded _: Bool) -> some View {
        switch self {
        case let .expiry(date, _, overriden):
            InventoryItemExpiryDateContent(expiryDate: date, overriden: overriden)
        case let .compactExpiry(date, _, expiryType):
            InventoryItemExpiryDateCompactContent(expiryDate: date, expiryType: expiryType)
        case let .status(status, overriden):
            IventoryItemStatusContent(status: status, overriden: overriden)
        case let .storage(location, _, overriden):
            InventoryItemStorageContent(storageLocation: location, overriden: overriden)
        case let .readOnlyStorage(location, _):
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
    @Binding var overriden: Overriden?

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

                Picker("Select inventory item status", selection: Binding(get: {
                    status
                }, set: { newValue in
                    status = newValue
                    overriden = .user
                })) {
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
    @Binding var overriden: Overriden?

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

                Picker("Select storage location", selection: Binding(get: {
                    storageLocation
                }, set: { newValue in
                    storageLocation = newValue
                    overriden = .user
                })) {
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
    @Binding var overriden: Overriden?

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
                    selection: Binding(get: {
                        expiryDate
                    }, set: { newValue in
                        expiryDate = newValue
                        overriden = .user
                    }),
                    displayedComponents: [.date])
                    .datePickerStyle(.graphical)
                    .tint(.blue700)
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
                    .datePickerStyle(.compact).labelsHidden().tint(.blue700)

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

    public init(
        type: InventoryItemFormType,
        storageLocation: StorageLocation,
        forceExpanded: Bool = false,
        customColor: (Color, Color)? = nil)
    {
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
