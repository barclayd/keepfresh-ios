import Models
import SwiftUI

struct GroceryItemSheetStatsGridRows: View {
    let pageIndex: Int

    var body: some View {
        if pageIndex == 0 {
            return Group {
                GridRow {
                    VStack(spacing: 0) {
                        Text("3").fontWeight(.bold).font(.headline)
                        Text("Days to expiry").fontWeight(.light).font(.subheadline).lineLimit(1)
                    }
                    Image(systemName: "hourglass")
                        .font(.system(size: 28)).fontWeight(.bold)
                        .foregroundStyle(.blue)
                    Image(systemName: "percent")
                        .font(.system(size: 28)).fontWeight(.bold)
                        .foregroundStyle(.blue)
                    VStack(spacing: 0) {
                        Text("17").fontWeight(.bold).font(.headline)
                        Text("Waste score").fontWeight(.light).font(.subheadline)
                    }
                }
                GridRow {
                    Text("Fridge").fontWeight(.bold).font(.headline)
                    Image(systemName: "refrigerator")
                        .font(.system(size: 28)).fontWeight(.bold)
                        .foregroundStyle(.blue)
                    Image(systemName: "circle.bottomrighthalf.pattern.checkered")
                        .font(.system(size: 28)).fontWeight(.bold)
                        .foregroundStyle(.blue)
                    Text("Sainsburys").fontWeight(.bold).foregroundStyle(.blue).font(.headline).lineLimit(1)
                }
            }
        }

        return Group {
            GridRow {
                VStack(spacing: 0) {
                    Text("3").fontWeight(.bold).font(.headline)
                    Text("Days since added").fontWeight(.light).font(.subheadline).lineLimit(1)
                }
                Image(systemName: "calendar.badge.plus")
                    .font(.system(size: 32)).fontWeight(.bold)
                    .foregroundStyle(.blue)
                VStack(spacing: 0) {
                    Text("3").fontWeight(.bold).font(.headline)
                    Text("Days since opened").fontWeight(.light).font(.subheadline)
                }
            }
            GridRow {
                VStack(spacing: 0) {
                    Text("2").fontWeight(.bold).font(.headline)
                    Text("Located in Fridge").fontWeight(.light).font(.subheadline).lineLimit(1)
                }
                Image(systemName: "house")
                    .font(.system(size: 32)).fontWeight(.bold)
                    .foregroundStyle(.blue)
                VStack(spacing: 0) {
                    Text("3").fontWeight(.bold).font(.headline)
                    Text("Located in Freezer").fontWeight(.light).font(.subheadline)
                }
            }
        }
    }
}

struct GroceryItemSheetStatsGrid: View {
    let groceryItem: GroceryItem

    let pageIndex: Int

    var body: some View {
        ViewThatFits(in: .horizontal) {
            Grid(horizontalSpacing: 30, verticalSpacing: 10) {
                GroceryItemSheetStatsGridRows(pageIndex: pageIndex)
            }
            Grid(horizontalSpacing: 10, verticalSpacing: 10) {
                GroceryItemSheetStatsGridRows(pageIndex: pageIndex)
            }
        }.padding(.horizontal, 15).padding(.vertical, 5).frame(maxWidth: .infinity, alignment: .center).background(.blue).cornerRadius(20)
    }
}

public struct GroceryItemSheetView: View {
    @Binding var groceryItem: GroceryItem?
    @Environment(\.dismiss) private var dismiss

    @State private var currentPage = 0

    init(groceryItem: Binding<GroceryItem?>) {
        _groceryItem = groceryItem

        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(.blue)
        UIPageControl.appearance().pageIndicatorTintColor = UIColor(.blue)
    }

