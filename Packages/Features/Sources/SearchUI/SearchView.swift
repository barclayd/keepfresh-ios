import DesignSystem
import Router
import SwiftUI

let searchTabItems = ["All", "Foods", "Categories", "My Foods"]

@MainActor
public struct SearchView: View {
    @State var searchText: String = ""
    @State private var currentPage: Int = 0
    @State private var dragOffset: CGFloat = 0

    @State private var canDrag: Bool = true
    @Namespace private var animationNamespace

    public init() {
        UIScrollView.appearance().bounces = false
    }

    private var isSearching: Bool {
        !searchText.isEmpty
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
                                    .foregroundStyle(.blue800)
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
//                        ScrollView {
//                            VStack {
//                                Spacer()
//                                Text(searchTabItems[index])
//                                    .foregroundStyle(.blue800)
//                                    .fontWeight(.bold)
//                                    .font(.headline)
//                            }
//                        }
                        SearchResultView()
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .onChange(of: currentPage) { _, _ in
                    canDrag = false
                    withAnimation(.smooth) {
                        dragOffset = 0
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        canDrag = true
                    }
                }
                .simultaneousGesture(canDrag ?
                    DragGesture()
                    .onChanged { value in
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
                RecentSearchView(searchText: $searchText)
            }
        }
        .navigationBarSearch(searchText: $searchText)
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

                func clearButtonImage() -> UIImage {
                    let image = UIImage(systemName: "xmark.circle.fill")
                    return image!.withTintColor(UIColor(.blue800), renderingMode: .alwaysOriginal)
                }

                UISearchTextField.appearance(whenContainedInInstancesOf: [UISearchBar.self])
                    .attributedPlaceholder = NSAttributedString(
                        string: "What do you want to track next?",
                        attributes: [.foregroundColor: UIColor(.white200)]
                    )

                UISearchBar.appearance(whenContainedInInstancesOf: [UINavigationBar.self]).setImage(
                    searchBarImage(), for: .search, state: .normal
                )
                UISearchBar.appearance(whenContainedInInstancesOf: [UINavigationBar.self]).setImage(
                    clearButtonImage(), for: .clear, state: .normal
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
