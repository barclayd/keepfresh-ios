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

struct ConsumableCategoryOverview: View {
    @Binding var isExpiryDateToggled: Bool

    let details: ConsumableCategoryDetails

    var body: some View {
        Image(systemName: "hourglass")
            .font(.system(size: 21))
            .fontWeight(.bold)
            .foregroundColor(.blue800)
            .frame(width: 40, height: 40)
            .background(Circle().fill(.blue200))

        Text(details.title)
            .fontWeight(.bold)
            .foregroundStyle(.blue800)
            .font(.headline)
            .lineLimit(1)
            .frame(width: 105, alignment: .leading)

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

        Spacer()

        Toggle("Selected Expiry Date", isOn: $isExpiryDateToggled)
            .toggleStyle(CheckToggleStyle())
            .labelsHidden()
    }
}

struct ConsumableCategoryContent: View {
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

                Text("22nd December")
                    .foregroundStyle(.gray600)
                    .font(.callout)
                    .lineLimit(1)
                    .frame(width: 150, alignment: .leading)

                Spacer()
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

struct ConsumableCategoryDetails {
    let title: String
}

public struct ConsumableCategory: View {
    @Binding var isExpandedToggled: Bool
    @Binding var isExpiryDateToggled: Bool

    let details: ConsumableCategoryDetails

    public var body: some View {
        VStack(spacing: 0) {
            HStack {
                ConsumableCategoryOverview(isExpiryDateToggled: $isExpiryDateToggled, details: details)
            }.padding(.vertical, 14).padding(.horizontal, 10).frame(maxWidth: .infinity).background(UnevenRoundedRectangle(cornerRadii: RectangleCornerRadii(topLeading: 20, bottomLeading: isExpandedToggled ? 0 : 20, bottomTrailing: isExpandedToggled ? 0 : 20, topTrailing: 20)).fill(.gray200))
            if isExpandedToggled {
                ConsumableCategoryContent()
            }
        }.transition(.move(edge: .top)).onTapGesture {
            withAnimation(.easeInOut) {
                isExpandedToggled.toggle()
            }
        }
    }
}
