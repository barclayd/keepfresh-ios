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
            Grid(horizontalSpacing: 10, verticalSpacing: 10) {
                GroceryItemSheetStatsGridRows()
            }
        }.padding(.horizontal, 15).padding(.vertical, 5).frame(maxWidth: .infinity, alignment: .center).background(.white300).cornerRadius(20)
    }
}

struct GroceryItemSheetView: View {
    @Binding var groceryItem: GroceryItem?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        guard let groceryItem: GroceryItem = groceryItem else {
            return EmptyView()
        }

        return VStack(spacing: 10) {
            HStack {
                Button(action: {
                    dismiss()
                    UISelectionFeedbackGenerator.modalDismiss()
                }) {
                    Text("Close")
                        .foregroundStyle(.black800)
                        .font(.callout)
                        .fontWeight(.bold)
                        .padding(.horizontal, 25)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 50)
                                .fill(.gray100)
                        )
                }
                .buttonStyle(.borderless)
                Spacer()
            }
            Image(systemName: groceryItem.icon)
                .font(.system(size: 80)).padding(0)
            Text(groceryItem.name).font(.title).fontWeight(.bold).foregroundStyle(.black).lineSpacing(0).padding(.bottom, -8)
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
            GroceryItemSheetStatsGrid(groceryItem: groceryItem).padding(.vertical, 5)
            Grid(horizontalSpacing: 16, verticalSpacing: 20) {
                GridRow {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundStyle(.gold500)
                        .font(.system(size: 32))
                    Text("Great work, you're on track to finish this before it expires")
                        .font(.callout)
                        .foregroundStyle(.gray600)
                        .multilineTextAlignment(.center)
                    Spacer()
                }
                GridRow {
                    Image(systemName: "cart.circle.fill")
                        .foregroundStyle(.blue600)
                        .font(.system(size: 32))
                    Text("Based on food waste history for this item, you should buy this again")
                        .font(.callout)
                        .foregroundStyle(.gray600)
                        .multilineTextAlignment(.center)
                    Spacer()
                }
            }.padding(.vertical, 10)
            Button(action: {
                print("Mark as no waste")
            }) {
                HStack(spacing: 5) {
                    Text("Mark as no waste")
                        .font(.headline)
                    Image(systemName: "takeoutbag.and.cup.and.straw.fill")
                        .font(.system(size: 18))
                }
                .foregroundStyle(.blue600)
                .fontWeight(.bold)
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.green300)
                )
            }
            Button(action: {
                print("Mark as some waste")
            }) {
                HStack(spacing: 5) {
                    Text("Mark as no waste")
                        .font(.headline)
                    Image(systemName: "trash")
                        .font(.system(size: 18))
                }
                .foregroundStyle(.blue600)
                .fontWeight(.bold)
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.red200)
                )
            }
            Button(action: {
                print("Mark as opened")
            }) {
                HStack(spacing: 5) {
                    Text("Mark as opened")
                        .font(.headline)
                }
                .foregroundStyle(.blue600)
                .fontWeight(.bold)
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.gray200)
                )
            }
        }.padding(.horizontal, 10).frame(maxWidth: .infinity, alignment: .center).padding(.horizontal, 10)
    }
}
