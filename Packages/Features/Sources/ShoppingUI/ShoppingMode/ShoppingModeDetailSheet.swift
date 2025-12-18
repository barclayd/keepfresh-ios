import DesignSystem
import SwiftUI

public struct ShoppingModeDetailSheet: View {
    
    @Environment(\.dismiss) private var dismiss
    
    public init() {}

    public var body: some View {
        VStack {
            Image(systemName: "basket.fill")
                .font(.system(size: 60))
                .foregroundStyle(.blue700)
            
            
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "checkmark")
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
