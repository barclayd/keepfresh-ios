import SwiftUI

struct GroceryItemSheetStatsGridRows: View {
    var body: some View {
        Group {
            GridRow {
                VStack(spacing: 0) {
                    Text("3").fontWeight(.bold).font(.headline)
                    Text("Days to expiry").fontWeight(.light).font(.subheadline).lineLimit(1)
                }
                Image(systemName: "hourglass")
                    .font(.system(size: 28)).fontWeight(.bold)
                    .foregroundStyle(.black800)
                Image(systemName: "percent")
                    .font(.system(size: 28)).fontWeight(.bold)
                    .foregroundStyle(.black800)
                VStack(spacing: 0) {
                    Text("17").fontWeight(.bold).font(.headline)
                    Text("Waste score").fontWeight(.light).font(.subheadline)
                }
            }
            GridRow {
                Text("Fridge").fontWeight(.bold).font(.headline)
                Image(systemName: "refrigerator")
                    .font(.system(size: 28)).fontWeight(.bold)
                    .foregroundStyle(.black800)
                Image(systemName: "circle.bottomrighthalf.pattern.checkered")
                    .font(.system(size: 28)).fontWeight(.bold)
                    .foregroundStyle(.black800)
                Text("Sainsburys").fontWeight(.bold).foregroundStyle(.brandSainsburys).font(.headline).lineLimit(1)
            }
        }
    }
}

struct GroceryItemSheetStatsGrid: View {
    let groceryItem: GroceryItem

    var body: some View {
        ViewThatFits(in: .horizontal) {
            Grid(horizontalSpacing: 30, verticalSpacing: 10) {
                GroceryItemSheetStatsGridRows()
            }
            Grid(horizontalSpacing: 20, verticalSpacing: 10) {
                GroceryItemSheetStatsGridRows()
            }
            Grid(horizontalSpacing: 10, verticalSpacing: 10) {
                GroceryItemSheetStatsGridRows()
            }
        }.padding().frame(maxWidth: .infinity, alignment: .center).padding(.horizontal, 10).background(.white300).cornerRadius(20)
    }
}

struct GroceryItemSheetView: View {
    @Binding var groceryItem: GroceryItem?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        guard let groceryItem: GroceryItem = groceryItem else {
            return EmptyView()
        }

        return VStack {
            HStack {
                Button("Close") {
                    dismiss()
                }
                .buttonStyle(.borderless)
                .padding(.horizontal, 25)
                .foregroundStyle(.black800)
                .font(.callout)
                .fontWeight(.bold)
                .padding(.vertical, 8)
                .background(.gray100)
                .cornerRadius(50)
                Spacer()
            }.padding(.top, 5)
            Image(systemName: groceryItem.icon)
                .font(.system(size: 98))
            Text(groceryItem.name).font(.title).fontWeight(.bold).foregroundStyle(.black)
            HStack {
                Text(groceryItem.category)
                    .font(.callout)
                    .foregroundStyle(.gray600)
                Circle()
                    .frame(width: 4, height: 4)
                    .foregroundStyle(.gray600)
                Text("\(String(format: "%.0f", groceryItem.amount)) \(groceryItem.unit)")
                    .font(.callout)
                    .foregroundStyle(.gray600)
            }
            GroceryItemSheetStatsGrid(groceryItem: groceryItem)
        }.padding(.horizontal, 10).frame(maxWidth: .infinity, alignment: .center).padding(.horizontal, 10)
    }
}
