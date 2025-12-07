import DesignSystem
import Models
import Network
import SharedUI
import SwiftData
import SwiftUI

public struct RecentConsumedItem: View {
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
                    GenmojiView(name: search.icon, fontSize: 35, tint: colorConfiguration.background)

                    Text(search.text)
                        .font(.subheadline)
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

public struct ShoppingSearchView: View {
    @Environment(\.modelContext) var modelContext

    @Query(sort: \RecentSearch.date, order: .reverse) var recentSearches: [RecentSearch]

    @Binding var searchText: String

    @State private var recentlyConsumedInventoryItems: [InventoryItem] = []
    @State private var seenProductIds: Set<Int> = []
    @State private var isLoadingMore = false
    @State private var hasMoreData = true

    private func deleteRecentSearch(at offsets: IndexSet) {
        for offset in offsets {
            let recentSearch = recentSearches[offset]
            modelContext.delete(recentSearch)
        }
    }

    private func deleteRecentSearch(_ recentSearch: RecentSearch) {
        modelContext.delete(recentSearch)
    }

    private func loadMoreItems() async {
        guard !isLoadingMore, hasMoreData else { return }
        guard let lastItem = recentlyConsumedInventoryItems.last else { return }

        isLoadingMore = true
        defer { isLoadingMore = false }

        let api = KeepFreshAPI()
        do {
            let newItems = try await api.getInventoryHistory(cursor: lastItem.updatedAt)
            if newItems.isEmpty {
                hasMoreData = false
            } else {
                for item in newItems {
                    if seenProductIds.insert(item.product.id).inserted {
                        recentlyConsumedInventoryItems.append(item)
                    }
                }
            }
        } catch {}
    }

    public var body: some View {
        if !recentlyConsumedInventoryItems.isEmpty {
            HStack {
                Text("Recent items")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(.blue800)
                Spacer()
            }.padding(.horizontal, 20).padding(.bottom, 10)

            ScrollView(.horizontal) {
                LazyHStack(spacing: 10) {
                    ForEach(recentlyConsumedInventoryItems) { recentlyConsumedInventoryItem in
                        Tile(recentlyConsumedInventoryItem: recentlyConsumedInventoryItem)
                            .padding(.horizontal, 5)
                            .onAppear {
                                if recentlyConsumedInventoryItem.id == recentlyConsumedInventoryItems.last?.id,
                                   hasMoreData,
                                   !isLoadingMore
                                {
                                    Task {
                                        await loadMoreItems()
                                    }
                                }
                            }
                    }

                    if isLoadingMore {
                        ProgressView()
                            .padding(.horizontal, 20)
                    }
                }.padding(.vertical, 8)
            }
            .scrollIndicators(.hidden)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, 10)
        }

        List {
            HStack {
                Text("Recent searches")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(.blue800)
                Spacer()
            }.padding(.top, 10)

            ForEach(recentSearches) { recentSearch in
                RecentConsumedItem(
                    search: recentSearch,
                    onTap: { previousSearchText in
                        searchText = previousSearchText
                    },
                    onDelete: { deleteRecentSearch(recentSearch) },
                    colorConfiguration: RecentConsumedItem.ColorConfiguration(
                        text: recentSearch.recommendedStorageLocation.textColor,
                        background: recentSearch.recommendedStorageLocation.tileColor,
                        closeIcon: recentSearch.recommendedStorageLocation.textColor))
                    .listRowInsets(EdgeInsets(
                        top: 5,
                        leading: 10,
                        bottom: 5,
                        trailing: 10))
            }
            .onDelete(perform: deleteRecentSearch)
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
        }
        .frame(maxWidth: .infinity)
        .listStyle(.plain)
        .task {
            let api = KeepFreshAPI()

            do {
                let items = try await api.getInventoryHistory()
                seenProductIds.removeAll()
                recentlyConsumedInventoryItems.removeAll()
                for item in items {
                    if seenProductIds.insert(item.product.id).inserted {
                        recentlyConsumedInventoryItems.append(item)
                    }
                }
            } catch {
                recentlyConsumedInventoryItems = []
            }
        }
    }
}