    public var body: some View {
        guard let groceryItem: GroceryItem = groceryItem else {
            return EmptyView()
        }

        return VStack(spacing: 10) {
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 24))
                        .foregroundStyle(.blue)
                }
                Spacer()
                Button(action: {
                    print("More options")
                }) {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 24))
                        .foregroundStyle(.blue)
                }
            }.padding(.top, 10)
            Image(systemName: groceryItem.icon)
                .font(.system(size: 80)).padding(.bottom, -8)
            Text(groceryItem.name).font(.title).fontWeight(.bold).foregroundStyle(.black).lineSpacing(0).padding(.bottom, -8)
            HStack {
                Text(groceryItem.category)
                    .font(.callout)
                    .foregroundStyle(.blue)
                Circle()
                    .frame(width: 4, height: 4)
                    .foregroundStyle(.blue)
                    .padding(.horizontal, 4)
                Text("\(String(format: "%.0f", groceryItem.amount)) \(groceryItem.unit)")
                    .font(.callout)
                    .foregroundStyle(.blue)
            }
            TabView(selection: $currentPage) {
                ForEach(0 ..< 2, id: \.self) { page in
                    GroceryItemSheetStatsGrid(groceryItem: groceryItem, pageIndex: page)
                        .tag(page)
                        .padding(.horizontal, 16)
                }
            }
            .padding(.vertical, -24)
            .padding(.horizontal, -16)
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            .frame(maxWidth: .infinity, minHeight: 120, maxHeight: 200)
            .offset(x: 0, y: -8)
            ViewThatFits(in: .vertical) {
                Grid(horizontalSpacing: 16, verticalSpacing: 20) {
                    GridRow {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundStyle(.blue)
                            .font(.system(size: 32))
                        Text("Great work, you're on track to finish this before it expires")
                            .font(.callout)
                            .foregroundStyle(.blue)
                            .multilineTextAlignment(.center)
                            .lineLimit(2 ... 2)

                        Spacer()
                    }
                    GridRow {
                        Image(systemName: "cart.circle.fill")
                            .foregroundStyle(.blue)
                            .font(.system(size: 32))
                        Text("Based on food waste history for this item, you should buy this again")
                            .font(.callout)
                            .foregroundStyle(.blue)
                            .multilineTextAlignment(.center)
                            .lineLimit(2 ... 2)
                        Spacer()
                    }

                }.padding(.bottom, 8)
                Grid(horizontalSpacing: 16, verticalSpacing: 0) {
                    GridRow {
                        Image(systemName: "cart.circle.fill")
                            .foregroundStyle(.blue)
                            .font(.system(size: 32))
                        Text("Based on food waste history for this item, you should buy this again")
                            .font(.callout)
                            .foregroundStyle(.blue)
                            .multilineTextAlignment(.center)
                            .lineLimit(2 ... 2)
                        Spacer()
                    }

                }.padding(.bottom, 8)
            }
            Button(action: {
                print("Mark as no waste")
            }) {
                HStack(spacing: 10) {
                    Image(systemName: "takeoutbag.and.cup.and.straw.fill")
                        .font(.system(size: 18))
                        .frame(width: 20, alignment: .center)
                    Text("Finish with no waste")
                        .font(.headline)
                        .frame(width: 175, alignment: .center)
                }
                .foregroundStyle(.blue)
                .fontWeight(.bold)
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.blue)
                )
            }
            Button(action: {
                print("Mark as waste")
            }) {
                HStack(spacing: 10) {
                    Image(systemName: "trash")
                        .font(.system(size: 18))
                        .frame(width: 20, alignment: .center)
                    Text("Finish with waste")
                        .font(.headline)
                        .frame(width: 175, alignment: .center)
                }
                .foregroundStyle(.blue)
                .fontWeight(.bold)
                .padding()
                .frame(maxWidth: .infinity, alignment: .center)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.blue)
                )
            }
            Button(action: {
                print("Mark as opened")
            }) {
                HStack(spacing: 10) {
                    Image(systemName: "door.right.hand.open")
                        .font(.system(size: 18))
                        .frame(width: 20, alignment: .center)
                    Text("Mark as opened")
                        .font(.headline)
                        .frame(width: 175, alignment: .center)
                }
                .foregroundStyle(.blue)
                .fontWeight(.bold)
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.blue)
                )
            }
        }.padding(10).frame(maxWidth: .infinity, alignment: .center).ignoresSafeArea()
            .padding(.horizontal, 10)
    }
}
