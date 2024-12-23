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
                Text("\(grocerySearchItem.name)").toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: {
                            print("Add click")
                        }) {
                            Image(systemName: "checkmark")
                                .font(.system(size: 18)).foregroundColor(.white200)
                        }
                    }
                }
            }.frame(maxWidth: .infinity)
                .background(
                    LinearGradient(
                        stops: [
                            Gradient.Stop(color: .blue700, location: -0.05),
                            Gradient.Stop(color: .blue500, location: 0.15),
                            Gradient.Stop(color: .white200, location: 0.3),
                        ], startPoint: .top, endPoint: .bottom
                    )
                ).toolbarRole(.editor)
            //                LinearGradient(gradient: Gradient(colors: [.blue800, .blue400, .white200]
            //                                                 ), startPoint: .top, endPoint: .bottom)).toolbarRole(.editor)

            Button(action: {
                print("Tapped add to fridge")
            }) {
                Text("Add to Fridge")
                    .font(.title2)
                    .foregroundStyle(.blue600)
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .padding(.vertical, 20)
                    .background(
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
                    )
            }
        }.edgesIgnoringSafeArea(.bottom)
    }
}
