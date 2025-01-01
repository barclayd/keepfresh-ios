import DesignSystem
import SwiftUI

public struct RecentSearchItem: View {
    let currentSearchText: String
    let onTap: (String) -> Void
    let onDelete: () -> Void
    let colorConfiguration: ColorConfiguration

    struct ColorConfiguration {
        let text: Color
        let background: Color
        let closeIcon: Color
    }

    public var body: some View {
        Button(action: { onTap(currentSearchText) }) {
            HStack {
                HStack(spacing: 10) {
                    Image(systemName: "waterbottle.fill")
                        .font(.system(size: 35))
                    Text(currentSearchText)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(colorConfiguration.text)
                    Spacer()
                    Button(action: onDelete) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18))
                            .foregroundStyle(colorConfiguration.closeIcon)
                            .fontWeight(.bold)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.trailing, 10)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(colorConfiguration.background)
                    .contentShape(RoundedRectangle(cornerRadius: 20))
            )
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

public struct RecentSearchView: View {
    @Binding var searchText: String

    public var body: some View {
        List {
            HStack {
                Text("Recent Searches" + searchText)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(.black)
                Spacer()
            }.padding(.top, 10)

            ForEach(0 ..< 20) { _ in
                RecentSearchItem(
                    currentSearchText: "Semi Skimmed Milk",
                    onTap: { previousSearchText in
                        searchText = previousSearchText
                    },
                    onDelete: { print("delete") },
                    colorConfiguration: .init(
                        text: .blue700,
                        background: .red200,
                        closeIcon: .blue400
                    )
                ).listRowInsets(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
            }
            .listRowSeparator(.hidden)
        }.frame(maxWidth: .infinity).listStyle(.plain)
    }
}
