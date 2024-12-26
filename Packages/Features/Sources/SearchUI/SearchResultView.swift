import DesignSystem
import Models
import Router
import SwiftUI

@MainActor let grocerySearchItem: GrocerySearchItem = .init(id: UUID(), icon: "waterbottle.fill", name: "Semi Skimmed Milk", category: "Dairy", brand: "Sainburys", amount: 4, unit: "pints")

public struct SearchResultCard: View {
    public var body: some View {
        VStack(alignment: .center, spacing: 0) {
            HStack {
                Image(systemName: grocerySearchItem.icon)
                    .font(.system(size: 28)).foregroundStyle(.white200)
                Text(grocerySearchItem.name)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(.blue800)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
                Image(systemName: "plus")
                    .font(.system(size: 14))
                    .fontWeight(.bold)
                    .foregroundColor(.white200)
                    .frame(width: 28, height: 28)
                    .background(Circle().fill(.blue800))
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 10)
            .background(.blue400)
            .cornerRadius(20)

            VStack {
                HStack {
                    Text(grocerySearchItem.category)
                        .font(.subheadline).foregroundStyle(.gray500)
                    Spacer()
                }
                HStack {
                    Text(grocerySearchItem.brand)
                        .font(.subheadline)
                        .foregroundStyle(.brandSainsburys)
                    Circle()
                        .frame(width: 4, height: 4)
                        .foregroundStyle(.blue800)
                    Text("\(String(format: "%.0f", grocerySearchItem.amount)) \(grocerySearchItem.unit)").foregroundStyle(.gray500)
                        .font(.subheadline)
                    Spacer()
                    Image(systemName: "clock")
                        .font(.system(size: 16))
                        .foregroundStyle(.blue800)
                }
            }.padding(.horizontal, 5).padding(10).padding(.bottom, 5)
                .background(
                    UnevenRoundedRectangle(
                        topLeadingRadius: 0,
                        bottomLeadingRadius: 20,
                        bottomTrailingRadius: 20,
                        topTrailingRadius: 0,
                        style: .continuous
                    ).fill(.white)
                )
        }
        .background(.blue400)
        .cornerRadius(20)
        .shadow(color: .shadow, radius: 2, x: 0, y: 4)
    }
}

public struct SearchResultView: View {
    public var body: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                ForEach(0 ..< 20) { _ in
                    NavigationLink(value: RouterDestination.addGroceryItem(grocerySearchItem: grocerySearchItem)) {
                        SearchResultCard()
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }.padding(.top, 15)
                .padding(.horizontal, 16)
        }
    }
}
