import DesignSystem
import Models
import SwiftUI

struct UpNextPanel: View {
    let storageLocation: StorageLocation

    var textColor: Color {
        storageLocation == .freezer ? .white200 : .blue800
    }

    var body: some View {
        VStack {
            HStack {
                HStack {
//                    Image(systemName: "arrow.forward.square.fill")
//                        .frame(width: 35).foregroundColor(textColor).fontWeight(.bold)
                    
                    Image(systemName: "arrow.forward.square.fill").resizable()
                        .frame(width: 25, height: 25).foregroundColor(.blue800).fontWeight(.bold)

                    Text("Up next")
                        .fontWeight(.bold)
                        .foregroundStyle(textColor)
                        .font(.title3)
                        .lineLimit(1)
                        
                    
                    Spacer()
                }
            }
//            .padding(.vertical, 10)
            .padding(.horizontal, 5)
            .frame(maxWidth: .infinity)

            ShoppingModeActiveItem(shoppingItem: ShoppingItem(id: 1, title: nil, createdAt: Date(), updatedAt: Date(), source: .user, status: .created, storageLocation: .pantry, product: Product(id: 1, name: "Sultanas", unit: "kg", brand: .sainsburys, barcode: nil, amount: 1, category: CategoryDetails(icon: "milk", id: 1, name: "Dried Fruit", pathDisplay: "Dried Fruit", expiryType: .BestBefore))))

                
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 10)
        .frame(maxWidth: .infinity)
        .overlay(
            RoundedRectangle(cornerRadius: 11)
                .stroke(
                    (storageLocation.panelForegroundColor.2).opacity(0.2),
                    style: StrokeStyle(
                        lineWidth: 1,
                        dash: [11, 6])))
    }
}
