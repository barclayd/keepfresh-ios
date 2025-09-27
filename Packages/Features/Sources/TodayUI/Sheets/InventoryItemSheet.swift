import DesignSystem
import Environment
import Models
import SwiftUI

struct InventoryItemSheetStatsGridRows: View {
    @Environment(Inventory.self) var inventory

    let pageIndex: Int

    var inventoryItem: InventoryItem

    var body: some View {
        Group {
            if pageIndex == 0 {
                GridRow {
                    VStack(spacing: 0) {
                        Text("\(inventoryItem.expiryDate.timeUntil.amount)").foregroundStyle(.green600).fontWeight(.bold).font(.headline)
                        Text("\(inventoryItem.expiryDate.timeUntil.unit.rawValue.capitalized) to expiry").foregroundStyle(.green600).fontWeight(.light).font(.subheadline)
                            .lineLimit(1)
                    }
                    Image(systemName: "hourglass")
                        .font(.system(size: 28)).fontWeight(.bold)
                        .foregroundStyle(.blue700)
                    Image(systemName: "percent")
                        .font(.system(size: 28)).fontWeight(.bold)
                        .foregroundStyle(.blue700)
                    VStack(spacing: 0) {
                        Text("17").fontWeight(.bold).font(.headline)
                        Text("Waste score").fontWeight(.light).font(.subheadline)
                    }.foregroundStyle(.blue700)
                }
                GridRow {
                    Text(inventoryItem.storageLocation.rawValue).fontWeight(.bold).font(.headline)
                    Image(systemName: "refrigerator")
                        .font(.system(size: 28)).fontWeight(.bold)
                    Image(systemName: "circle.bottomrighthalf.pattern.checkered")
                        .font(.system(size: 28)).fontWeight(.bold)
                    Text(inventoryItem.product.brand.name).fontWeight(.bold).foregroundStyle(inventoryItem.product.brand.color).font(.headline)
                        .lineLimit(1)
                }.foregroundStyle(.blue700)
            } else {
                GridRow {
                    VStack(spacing: 0) {
                        Text("\(inventoryItem.createdAt.timeSince.formatted) ago").fontWeight(.bold).font(.headline)
                        Text("Added").fontWeight(.light).font(.subheadline).lineLimit(1)
                    }.foregroundStyle(.blue700)
                    Image(systemName: "calendar.badge.plus")
                        .font(.system(size: 32)).fontWeight(.bold)
                        .foregroundStyle(.blue700)
                    VStack(spacing: 0) {
                        Text("3 days ago").fontWeight(.bold).font(.headline)
                        Text("Opened").fontWeight(.light).font(.subheadline)
                    }.foregroundStyle(.blue700)
                }
                GridRow {
                    VStack(spacing: 0) {
                        Text("\(inventory.productCountsByLocation[inventoryItem.product.id]?[.fridge] ?? 0)").fontWeight(.bold).font(.headline)
                        Text("Located in Fridge").fontWeight(.light).font(.subheadline).lineLimit(1)
                    }.foregroundStyle(.blue700)
                    Image(systemName: "house")
                        .font(.system(size: 32)).fontWeight(.bold)
                        .foregroundStyle(.blue700)
                    VStack(spacing: 0) {
                        Text("\(inventory.productCountsByLocation[inventoryItem.product.id]?[.freezer] ?? 0)").fontWeight(.bold).font(.headline)
                        Text("Located in Freezer").fontWeight(.light).font(.subheadline)
                    }.foregroundStyle(.blue700)
                }
            }
        }
    }
}

struct InventoryItemSheetStatsGrid: View {
    let pageIndex: Int
    let inventoryItem: InventoryItem

    var body: some View {
        ViewThatFits(in: .horizontal) {
            Grid(horizontalSpacing: 30, verticalSpacing: 10) {
                InventoryItemSheetStatsGridRows(pageIndex: pageIndex, inventoryItem: inventoryItem)
            }
            Grid(horizontalSpacing: 10, verticalSpacing: 10) {
                InventoryItemSheetStatsGridRows(pageIndex: pageIndex, inventoryItem: inventoryItem)
            }
        }.padding(.horizontal, 15).padding(.vertical, 5).frame(maxWidth: .infinity, alignment: .center)
            .background(.white300).cornerRadius(20)
    }
}

