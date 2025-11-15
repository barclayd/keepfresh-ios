import DesignSystem
import Models
import SwiftUI

public struct ShoppingView: View {
    @State private var currentPage: Int = 3
    
    public init() {}
    
    var shoppingListTabs: [String] {
        ["Fri 31st Oct", "Fri 7th", "Last Shop", "Today", "Tomorrow", "Mon 17th", "Mon 24th"]
    }
    
    public var body: some View {
        VStack {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(0 ..< shoppingListTabs.count, id: \.self) { index in
                        Spacer()
                        Button {
                            withAnimation(.smooth(duration: 0.3)) {
                                currentPage = index
                            }
                        } label: {
                            Text(shoppingListTabs[index])
                                .fontWeight(.bold)
                                .font(.subheadline)
                                .foregroundStyle(.blue700)
                                .opacity(currentPage == index ? 1 : 0.5)
                                .fixedSize(horizontal: true, vertical: false)
                        }
                    }
                }.frame(maxWidth: .infinity)
            }
            
            TabView(selection: $currentPage) {
                ForEach(0 ..< shoppingListTabs.count, id: \.self) { index in
                    ScrollView {
                        LazyVStack {
                            ForEach(StorageLocation.allCases) { storageLocation in
                                StorageLocationPanel(storageLocation: storageLocation)
                            }.tag(index)
                        }.padding(.horizontal, 12.5)
                            .padding(.top, 20)
                            .padding(.bottom, 10)
                    }
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.white200)
        }
    }
}
