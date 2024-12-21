import SwiftUI

public struct SearchView: View {
    public init(searchText: Binding<String>) {
        _searchText = searchText
    }

    @Binding var searchText: String

    public var body: some View {
        VStack {
            Text("Recent Searches" + searchText).font(.headline).fontWeight(.bold).foregroundStyle(.black)
        }
    }
}
