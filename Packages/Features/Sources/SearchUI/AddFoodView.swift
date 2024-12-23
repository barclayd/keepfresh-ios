import DesignSystem
import Models
import SwiftUI

public struct AddFoodView: View {
    public let grocerySearchItem: GrocerySearchItem

    public init(grocerySearchItem: GrocerySearchItem) {
        self.grocerySearchItem = grocerySearchItem
    }

    public var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: 5) {
                    Image(systemName: grocerySearchItem.icon).font(.system(size: 78)).foregroundColor(.white200)
                    Text("\(grocerySearchItem.name)").font(.largeTitle).lineSpacing(0).foregroundStyle(.blue800).fontWeight(.bold)
                    HStack {
                        Text(grocerySearchItem.category)
                            .font(.callout).foregroundStyle(.gray600)
                        Circle()
                            .frame(width: 4, height: 4)
                            .foregroundStyle(.gray600)
                        Text("\(String(format: "%.0f", grocerySearchItem.amount)) \(grocerySearchItem.unit)").foregroundStyle(.gray600)
                            .font(.callout)
                    }
                    Text(grocerySearchItem.brand)
                        .font(.callout).fontWeight(.bold)
                        .foregroundStyle(.brandSainsburys)

                    VStack {
                        Text("3%").font(.title).foregroundStyle(.yellow500).fontWeight(.bold).lineSpacing(0)
                        HStack(spacing: 0) {
                            Text("Predicted waste score").font(.subheadline).foregroundStyle(.black800).fontWeight(.light)
                            Image(systemName: "sparkles").font(.system(size: 16)).foregroundColor(.yellow500).offset(x: -2, y: -10)
                        }.offset(y: -5)
                    }

                    Grid {
                        GridRow {
                            VStack(spacing: 0) {
                                Text("32").fontWeight(.bold).font(.headline)
                                Text("Previously addded").fontWeight(.light).font(.subheadline).lineLimit(1)
                            }
                            Image(systemName: "calendar.badge.plus")
                                .font(.system(size: 32)).fontWeight(.bold)
                                .foregroundStyle(.black800)
                            VStack(spacing: 0) {
                                Text("31").fontWeight(.bold).font(.headline)
                                Text("Previously consumed").fontWeight(.light).font(.subheadline)
                            }
                        }
                        GridRow {
                            VStack(spacing: 0) {
                                Text("2").fontWeight(.bold).font(.headline)
                                Text("Located in Fridge").fontWeight(.light).font(.subheadline).lineLimit(1)
                            }
                            Image(systemName: "house")
                                .font(.system(size: 32)).fontWeight(.bold)
                                .foregroundStyle(.black800)
                            VStack(spacing: 0) {
                                Text("2").fontWeight(.bold).font(.headline)
                                Text("Located in Freezer").fontWeight(.light).font(.subheadline)
                            }
                        }
                    }.padding(.horizontal, 15).padding(.vertical, 5).frame(maxWidth: .infinity, alignment: .center).background(.blue100).cornerRadius(20).padding(.vertical, 10)
                    
                    Grid(horizontalSpacing: 16, verticalSpacing: 20) {
                        GridRow {
                            Image(systemName: "checkmark.seal.fill")
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
                                .foregroundStyle(.blue600)
                                .font(.system(size: 32))
                            Text("You should only need to buy one of these before your next holiday")
                                .font(.callout)
                                .foregroundStyle(.gray600)
                                .multilineTextAlignment(.center)
                                .lineLimit(2 ... 2)
                            Spacer()
                        }

                    }.padding(.top, 5)
                    
                }
            }.padding(.horizontal, 20).frame(maxWidth: .infinity).frame(maxHeight: .infinity)
                .background(
                    LinearGradient(
                        stops: [
                            Gradient.Stop(color: .blue700, location: -0.05),
                            Gradient.Stop(color: .blue500, location: 0.1),
                            Gradient.Stop(color: .white200, location: 0.25),
                        ], startPoint: .top, endPoint: .bottom
                    )
                ).toolbarRole(.editor)

            ZStack {
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

                Button(action: {
                    print("Tapped add to fridge")
                }) {
                    Text("Add to Fridge")
                        .font(.title2)
                        .foregroundStyle(.blue600)
                        .fontWeight(.medium)
                        .padding()
                        .padding(.vertical, 20)
                }
            }
        }.edgesIgnoringSafeArea(.bottom).toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    print("Add click")
                }) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 18)).foregroundColor(.white200)
                }
            }
        }
    }
}
