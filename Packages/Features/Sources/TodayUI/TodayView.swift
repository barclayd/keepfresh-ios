import DesignSystem
import Environment
import Extensions
import Models
import SwiftUI

public struct TodayView: View {
    public init() {}
    
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(Inventory.self) var inventory
    
    private func getSheetFraction(height: CGFloat) -> CGFloat {
        if dynamicTypeSize >= .xxLarge {
            return 0.8
        }
        
        switch height {
        case ..<668:
            return 1 // iPhone SE
        case ..<845:
            return 0.9 // iPhone 13
        case ..<957:
            return 0.85 // iPhone 16 Pro Max
        default:
            return 0.7
        }
    }
    
    public var body: some View {
        if inventory.items.isEmpty {
            VStack(spacing: 8) {
                HStack {
                    Spacer()
                    Image("arrow.curved.right")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 300)
                        .foregroundStyle(.green500)
                }.padding(.horizontal, 40)
                
                Text("Bring your fridge to your pocket").font(.headline).foregroundStyle(
                    .blue600
                ).fontWeight(.bold)
                Text("Tap above to search for or scan a grocery item from the UK’s favourite supermarkets").font(.subheadline).foregroundStyle(
                    .blue800
                ).multilineTextAlignment(.center).padding(.horizontal, 20)
                
                Spacer()
                
                Text("Need some inspiraton?").font(.subheadline).foregroundStyle(
                    .blue600
                ).fontWeight(.bold)
                
                Button(action: {
                    print("randomise")
                }) {
                    HStack(spacing: 10) {
                        Image(systemName: "dice")
                            .font(.system(size: 18))
                            .frame(width: 20, alignment: .center)
                        Text("Random item")
                            .font(.headline)
                            .frame(width: 175, alignment: .center)
                    }
                    .foregroundStyle(.blue600)
                    .fontWeight(.bold)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.gray200))
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
            .background(.white200)
        } else {
            ScrollView {
                LazyVStack(spacing: 14) {
                    ForEach(inventory.itemsSortedByExpiryAscending) { inventoryItem in
                        InventoryItemView(inventoryItem: inventoryItem)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 10)
                .redactedShimmer(when: inventory.state == .loading)
            }
            .background(.white200)
        }
    }
}
