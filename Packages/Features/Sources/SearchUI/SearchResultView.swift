import DesignSystem
import Router
import SwiftUI

public struct SearchResultView: View {
    public var body: some View {
        List {
            ForEach(0 ..< 20) { _ in
                NavigationLink(value: RouterDestination.today) {
                    RecentSearchItem(
                        previousSearchText: "Semi Skimmed Mik",
                        onTap: { previousSearchText in
                            print(previousSearchText)
                        },
                        onDelete: { print("delete") },
                        colorConfiguration: .init(
                            text: .blue800,
                            background: .red200,
                            closeIcon: .blue400
                        )
                    )
                }
            }.listRowSeparator(.hidden)
        }.listStyle(.plain)
    }
}
