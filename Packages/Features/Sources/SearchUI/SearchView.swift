import DesignSystem
import Models
import Network
import Router
import SwiftData
import SwiftUI

@MainActor
@Observable
class Search {
    var searchText: String = "" {
        didSet {
            guard searchText != debouncedSearchText, searchText != lastSearchedTerm else {
                return
            }

            state = .loading
            currentPage = 1
            hasMorePages = false

            Task {
                await debounceSearch()
            }
        }
    }

    var debouncedSearchText: String = ""
    var searchResults: [ProductSearchResultItemResponse] = []
    var state: FetchState = .empty
    var lastSearchedTerm = ""
    var currentPage = 1
    var hasMorePages = false
    var isLoadingMore = false

    private var searchTask: Task<Void, Never>?

    private let onSaveSearch: (String, StorageLocation, String?) -> Void

    init(onSaveSearch: @escaping (String, StorageLocation, String?) -> Void) {
        self.onSaveSearch = onSaveSearch
    }

    public func debounceSearch(shouldWait: Bool = true) async {
        searchTask?.cancel()

        searchTask = Task {
            do {
                if shouldWait {
                    try await Task.sleep(for: .seconds(1))
                }

                if !Task.isCancelled, debouncedSearchText != searchText, searchText != lastSearchedTerm, searchText != "" {
                    debouncedSearchText = searchText
                    print("Debounced value: '\(debouncedSearchText)'")

                    if !searchText.isEmpty {
                        searchResults = ProductSearchResultItemResponse.mocks(count: 5)
                        await sendSearchRequest(searchTerm: debouncedSearchText)
                    }
                } else {
                    state = .loaded
                }
            } catch {}
        }
    }

    private func sendSearchRequest(searchTerm: String) async {
        state = .loading

        let api = KeepFreshAPI()

        do {
            let searchResponse = try await api.searchProducts(query: searchTerm, page: currentPage)
            searchResults = searchResponse.results
            hasMorePages = searchResponse.pagination.hasNext

            state = .loaded
            lastSearchedTerm = searchTerm

            print("Search successful: Found \(searchResults.count) products")

            let (locationCounts, iconCounts) = searchResults.prefix(10).reduce(into: (
                [StorageLocation: Int](),
                [String: Int]()))
            { result, item in
                result.0[item.category.recommendedStorageLocation, default: 0] += 1

                result.1[item.icon, default: 0] += 1
            }

            let mostCommonStorageLocation = locationCounts.max(by: { $0.value < $1.value })?.key
            let mostCommonIcon = iconCounts.max(by: { $0.value < $1.value })?.key

            if let storageLocation = mostCommonStorageLocation {
                onSaveSearch(searchTerm, storageLocation, mostCommonIcon)
            }

        } catch {
            print("Search failed with error: \(error)")
            searchResults = []
            state = .error
            lastSearchedTerm = ""
        }
    }

    func loadMoreResults() async {
        guard hasMorePages, !isLoadingMore, state == .loaded else { return }

        isLoadingMore = true
        currentPage += 1

        let api = KeepFreshAPI()

        do {
            let searchResponse = try await api.searchProducts(query: lastSearchedTerm, page: currentPage)
            searchResults.append(contentsOf: searchResponse.results)
            hasMorePages = searchResponse.pagination.hasNext

            print("Loaded more results: Now have \(searchResults.count) total products")
        } catch {
            print("Failed to load more results: \(error)")
            currentPage -= 1
        }

        isLoadingMore = false
    }
}

@MainActor
public struct SearchView: View {
    @Environment(\.modelContext) var modelContext

    @Query(sort: \RecentSearch.date, order: .reverse) var recentSearches: [RecentSearch]

    @State private var search: Search?

    public init() {
        UIScrollView.appearance().bounces = false
    }

    private func saveRecentSearch(text: String, recommendedStorageLocation: StorageLocation, icon: String?) {
        let existingSearch = recentSearches.first(where: { $0.text.lowercased() == text.lowercased() })

        guard existingSearch == nil else {
            existingSearch?.date = Date()
            return
        }

        let recentSearch = RecentSearch(
            icon: icon,
            text: text,
            recommendedStorageLocation: recommendedStorageLocation,
            date: Date())
        modelContext.insert(recentSearch)

        do {
            try modelContext.save()
        } catch {
            print("Failed to save search: \(error)")
        }
    }

    private var isSearching: Bool {
        guard let searchText = search?.searchText else {
            return false
        }
        return !searchText.isEmpty
    }

    private var searchTextBinding: Binding<String> {
        Binding(
            get: { search?.searchText ?? "" },
            set: { search?.searchText = $0 })
    }

    public var body: some View {
        VStack(spacing: 0) {
            if isSearching, let search {
                SearchResultView(
                    searchProducts: search.searchResults,
                    isLoading: search.state != .loaded,
                    hasMorePages: search.hasMorePages,
                    isLoadingMore: search.isLoadingMore,
                    onLoadMore: {
                        Task {
                            await search.loadMoreResults()
                        }
                    })
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                RecentSearchView(searchText: searchTextBinding)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.white100)
        .task {
            if search == nil {
                search = Search(onSaveSearch: saveRecentSearch)
            }
        }
        .searchable(text: searchTextBinding)
        .onSubmit(of: .search) {
            Task {
                guard search?.state != .loading else { return }
                await search?.debounceSearch(shouldWait: false)
            }
        }
    }
}
