import DesignSystem
import Models
import Router
import SwiftUI

private extension Date {
    func isSameDay(as other: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(self, equalTo: other, toGranularity: .day)
    }
}

public struct AddConsumableView: View {
    @Environment(Router.self) var router

    @State private var expiryDate: Date
    @State private var inventoryStore: InventoryStore
    @State private var quantity: Int = 1
    @State private var status: ConsumableStatus = .unopened

    public let consumableItem: ConsumableSearchItem
    let initialInventoryStore: InventoryStore
    let initialExpiryDate: Date

    public init(consumableSearchItem: ConsumableSearchItem) {
        consumableItem = consumableSearchItem
        initialExpiryDate = Date()
        initialInventoryStore = .fridge
        _expiryDate = State(initialValue: initialExpiryDate)
        _inventoryStore = State(initialValue: initialInventoryStore)
    }

    var didUpdateInventoryStore: Bool {
        inventoryStore != initialInventoryStore
    }

    var didUpdateExpiryDate: Bool {
        expiryDate.isSameDay(as: initialExpiryDate) == false
    }

    func addToInventory() {
        print("Expiry date: \(expiryDate)", "Inventory store: \(inventoryStore.rawValue)", "quantity: \(quantity)", "status: \(status.rawValue)")

        router.popToRoot(for: .search)
    }