struct InventoryItemSheetView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var currentPage = 0
    @State private var showRemoveSheet: Bool = false

    var inventoryItem: InventoryItem

    init(inventoryItem: InventoryItem) {
        self.inventoryItem = inventoryItem

        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(.blue600)
        UIPageControl.appearance().pageIndicatorTintColor = UIColor(.gray150)
    }

    var body: some View {
        Group {
            VStack(spacing: 10) {
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.down")
                            .font(.system(size: 24))
                            .foregroundStyle(.gray600)
                    }
                    Spacer()
                    Button(action: {
                        print("More options")
                    }) {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 24))
                            .foregroundStyle(.gray600)
                    }
                }.padding(.top, 10)

                AsyncImage(url: URL(string: inventoryItem.product.imageUrl ?? "https://keep-fresh-images.s3.eu-west-2.amazonaws.com/chicken-leg.png")) { image in
                    image.resizable()
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 80, height: 80)
                .padding(.bottom, -8)
                Text(inventoryItem.product.name).font(.title).fontWeight(.bold).foregroundStyle(.blue800)
                    .lineSpacing(0).padding(.bottom, -8)
                HStack {
                    Text(inventoryItem.product.categories.name)
                        .font(.callout)
                        .foregroundStyle(.gray600)
                    Circle()
                        .frame(width: 6, height: 6)
                        .foregroundStyle(.gray600)
                        .padding(.horizontal, 4)
                    Text("\(String(format: "%.0f", inventoryItem.product.amount)) \(inventoryItem.product.unit)")
                        .font(.callout)
                        .foregroundStyle(.gray600)
                }
                TabView(selection: $currentPage) {
                    ForEach(0 ..< 2, id: \.self) { page in
                        InventoryItemSheetStatsGrid(pageIndex: page, inventoryItem: inventoryItem)
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
                                .fontWeight(.bold)
                                .foregroundStyle(.yellow500)
                                .font(.system(size: 32))
                            Text("Great work, you're on track to finish this before it expires")
                                .font(.callout)
                                .foregroundStyle(.gray600)
                                .multilineTextAlignment(.center)
                                .lineLimit(2 ... 2)

                            Spacer()
                        }
                        GridRow {
                            Image(systemName: "cart.circle.fill")
                                .fontWeight(.bold)
                                .foregroundStyle(.blue600)
                                .font(.system(size: 32))
                            Text("Based on your waste history for this item, you should buy this again")
                                .font(.callout)
                                .foregroundStyle(.gray600)
                                .multilineTextAlignment(.center)
                                .lineLimit(2 ... 2)
                            Spacer()
                        }
                        GridRow {
                            Image(systemName: "beach.umbrella.fill")
                                .foregroundStyle(.green500)
                                .font(.system(size: 32))
                            Text("You should only need to buy one of these before your next holiday")
                                .font(.callout)
                                .foregroundStyle(.gray600)
                                .multilineTextAlignment(.center)
                                .lineLimit(2 ... 2)
                            Spacer()
                        }
                    }.padding(.bottom, 8)
                    Grid(horizontalSpacing: 16, verticalSpacing: 20) {
                        GridRow {
                            Image(systemName: "checkmark.seal.fill")
                                .fontWeight(.bold)
                                .foregroundStyle(.yellow500)
                                .font(.system(size: 32))
                            Text("Great work, you're on track to finish this before it expires")
                                .font(.callout)
                                .foregroundStyle(.gray600)
                                .multilineTextAlignment(.center)
                                .lineLimit(2 ... 2)

                            Spacer()
                        }
                        GridRow {
                            Image(systemName: "cart.circle.fill")
                                .foregroundStyle(.blue600)
                                .font(.system(size: 32))
                            Text("Based on your waste history for this item, you should buy this again")
                                .font(.callout)
                                .foregroundStyle(.gray600)
                                .multilineTextAlignment(.center)
                                .lineLimit(2 ... 2)
                            Spacer()
                        }
                    }.padding(.bottom, 8)
                }
                Button(action: {
                    print("Mark as done")
                    showRemoveSheet = true
                }) {
                    HStack(spacing: 10) {
                        Image(systemName: "takeoutbag.and.cup.and.straw.fill")
                            .font(.system(size: 18))
                            .frame(width: 20, alignment: .center)
                        Text("Mark as done")
                            .font(.headline)
                            .frame(width: 175, alignment: .center)
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
                    .foregroundStyle(.blue600)
                    .fontWeight(.bold)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.gray200)
                    )
                }
            }.padding(10).frame(maxWidth: .infinity, alignment: .center).ignoresSafeArea()
                .padding(.horizontal, 10)
                .sheet(isPresented: $showRemoveSheet) {
                    RemoveInventoryItemSheet(inventoryItem: inventoryItem)
                        .presentationDragIndicator(.visible)
                        .presentationCornerRadius(25)
                        .presentationDetents([.fraction(0.4)])
                }
        }
    }
}
