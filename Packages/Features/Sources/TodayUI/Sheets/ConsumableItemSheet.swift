import DesignSystem
import Models
import SwiftUI

struct ConsumableSheetStatsGridRows: View {
    let pageIndex: Int

    var body: some View {
        if pageIndex == 0 {
            return Group {
                GridRow {
                    VStack(spacing: 0) {
                        Text("3").foregroundStyle(.green600).fontWeight(.bold).font(.headline)
                        Text("Days to expiry").foregroundStyle(.green600).fontWeight(.light).font(.subheadline).lineLimit(1)
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
                    Text("Fridge").fontWeight(.bold).font(.headline)
                    Image(systemName: "refrigerator")
                        .font(.system(size: 28)).fontWeight(.bold)
                    Image(systemName: "circle.bottomrighthalf.pattern.checkered")
                        .font(.system(size: 28)).fontWeight(.bold)
                    Text("Sainsburys").fontWeight(.bold).foregroundStyle(.brandSainsburys).font(.headline).lineLimit(1)
                }.foregroundStyle(.blue700)
            }
        }

        return Group {
            GridRow {
                VStack(spacing: 0) {
                    Text("3 weeks ago").fontWeight(.bold).font(.headline)
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
                    Text("2").fontWeight(.bold).font(.headline)
                    Text("Located in Fridge").fontWeight(.light).font(.subheadline).lineLimit(1)
                }.foregroundStyle(.blue700)
                Image(systemName: "house")
                    .font(.system(size: 32)).fontWeight(.bold)
                    .foregroundStyle(.blue700)
                VStack(spacing: 0) {
                    Text("3").fontWeight(.bold).font(.headline)
                    Text("Located in Freezer").fontWeight(.light).font(.subheadline)
                }.foregroundStyle(.blue700)
            }
        }
    }
}

struct ConsumableItemSheetStatsGrid: View {
    let consumableItem: ConsumableItem

    let pageIndex: Int

    var body: some View {
        ViewThatFits(in: .horizontal) {
            Grid(horizontalSpacing: 30, verticalSpacing: 10) {
                ConsumableSheetStatsGridRows(pageIndex: pageIndex)
            }
            Grid(horizontalSpacing: 10, verticalSpacing: 10) {
                ConsumableSheetStatsGridRows(pageIndex: pageIndex)
            }
        }.padding(.horizontal, 15).padding(.vertical, 5).frame(maxWidth: .infinity, alignment: .center).background(.white300).cornerRadius(20)
    }
}

struct ConsumableItemSheetView: View {
    @Binding var consumableItem: ConsumableItem?
    @Environment(\.dismiss) private var dismiss

    @State private var currentPage = 0
    @State private var showRemoveSheet: Bool = false

    init(consumableItem: Binding<ConsumableItem?>) {
        _consumableItem = consumableItem

        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(.blue600)
        UIPageControl.appearance().pageIndicatorTintColor = UIColor(.gray150)
    }

    var body: some View {
        guard let consumableItem: ConsumableItem = consumableItem else {
            return EmptyView()
        }

        return VStack(spacing: 10) {
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
            Image(systemName: consumableItem.icon)
                .font(.system(size: 80)).padding(.bottom, -8).foregroundStyle(.blue800)
            Text(consumableItem.name).font(.title).fontWeight(.bold).foregroundStyle(.blue800).lineSpacing(0).padding(.bottom, -8)
            HStack {
                Text(consumableItem.category)
                    .font(.callout)
                    .foregroundStyle(.gray600)
                Circle()
                    .frame(width: 6, height: 6)
                    .foregroundStyle(.gray600)
                    .padding(.horizontal, 4)
                Text("\(String(format: "%.0f", consumableItem.amount)) \(consumableItem.unit)")
                    .font(.callout)
                    .foregroundStyle(.gray600)
            }
            TabView(selection: $currentPage) {
                ForEach(0 ..< 2, id: \.self) { page in
                    ConsumableItemSheetStatsGrid(consumableItem: consumableItem, pageIndex: page)
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
                RemoveConsumableItemSheet()
                    .presentationDragIndicator(.visible)
                    .presentationCornerRadius(25)
                    .presentationDetents([.fraction(0.35)])
            }
    }
}
