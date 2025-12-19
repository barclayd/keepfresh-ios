import DesignSystem
import Models
import SwiftUI

struct ExpiryDateMinusButton: View {
    @Binding var date: Date

    @State private var plusTrigger = 0
    @State private var minusTrigger = 0

    let storageLocation: StorageLocation

    init(date: Binding<Date>, storageLocation: StorageLocation) {
        _date = date
        self.storageLocation = storageLocation
    }

    var body: some View {
        Button(action: {
            minusTrigger += 1
            date.addDays(-1)
        }) {
            Image(systemName: "minus.square.fill")
                .font(.system(size: 20))
                .fontWeight(.bold)
                .foregroundStyle(storageLocation.controlColors.0, storageLocation.controlColors.1)
        }
        .buttonStyle(.borderless)
        .sensoryFeedback(.decrease, trigger: minusTrigger)
        .buttonRepeatBehavior(.enabled)
    }
}

struct ExpiryDatePlusButton: View {
    @Binding var date: Date

    @State private var plusTrigger = 0
    @State private var minusTrigger = 0

    let storageLocation: StorageLocation

    init(date: Binding<Date>, storageLocation: StorageLocation) {
        _date = date
        self.storageLocation = storageLocation
    }

    var body: some View {
        Button(action: {
            plusTrigger += 1
            date.addDays(1)
        }) {
            Image(systemName: "plus.square.fill")
                .font(.system(size: 20))
                .fontWeight(.bold)
                .foregroundStyle(storageLocation.controlColors.0, storageLocation.controlColors.1)
        }
        .buttonStyle(.borderless)
        .sensoryFeedback(.increase, trigger: plusTrigger)
        .buttonRepeatBehavior(.enabled)
    }
}

struct ExpiryDateButtons: View {
    @Binding var date: Date

    @State private var plusTrigger = 0
    @State private var minusTrigger = 0

    let storageLocation: StorageLocation

    init(date: Binding<Date>, storageLocation: StorageLocation) {
        _date = date
        self.storageLocation = storageLocation
    }

    var body: some View {
        VStack {
            Button(action: {
                plusTrigger += 1
                date.addDays(1)
            }) {
                Image(systemName: "plus.square.fill")
                    .font(.system(size: 20))
                    .fontWeight(.bold)
                    .foregroundStyle(storageLocation.controlColors.0, storageLocation.controlColors.1)
            }
            .buttonStyle(.borderless)
            .sensoryFeedback(.increase, trigger: plusTrigger)
            .buttonRepeatBehavior(.enabled)

            Button(action: {
                minusTrigger += 1
                date.addDays(-1)
            }) {
                Image(systemName: "minus.square.fill")
                    .font(.system(size: 16))
                    .fontWeight(.bold)
                    .foregroundStyle(storageLocation.controlColors.0, storageLocation.controlColors.1)
            }
            .buttonStyle(.borderless)
            .sensoryFeedback(.decrease, trigger: minusTrigger)
            .buttonRepeatBehavior(.enabled)
        }
    }
}
