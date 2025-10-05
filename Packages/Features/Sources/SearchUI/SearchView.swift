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
            if !searchText.isEmpty {
                searchResults = ProductSearchItemResponse.mocks(count: 5)
                isLoading = true
            } else {
                searchResults = []
                isLoading = false
            }
            Task {
                await debounceSearch()
            }
        }
    }

    var debouncedSearchText: String = ""
    var searchResults: [ProductSearchItemResponse] = []
    var isLoading: Bool = false

    private var searchTask: Task<Void, Never>?

    private let onSaveSearch: (String, String?) -> Void

    init(onSaveSearch: @escaping (String, String?) -> Void) {
        self.onSaveSearch = onSaveSearch
    }

    private func debounceSearch() async {
        searchTask?.cancel()

        searchTask = Task {
            do {
                try await Task.sleep(for: .seconds(1))

                if !Task.isCancelled, debouncedSearchText != searchText {
                    debouncedSearchText = searchText
                    print("Debounced value: '\(searchText)'")

                    if !searchText.isEmpty {
                        await sendSearchRequest(searchTerm: searchText)
                    }
                }
            } catch {}
        }
    }

    private func sendSearchRequest(searchTerm: String) async {
        isLoading = true

        let api = KeepFreshAPI()

        do {
            let searchResponse = try await api.searchProducts(query: searchTerm)
            searchResults = searchResponse.products
            print("Search successful: Found \(searchResults.count) products")

            if let firstResult = searchResults.first(where: { $0.imageURL != nil }) {
                onSaveSearch(searchTerm, firstResult.imageURL)
            }

        } catch {
            print("Search failed with error: \(error)")
            searchResults = []
        }

        isLoading = false
    }
}

@MainActor
public struct SearchView: View {
    @Environment(\.modelContext) var modelContext

    @Query(sort: \RecentSearch.date, order: .reverse) var recentSearches: [RecentSearch]

    @State private var search: Search?
    @State private var currentPage: Int = 0
    @State private var dragOffset: CGFloat = 0
    @State private var canDrag: Bool = true
    @Namespace private var animationNamespace

    public init() {
        UIScrollView.appearance().bounces = false
    }

    private func saveRecentSearch(text: String, imageURL: String?) {
        let existingSearch = recentSearches.first(where: { $0.text.lowercased() == text.lowercased() })

        guard existingSearch == nil else {
            existingSearch?.date = Date()
            return
        }

        let recentSearch = RecentSearch(
            imageURL: imageURL,
            text: text,
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
            if isSearching, let search = search {
                SearchResultView(products: search.searchResults, isLoading: search.isLoading)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                RecentSearchView(searchText: searchTextBinding)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .task {
            if search == nil {
                search = Search(onSaveSearch: saveRecentSearch)
            }
        }
        .searchable(text: searchTextBinding)
    }
}
