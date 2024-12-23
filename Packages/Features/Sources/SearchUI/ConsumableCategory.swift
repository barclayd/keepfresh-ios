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

public struct ConsumableCategory: View {
    @Binding var isExpiryDateToggled: Bool

    public var body: some View {
        HStack {
            Image(systemName: "hourglass")
                .font(.system(size: 21))
                .fontWeight(.bold)
                .foregroundColor(.blue800)
                .frame(width: 40, height: 40)
                .background(Circle().fill(.blue200))

            Text("Expiry Date")
                .fontWeight(.bold)
                .foregroundStyle(.blue800)
                .font(.headline)
                .lineLimit(1)
                .padding(.trailing, 10)

            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 0) {
                    Text("22nd December").foregroundStyle(.gray600)
                    Image(systemName: "sparkles").font(.system(size: 16)).foregroundColor(.yellow500)
                        .offset(y: -10)
                }
                Text("Expires in 7 days").foregroundStyle(.black800).font(.footnote).fontWeight(
                    .thin)
            }
            .frame(width: 150, alignment: .leading)

            Spacer()

            Toggle("Selected Expiry Date", isOn: $isExpiryDateToggled)
                .toggleStyle(CheckToggleStyle())
                .labelsHidden()

        }.padding(.vertical, 14).padding(.horizontal, 10).frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 20).fill(.gray200)
            )
    }
}
