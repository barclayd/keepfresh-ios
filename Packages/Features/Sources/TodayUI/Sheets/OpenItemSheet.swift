import Models
import SharedUI
import SwiftUI

public struct OpenInventoryItemSheet: View {
    var inventoryItem: InventoryItem
    var expiryDate: Date

    let onOpen: (_ expiryDate: Date?) -> Void

    public init(
        inventoryItem: InventoryItem,
        expiryDate: Date,
        onOpen: @escaping (_ expiryDate: Date?) -> Void)
    {
        self.inventoryItem = inventoryItem
        self.expiryDate = expiryDate
        self.onOpen = onOpen
    }
    
    var isSignificantChangeInExpiry: Bool {
        guard expiryDate.timeUntil.totalDays > 0 else { return false }
        
        let percentageDifference = Double(inventoryItem.expiryDate.timeUntil.totalDays - expiryDate.timeUntil.totalDays) / Double(inventoryItem.expiryDate.timeUntil.totalDays)
        
        return percentageDifference >= 0.25
    }
    public var body: some View {
        VStack(spacing: 20) {
            Text(
                "\(Text("Open").foregroundStyle(.gray600)) \(Text(inventoryItem.product.name.truncated(to: 25)).foregroundStyle(.blue700))")
                .lineLimit(2).multilineTextAlignment(.center).fontWeight(.bold).padding(.horizontal, 20).font(.title2).padding(.top, 10)
            
            Spacer()

            Grid(horizontalSpacing: 16, verticalSpacing: 20) {
                GridRow(alignment: .center) {
                    Image(systemName: "\(Calendar.current.component(.day, from: expiryDate)).calendar").fontWeight(.bold)
                        .foregroundStyle(.yellow700)
                        .font(.system(size: 32))

                    VStack(spacing: 2) {
                        Text("Suggested expiry after opening:")
                            .font(.callout)
                            .foregroundStyle(.gray600)
                        HStack(spacing: 0) {
                            Text("\(Text(expiryDate.formattedWithOrdinal).fontWeight(.bold)) (in \(expiryDate.timeUntil.formatted))").font(.callout)
                                .foregroundStyle(.gray600)
                            Image(systemName: "sparkles").font(.system(size: 12)).foregroundColor(
                                .yellow500
                            )
                            .offset(x: 0, y: -6)
                        }
                    }

                    Spacer()
                }

                Suggestion(
                    icon: "hourglass.bottomhalf.filled",
                    iconColor: .blue600,
                    text: "Expiry date shortens \(isSignificantChangeInExpiry ? "significantly" : "slightly") after opening",
                    textColor: .gray600)

            }.padding(.horizontal, 20)

            Spacer()

            HStack {
                Button(action: {
                    onOpen(nil)
                }) {
                    HStack(spacing: 10) {
                        Text("Keep Expiry")
                            .font(.headline)
                    }
                    .foregroundStyle(.blue600)
                    .fontWeight(.bold)
                    .padding()
                    .padding(.vertical, 5)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.gray200))
                }

                Spacer(minLength: 20)

                Button(action: {
                    onOpen(expiryDate)
                }) {
                    HStack(spacing: 10) {
                        Text("Shorten Expiry")
                            .font(.headline)
                    }
                    .foregroundStyle(.blue600)
                    .fontWeight(.bold)
                    .padding()
                    .padding(.vertical, 5)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.green300))
                }
            }

        }.frame(maxWidth: .infinity)
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
    }
}
