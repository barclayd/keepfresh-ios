import DesignSystem
import Router
import SwiftUI

let searchTabItems = ["All", "Foods", "Categories", "My Foods"]

@MainActor
public struct SearchView: View {
    @State var searchText: String = ""
    @State var currentPage: Int = 0
    @State private var previousPage: Int = 0

    @State private var dragOffset: CGFloat = 0
    @Namespace private var animationNamespace

    public init() {
        UIScrollView.appearance().bounces = false
    }

    private var isSearching: Bool {
        !searchText.isEmpty
    }

    private func calculateIndicatorOffset(geometry: GeometryProxy) -> CGFloat {
        let screenWidth = geometry.size.width
        let offsetPerTab = screenWidth / 2
        return offsetPerTab * CGFloat(currentPage) - (dragOffset / screenWidth * offsetPerTab)
    }

    public var body: some View {
        ScrollViewReader { _ in
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
                            VStack {
                                Spacer()
                                Text(searchTabItems[index])
                                    .foregroundStyle(.blue800)
                                    .fontWeight(.bold)
                                    .font(.headline)
                            }
                            .tag(index)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .simultaneousGesture(
                        DragGesture()
                            .onChanged { value in
                                let screenWidth = UIScreen.main.bounds.width
                                let tabWidth = screenWidth / CGFloat(searchTabItems.count)
                                let translation = value.translation.width

                                let progress = -translation / screenWidth

                                // If we've moved past 50% and the page has changed, reset the offset
                                if abs(progress) > 0.5, currentPage != Int(round(progress)) {
                                    dragOffset = 0
                                } else {
                                    let capsuleOffset = progress * tabWidth
                                    dragOffset = capsuleOffset
                                }
                            }
                            .onEnded { _ in
                                dragOffset = 0
                            }
                    )
                } else {
                    Text("Recent Searches" + searchText).font(.headline).fontWeight(.bold).foregroundStyle(.black)
                    Spacer()
                }
            }
            .navigationBarSearch(searchText: $searchText)
        }
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
