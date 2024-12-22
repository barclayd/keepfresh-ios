import DesignSystem
import SwiftUI

private struct RecentSearchItem: View {
    let previousSearchText: String
    let onTap: (String) -> Void
    let onDelete: () -> Void
    let colorConfiguration: ColorConfiguration

    struct ColorConfiguration {
        let text: Color
        let background: Color
        let closeIcon: Color
    }

    public var body: some View {
        Button(action: {
            onTap(previousSearchText)
        }) {
            HStack(spacing: 10) {
                Image(systemName: "waterbottle.fill")
                    .font(.system(size: 35))
                Text(previousSearchText)
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
                .padding(.trailing, 10)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal, 10)
        .padding(.vertical, 10)
        .background(RoundedRectangle(cornerRadius: 20).fill(colorConfiguration.background).onTapGesture(count: 1, perform: {
            onTap(previousSearchText)
        }))
        .frame(maxWidth: .infinity)
    }
}

public struct RecentSearchView: View {
    @Binding var searchText: String

    public var body: some View {
        ScrollView {
            VStack(spacing: 15) {
                HStack {
                    Text("Recent Searches" + searchText)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(.black)
                    Spacer()
                }.padding(.top, 20).padding(.bottom, 5)

                ForEach(0 ..< 20) { _ in
                    RecentSearchItem(
                        previousSearchText: "Semi Skimmed Mik",
                        onTap: { previousSearchText in
                            searchText = previousSearchText
                        },
                        onDelete: { print("delete") },
                        colorConfiguration: .init(
                            text: .blue800,
                            background: .red200,
                            closeIcon: .blue400
                        )
                    )
                }
            }
            .padding(.horizontal).padding(.bottom, 30)
        }
    }
}
