import DesignSystem
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

private extension ConsumableCategoryType {
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

private extension ConsumableCategoryType {
    @ViewBuilder
    func overviewLabel(quantity: Binding<Int>) -> some View {
        switch self {
        case .ExpiryDate:
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 0) {
                    Text("22nd December").foregroundStyle(.gray600)
                    Image(systemName: "sparkles").font(.system(size: 16)).foregroundColor(.yellow500)
                        .offset(y: -8)
                }
                Text("Expires in 7 days").foregroundStyle(.black800).font(.footnote).fontWeight(
                    .thin)
            }
            .frame(width: 150, alignment: .leading)

        case .Status:
            VStack(alignment: .leading, spacing: 0) {
                Text("Unopened").foregroundStyle(.gray600)
            }
            .frame(width: 150, alignment: .leading)

        case .Storage:
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .lastTextBaseline, spacing: 0) {
                    Image(systemName: "refrigerator").font(.system(size: 24)).foregroundStyle(.gray600).padding(.trailing, 2)
                    Text("Fridge").foregroundStyle(.gray600)
                    Image(systemName: "sparkles").font(.system(size: 16)).foregroundColor(.yellow500)
                        .offset(y: -8)
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

//    @ViewBuilder
//    func contentAction() -> some View {
//        switch self {
//        case .ExpiryDate:
//            Text("Select Expiry Date")
//        }
//    }
}

struct ConsumableCategoryOverview: View {
    @Binding var isExpiryDateToggled: Bool
    @Binding var quantity: Int

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

        type.overviewLabel(quantity: $quantity)

        Spacer()

        type.overviewSwitch(isToggled: $isExpiryDateToggled, quantity: $quantity)
    }
}

struct ConsumableCategoryContent: View {
    @State private var date = Date()
    @State private var showDatePicker = false

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "calendar.badge.exclamationmark")
                    .font(.system(size: 21))
                    .fontWeight(.bold)
                    .foregroundColor(.blue800)
                    .frame(width: 40, height: 40)

                Text("Expiry date")
                    .foregroundStyle(.blue800)
                    .font(.callout)
                    .lineLimit(1)
                    .frame(width: 105, alignment: .leading)

                Button(action: { showDatePicker.toggle() }) {
                    Text(date.formatted(date: .long, time: .omitted))
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
                    selection: $date,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical).colorInvert().colorMultiply(.blue800)
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

                Text("Use By")
                    .foregroundStyle(.gray600)
                    .font(.callout)
                    .lineLimit(1)
                    .frame(width: 150, alignment: .leading)

                Spacer()
            }
        }.padding(.vertical, 10).padding(.horizontal, 10).frame(maxWidth: .infinity).background(UnevenRoundedRectangle(cornerRadii: RectangleCornerRadii(topLeading: 0, bottomLeading: 20, bottomTrailing: 20, topTrailing: 0)).fill(.white))
    }
}

public struct ConsumableCategory: View {
    @State private var isExpandedToggled: Bool = false
    @State private var quantity: Int = 1

    let type: ConsumableCategoryType

    public var body: some View {
        VStack(spacing: 0) {
            HStack {
                ConsumableCategoryOverview(isExpiryDateToggled: $isExpandedToggled, quantity: $quantity, type: type)
            }.padding(.vertical, 14).padding(.horizontal, 10)
                .frame(maxWidth: .infinity)
                .background(UnevenRoundedRectangle(cornerRadii: RectangleCornerRadii(topLeading: 20, bottomLeading: isExpandedToggled ? 0 : 20, bottomTrailing: isExpandedToggled ? 0 : 20, topTrailing: 20)).fill(.gray200))
                .onTapGesture {
                    withAnimation(.easeInOut) {
                        isExpandedToggled.toggle()
                    }
                }
            if isExpandedToggled {
                ConsumableCategoryContent()
            }
        }.transition(.move(edge: .top))
    }
}
