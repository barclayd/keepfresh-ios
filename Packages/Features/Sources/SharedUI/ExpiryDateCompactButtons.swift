import DesignSystem
import Models
import SwiftUI

public struct ExpiryDateCompactButtons: View {
    @Binding var date: Date

    @State private var plusTrigger = 0
    @State private var minusTrigger = 0

    let storageLocation: StorageLocation

    public init(date: Binding<Date>, storageLocation: StorageLocation) {
        _date = date
        self.storageLocation = storageLocation
    }

    public var body: some View {
        VStack(spacing: 2) {
            Button(action: {
                plusTrigger += 1
                date.addDays(1)
            }) {
                Image(systemName: "plus.square.fill")
                    .font(.system(size: 28))
                    .fontWeight(.bold)
                    .foregroundStyle(storageLocation.controlColors.0, storageLocation.controlColors.1)
            }
            .sensoryFeedback(.increase, trigger: plusTrigger)
            .buttonRepeatBehavior(.enabled)

            Button(action: {
                minusTrigger += 1
                date.addDays(-1)
            }) {
                Image(systemName: "minus.square.fill")
                    .font(.system(size: 28))
                    .fontWeight(.bold)
                    .foregroundStyle(storageLocation.controlColors.0, storageLocation.controlColors.1)
            }
            .sensoryFeedback(.decrease, trigger: minusTrigger)
            .buttonRepeatBehavior(.enabled)
        }
    }
}
