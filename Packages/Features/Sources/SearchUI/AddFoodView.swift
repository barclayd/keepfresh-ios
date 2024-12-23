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
                }
            }.frame(maxWidth: .infinity).frame(maxHeight: .infinity)
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
