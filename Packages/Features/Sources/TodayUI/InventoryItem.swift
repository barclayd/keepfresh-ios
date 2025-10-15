import Intelligence
import Models
import SharedUI
import SwiftUI

struct IconsView: View {
    let inventoryItem: InventoryItem
    let usageGenerator = UsageGenerator()
    
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 3) {
            if inventoryItem.createdAt.timeSince.totalDays > 0, inventoryItem.createdAt.timeSince.totalDays <= 31 {
                Image(systemName: "\(inventoryItem.createdAt.timeSince.totalDays).calendar")
                    .font(.system(size: 20))
                    .foregroundStyle(inventoryItem.consumptionUrgency.tileColor.foreground)
                    .fontWeight(.bold)
                    .alignmentGuide(.firstTextBaseline) { d in
                        d[.bottom] * 0.75
                    }
            }
            
            Image(systemName: inventoryItem.storageLocation.iconFilled)
                .font(.system(size: 20))
                .foregroundStyle(inventoryItem.consumptionUrgency.tileColor.foreground)
            
            if inventoryItem.status == .opened {
                Image("tin.open")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 22, height: 22)
                    .foregroundStyle(inventoryItem.consumptionUrgency.tileColor.foreground)
                    .alignmentGuide(.firstTextBaseline) { d in
                        d[.bottom] * 0.8
                    }
            }
            
            if usageGenerator.isAvailable {
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 20))
                        .foregroundStyle(inventoryItem.consumptionUrgency.tileColor.ai)
                    
                    Text("\(inventoryItem.consumptionPrediction)%")
                        .foregroundStyle(inventoryItem.consumptionUrgency.tileColor.ai).font(.callout)
                        .alignmentGuide(.firstTextBaseline) { d in
                            d[.bottom] * 0.7
                        }
                }
            }
            
            Spacer()
            
            if inventoryItem.createdAt.timeSince.totalDays == 0 {
                Circle()
                    .frame(width: 12, height: 12)
                    .foregroundStyle(inventoryItem.consumptionUrgency.tileColor.foreground)
                    .alignmentGuide(.firstTextBaseline) { d in
                        d[.bottom]
                    }.padding(.trailing, 20)
            }
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .background(UnevenRoundedRectangle(
            topLeadingRadius: 0,
            bottomLeadingRadius: 20,
            bottomTrailingRadius: 20,
            topTrailingRadius: 0,
            style: .continuous))
        .foregroundStyle(inventoryItem.consumptionUrgency.tileColor.background)
    }
}

public struct InventoryItemView: View {
    @State var showInventoryItemSheet: Bool = false
    
    var inventoryItem: InventoryItem
    
    public init(inventoryItem: InventoryItem) {
        self.inventoryItem = inventoryItem
    }
    
    public var body: some View {
        VStack(alignment: .center, spacing: 0) {
            HStack(spacing: 0) {
                GenmojiView(
                    name: inventoryItem.product.category.icon ?? "chicken",
                    fontSize: 35,
                    tint: inventoryItem.consumptionUrgency.tileColor.background)
                
                VStack {
                    HStack {
                        VStack(alignment: .leading, spacing: 0) {
                            Text(inventoryItem.product.name)
                                .font(.headline)
                                .foregroundStyle(.blue800)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .lineLimit(1)
                            
                            Text(inventoryItem.product.brand.name)
                                .foregroundStyle(inventoryItem.product.brand.color).font(.subheadline)
                            
                        }.frame(maxWidth: .infinity, alignment: .leading)
                        
                        Spacer()
                        
                        ProgressRing(
                            progress: inventoryItem.progress,
                            backgroundColor: inventoryItem.consumptionUrgency.tileColor.background,
                            foregroundColor: inventoryItem.consumptionUrgency.tileColor.foreground)
                        .frame(width: 35, height: 35)
                        .overlay {
                            Text(
                                inventoryItem.expiryDate.timeUntil.totalDaysFormatted)
                            .foregroundStyle(.blue800).fontWeight(.bold).font(.footnote)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 5)
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 10)
            .background(.white100)
            .cornerRadius(20)
            
            IconsView(inventoryItem: inventoryItem)
        }
        .padding(.bottom, 4)
        .padding(.horizontal, 4)
        .background(.white100)
        .cornerRadius(20)
        .frame(maxWidth: .infinity, alignment: .center)
        .shadow(color: .shadow, radius: 2, x: 0, y: 4)
        .onTapGesture {
            showInventoryItemSheet.toggle()
        }
        .sheet(isPresented: $showInventoryItemSheet) {
            InventoryItemSheetView(inventoryItem: inventoryItem)
                .presentationDetents([.custom(AdaptiveMediumDetent.self)])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(25)
        }
    }
}
