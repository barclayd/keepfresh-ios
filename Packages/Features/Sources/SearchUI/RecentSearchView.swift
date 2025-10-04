import DesignSystem
import Models
import SwiftData
import SwiftUI

public struct RecentSearchItem: View {
    let search: RecentSearch
    let onTap: (String) -> Void
    let onDelete: () -> Void
    let colorConfiguration: ColorConfiguration

    struct ColorConfiguration {
        let text: Color
        let background: Color
        let closeIcon: Color
    }

    public var body: some View {
        Button(action: { onTap(search.text) }) {
            HStack {
                HStack(spacing: 10) {
                    if let imageURL = search.imageURL {
                        AsyncImage(url: URL(string: imageURL)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 35, height: 35)
                    }

                    Text(search.text)
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
                    .contentShape(RoundedRectangle(cornerRadius: 20)))
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

public struct RecentSearchView: View {
    @Environment(\.modelContext) var modelContext

    @Query(sort: \RecentSearch.date, order: .reverse) var recentSearches: [RecentSearch]

    @Binding var searchText: String

    private func deleteRecentSearch(at offsets: IndexSet) {
        for offset in offsets {
            let recentSearch = recentSearches[offset]
            modelContext.delete(recentSearch)
        }
    }

    private func deleteRecentSearch(_ recentSearch: RecentSearch) {
        modelContext.delete(recentSearch)
    }

    public var body: some View {
        List {
            HStack {
                Text("Recent Searches")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(.black)
                Spacer()
            }.padding(.top, 10)

            ForEach(recentSearches) { recentSearch in
                RecentSearchItem(
                    search: recentSearch,
                    onTap: { previousSearchText in
                        searchText = previousSearchText
                    },
                    onDelete: { deleteRecentSearch(recentSearch) },
                    colorConfiguration: .init(
                        text: .blue700,
                        background: .red200,
                        closeIcon: .blue400))
                    .listRowInsets(EdgeInsets(
                        top: 5,
                        leading: 10,
                        bottom: 5,
                        trailing: 10))
            }
            .onDelete(perform: deleteRecentSearch)
            .listRowSeparator(.hidden)
        }
        .frame(maxWidth: .infinity)
        .listStyle(.plain)
    }
}