    public var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                ScrollView(showsIndicators: false) {
                    ZStack {
                        LinearGradient(
                            stops: [
                                Gradient.Stop(color: .blue700, location: 0),
                                Gradient.Stop(color: .blue500, location: 0.2),
                                Gradient.Stop(color: .white200, location: 0.375),
                            ], startPoint: .top, endPoint: .bottom
                        )
                        .ignoresSafeArea(edges: .top)
                        .offset(y: -geometry.safeAreaInsets.top)
                        .frame(height: geometry.size.height)
                        .frame(maxHeight: .infinity, alignment: .top)

                        VStack(spacing: 5) {
                            Image(systemName: consumableItem.icon).font(.system(size: 78)).foregroundColor(
                                .white200)
                            Text("\(consumableItem.name)").font(.largeTitle).lineSpacing(0).foregroundStyle(
                                .blue700
                            ).fontWeight(.bold)
                            HStack {
                                Text(consumableItem.category)
                                    .font(.callout).foregroundStyle(.gray600)
                                Circle()
                                    .frame(width: 4, height: 4)
                                    .foregroundStyle(.gray600)
                                Text("\(String(format: "%.0f", consumableItem.amount)) \(consumableItem.unit)")
                                    .foregroundStyle(.gray600)
                                    .font(.callout)
                            }
                            Text(consumableItem.brand)
                                .font(.headline).fontWeight(.bold)
                                .foregroundStyle(.brandSainsburys)

                            VStack {
                                Text("3%").font(.title).foregroundStyle(.yellow500).fontWeight(.bold).lineSpacing(0)
                                HStack(spacing: 0) {
                                    Text("Predicted waste score").font(.subheadline).foregroundStyle(.black800)
                                        .fontWeight(.light)
                                    Image(systemName: "sparkles").font(.system(size: 16)).foregroundColor(.yellow500)
                                        .offset(x: -2, y: -10)
                                }.offset(y: -5)
                            }.padding(.top, 10)

                            Grid {
                                GridRow {
                                    VStack(spacing: 0) {
                                        Text("32").fontWeight(.bold).font(.headline).foregroundStyle(.blue700)
                                        Text("Addded").fontWeight(.light).font(.subheadline).lineLimit(1)
                                            .foregroundStyle(.blue700)
                                    }
                                    Image(systemName: "calendar.badge.plus")
                                        .font(.system(size: 32)).fontWeight(.bold)
                                        .foregroundStyle(.blue700)
                                    VStack(spacing: 0) {
                                        Text("31").fontWeight(.bold).font(.headline).foregroundStyle(.blue700)
                                        Text("Consumed").fontWeight(.light).font(.subheadline).foregroundStyle(
                                            .blue700)
                                    }
                                }
                                GridRow {
                                    VStack(spacing: 0) {
                                        Text("2").fontWeight(.bold).font(.headline).foregroundStyle(.blue700)
                                            .foregroundStyle(.blue700)
                                        Text("In Fridge").fontWeight(.light).font(.subheadline)
                                            .foregroundStyle(.blue700)
                                    }
                                    Image(systemName: "house")
                                        .font(.system(size: 32)).fontWeight(.bold)
                                        .foregroundStyle(.blue700)
                                    VStack(spacing: 0) {
                                        Text("2").fontWeight(.bold).font(.headline).foregroundStyle(.blue700)
                                        Text("In Freezer").fontWeight(.light).font(.subheadline).foregroundStyle(
                                            .blue700)
                                    }
                                }
                            }.padding(.horizontal, 15).padding(.vertical, 5).frame(
                                maxWidth: .infinity, alignment: .center
                            ).background(.blue100).cornerRadius(20).padding(.bottom, 10)

                            Grid(horizontalSpacing: 16, verticalSpacing: 20) {
                                GridRow {
                                    Image(systemName: "checkmark.seal.fill").fontWeight(.bold)
                                        .foregroundStyle(.yellow500)
                                        .font(.system(size: 32))
                                    Text("Looks like a good choice, you’re unlikely to waste any of this item")
                                        .font(.callout)
                                        .foregroundStyle(.gray600)
                                        .multilineTextAlignment(.center)
                                        .lineLimit(2 ... 2)

                                    Spacer()
                                }
                                GridRow {
                                    Image(systemName: "beach.umbrella.fill")
                                        .foregroundStyle(.blue600).fontWeight(.bold)
                                        .font(.system(size: 32))
                                    Text("You should only need to buy one of these before your next holiday")
                                        .font(.callout)
                                        .foregroundStyle(.gray600)
                                        .multilineTextAlignment(.center)
                                        .lineLimit(2 ... 2)
                                    Spacer()
                                }

                            }.padding(.vertical, 5).padding(.bottom, 10).padding(.horizontal, 20)

                            VStack(spacing: 15) {
                                ConsumableCategory(quantity: $quantity, status: $status, expiryDate: $expiryDate, inventoryStore: $inventoryStore, didUpdateExpiryDate: didUpdateExpiryDate, didUpdateInventoryStore: didUpdateInventoryStore, type: .ExpiryDate)
                                ConsumableCategory(quantity: $quantity, status: $status, expiryDate: $expiryDate, inventoryStore: $inventoryStore, didUpdateExpiryDate: didUpdateExpiryDate, didUpdateInventoryStore: didUpdateInventoryStore, type: .Storage)
                                ConsumableCategory(quantity: $quantity, status: $status, expiryDate: $expiryDate, inventoryStore: $inventoryStore, didUpdateExpiryDate: didUpdateExpiryDate, didUpdateInventoryStore: didUpdateInventoryStore, type: .Status)
                                ConsumableCategory(quantity: $quantity, status: $status, expiryDate: $expiryDate, inventoryStore: $inventoryStore, didUpdateExpiryDate: didUpdateExpiryDate, didUpdateInventoryStore: didUpdateInventoryStore, type: .Quantity)
                            }
                        }
                        .padding(.bottom, 100)
                        .padding(.horizontal, 20)
                        .frame(maxWidth: geometry.size.width)
                    }
                }.background(.white200)

                ZStack(alignment: .bottom) {
                    UnevenRoundedRectangle(
                        cornerRadii: RectangleCornerRadii(
                            topLeading: 0,
                            bottomLeading: 40,
                            bottomTrailing: 40,
                            topTrailing: 0
                        )
                    )
                    .fill(.white200)
                    .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.25), radius: 4, x: 0, y: -4)
                    .frame(height: 80)

                    Button(action: addToInventory) {
                        Text("Add to \(inventoryStore.rawValue.capitalized)")
                            .font(.title2)
                            .foregroundStyle(.blue600)
                            .fontWeight(.medium)
                            .padding()
                            .padding(.vertical, 20)
                    }
                }
            }
            .frame(maxWidth: geometry.size.width, maxHeight: geometry.size.height)
        }
        .edgesIgnoringSafeArea(.bottom)
        .toolbarRole(.editor)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: addToInventory) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 18))
                        .foregroundColor(.white200)
                }
            }
        }
    }
}
