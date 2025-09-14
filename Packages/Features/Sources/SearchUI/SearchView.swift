import Combine
import DesignSystem
import Models
import Router
import SwiftUI

let searchTabItems = ["All", "Foods", "Categories", "My Foods"]

struct SearchResponse: Codable {
    let products: [ProductSearchItem]
}

@MainActor
class SearchManager: ObservableObject {
    @Published var searchText: String = ""
    @Published var debouncedSearchText: String = ""
    @Published var searchResults: [ProductSearchItem] = []
    @Published var isLoading: Bool = false

    private var cancellables = Set<AnyCancellable>()

    init() {
        setupSearchDebounce()
    }

    private func setupSearchDebounce() {
        $searchText
            .debounce(for: .seconds(1), scheduler: RunLoop.main)
            .sink { [weak self] debouncedValue in
                self?.debouncedSearchText = debouncedValue
                print("Debounced value: '\(debouncedValue)'")

                if !debouncedValue.isEmpty {
                    Task { [weak self] in
                        await self?.sendSearchRequest(searchTerm: debouncedValue)
                    }
                }
            }
            .store(in: &cancellables)
    }

    private func sendSearchRequest(searchTerm: String) async {
        isLoading = true

        do {
            var urlComponents = URLComponents(string: "https://api.keepfre.sh/v1/products")!

            let parameters: [String: String] = [
                "search": searchTerm,
            ]

            urlComponents.queryItems = parameters.map { key, value in
                URLQueryItem(name: key, value: value)
            }

            guard let url = urlComponents.url else {
                isLoading = false
                return
            }

            let (data, _) = try await URLSession.shared.data(from: url)

            let searchResponse = try JSONDecoder().decode(SearchResponse.self, from: data)

            searchResults = searchResponse.products
            print("Search successful: Found \(searchResults.count) products")

        } catch {
            print("Search failed with error: \(error)")
            searchResults = []
        }

        isLoading = false
    }
}

@MainActor
public struct SearchView: View {
    @StateObject private var searchManager = SearchManager()
    @State private var currentPage: Int = 0
    @State private var dragOffset: CGFloat = 0
    @State private var canDrag: Bool = true
    @Namespace private var animationNamespace

    public init() {
        UIScrollView.appearance().bounces = false
    }

    private var isSearching: Bool {
        !searchManager.debouncedSearchText.isEmpty
    }

    public var body: some View {
        VStack(spacing: 0) {
            if isSearching {
                HStack(spacing: 0) {
                    ForEach(0 ..< searchTabItems.count, id: \.self) { index in
                        Spacer()
                        Button {
                            withAnimation(.smooth(duration: 0.3)) {
                                currentPage = index
                            }
                        } label: {
                            VStack(spacing: 3) {
                                Text(searchTabItems[index])
                                    .fontWeight(.bold)
                                    .font(.subheadline)
                                    .foregroundStyle(.blue700)
                                    .opacity(currentPage == index ? 1 : 0.5)
                                ZStack {
                                    Capsule()
                                        .fill(.clear)
                                        .frame(height: 4)
                                    if currentPage == index {
                                        Capsule(style: .continuous)
                                            .fill(.white)
                                            .frame(width: 30, height: 3)
                                            .offset(x: dragOffset)
                                            .transition(.slide)
                                            .matchedGeometryEffect(id: "indicator", in: animationNamespace)
                                    }
                                }
                            }.fixedSize(horizontal: true, vertical: false)
                        }
                        .buttonStyle(PlainButtonStyle())
                        Spacer()
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Rectangle().fill(.blue600))

                TabView(selection: $currentPage) {
                    ForEach(0 ..< searchTabItems.count, id: \.self) { index in
                        SearchResultView(products: searchManager.searchResults).frame(
                            maxWidth: .infinity, maxHeight: .infinity
                        )
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onChange(of: currentPage) { _, _ in
                    canDrag = false
                    withAnimation(.smooth) {
                        dragOffset = 0
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        canDrag = true
                    }
                }
                .simultaneousGesture(
                    canDrag
                        ? DragGesture(minimumDistance: 10)
                        .onChanged { value in
                            if abs(value.translation.height) > abs(value.translation.width) {
                                return // Ignore primarily vertical drags
                            }

                            let screenWidth = UIScreen.main.bounds.width
                            let tabWidth = screenWidth / CGFloat(searchTabItems.count)
                            let translation = value.translation.width
                            let progress = (-translation / screenWidth)

                            if (progress * tabWidth) > 57 || (progress * tabWidth) < -57 {
                                canDrag = false
                                withAnimation(.smooth) {
                                    dragOffset = 0
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                    canDrag = true
                                }
                            } else {
                                dragOffset = progress * tabWidth
                            }
                        }
                        .onEnded { _ in
                            withAnimation(.smooth) {
                                dragOffset = 0
                            }
                        }
                        : nil)
            } else {
                RecentSearchView(searchText: $searchManager.searchText)
            }
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationBarSearch(searchText: $searchManager.searchText)
    }
}

public extension View {
    func navigationBarSearch(searchText: Binding<String>) -> some View {
        modifier(NavigatationBarSearch(searchText: searchText))
    }
}

public struct NavigatationBarSearch: ViewModifier {
    @Binding var searchText: String
    @Environment(Router.self) var router

    public func body(content: Content) -> some View {
        switch router.selectedTab {
        case .search:
            content.searchable(
                text: $searchText,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "What do you want to track next?"
            )
            .onAppear {
                UISearchTextField.appearance().backgroundColor = .blue400
                UISearchTextField.appearance().tintColor = .white200

                UISearchTextField.appearance().borderStyle = .none
                UISearchTextField.appearance().layer.cornerRadius = 10

                UISearchTextField.appearance().attributedPlaceholder = NSAttributedString(
                    string: "What do you want to track next?",
                    attributes: [.foregroundColor: UIColor.gray200]
                )

                func searchBarImage() -> UIImage {
                    let image = UIImage(systemName: "magnifyingglass")
                    return image!.withTintColor(UIColor(.white200), renderingMode: .alwaysOriginal)
                }

                UISearchTextField.appearance(whenContainedInInstancesOf: [UISearchBar.self])
                    .attributedPlaceholder = NSAttributedString(
                        string: "What do you want to track next?",
                        attributes: [.foregroundColor: UIColor(.white200)]
                    )

                UISearchBar.appearance(whenContainedInInstancesOf: [UINavigationBar.self]).setImage(
                    searchBarImage(), for: .search, state: .normal
                )

                UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self])
                    .setTitleTextAttributes([.foregroundColor: UIColor.white400], for: .normal)
            }.foregroundColor(.white200)
        default:
            content
        }
    }
}

struct TabOffsetPreferenceKey: PreferenceKey {
    static let defaultValue: CGPoint = .zero
    static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {
        value = nextValue()
    }
}
