import DesignSystem
import Models
import Router
import SwiftUI

@MainActor let groceryItem: GroceryItem = .init(id: UUID(), icon: "waterbottle", name: "Semi Skimmed Milk", category: "Dairy", brand: "Sainburys", amount: 4, unit: "pints", foodStore: .fridge, status: .open, wasteScore: 17, expiryDate: Date())

public struct SearchResultCard: View {
    public var body: some View {
        VStack(alignment: .center, spacing: 0) {
            HStack {
                Image(systemName: groceryItem.icon)
                    .font(.system(size: 28)).foregroundStyle(.blue800)
                Text(groceryItem.name)
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
                    Text(groceryItem.category)
                        .font(.footnote).foregroundStyle(.gray600)
                    Spacer()
                }
                HStack {
                    Text(groceryItem.brand)
                        .font(.footnote)
                        .foregroundStyle(.brandSainsburys)
                    Circle()
                        .frame(width: 4, height: 4)
                        .foregroundStyle(.gray600)
                    Text("\(String(format: "%.0f", groceryItem.amount)) \(groceryItem.unit)").foregroundStyle(.gray600)
                        .font(.footnote)
                    Spacer()
                    Image(systemName: "clock")
                        .font(.system(size: 16))
                        .foregroundStyle(.blue800)
                }
            }.padding(.horizontal, 5).padding(10)
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
//        .padding(.bottom, 4)
//        .padding(.horizontal, 4)
        .background(.blue400)
        .cornerRadius(20)
        .shadow(color: .shadow, radius: 2, x: 0, y: 4)
    }
}

public struct SearchResultView: View {
    public var body: some View {
        List {
            ForEach(0 ..< 20) { _ in
                NavigationLink(value: RouterDestination.today) {
                    SearchResultCard()
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(PlainButtonStyle())
                .listRowInsets(EdgeInsets())
            }
            .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
        .frame(maxWidth: .infinity)
    }
}
