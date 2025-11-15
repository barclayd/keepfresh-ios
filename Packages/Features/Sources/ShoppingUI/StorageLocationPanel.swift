import DesignSystem
import Models
import SharedUI
import SwiftUI

public struct StorageLocationPanel: View {
    @State private var isToggled: Bool = false
    
    let storageLocation: StorageLocation
    
    public init(storageLocation: StorageLocation) {
        self.storageLocation = storageLocation
    }
    
    var textColor: Color {
        storageLocation == .freezer ? .white200 : .blue800
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            HStack {
                HStack(alignment: .firstTextBaseline) {
                    Image(systemName: storageLocation.iconFilled)
                        .frame(width: 18).foregroundColor(textColor).fontWeight(.bold)
                    
                    Text(storageLocation.rawValue.capitalized)
                        .fontWeight(.bold)
                        .foregroundStyle(textColor)
                        .font(.headline)
                        .lineLimit(1)
                        .alignmentGuide(.firstTextBaseline) { d in
                            d[.bottom] * 0.75
                        }
                }
                
                Spacer()
                
                HStack {
                    Image(systemName: "5.square.fill")
                        .frame(width: 18).foregroundColor(textColor)
                    Image(systemName: "chevron.down")
                        .rotationEffect(.degrees(isToggled ? -180 : 0))
                        .frame(width: 18).foregroundColor(textColor)
                }.fontWeight(.bold)
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 15)
            .frame(maxWidth: .infinity)
            .background(
                UnevenRoundedRectangle(cornerRadii: RectangleCornerRadii(
                    topLeading: 10,
                    bottomLeading: isToggled ? 0 : 10,
                    bottomTrailing: isToggled ? 0 : 10,
                    topTrailing: 10)).fill(LinearGradient(stops: storageLocation.viewGradientStopsReversed, startPoint: .leading, endPoint: .trailing)))
            .onTapGesture {
//                withAnimation(.easeInOut) {
                    isToggled.toggle()
//                }
            }
//            .transition(.move(edge: .top))
            if isToggled {
                VStack(spacing: 0) {
                    RoundedRectangle(cornerRadius: 10).fill(Color.black).opacity(0.15).frame(maxWidth: .infinity, maxHeight: 1).offset(y: -10)
                    
                    HStack {
                        Image(systemName: "house")
                            .font(.system(size: 21))
                            .fontWeight(.bold)
                            .foregroundColor(.blue700)
                            .frame(width: 40, height: 40)
                        
                        Text("Location")
                            .foregroundStyle(.blue700)
                            .font(.callout)
                            .lineLimit(1)
                        
                        Spacer()
                    }
                    
                }.padding(.vertical, 10).padding(.horizontal, 15).frame(maxWidth: .infinity)
                    .background(
                        UnevenRoundedRectangle(cornerRadii: RectangleCornerRadii(
                            topLeading: 0,
                            bottomLeading: 10,
                            bottomTrailing: 10,
                            topTrailing: 0))
                        .fill(LinearGradient(stops: storageLocation.viewGradientStopsReversed, startPoint: .leading, endPoint: .trailing)))
            }
        }
    }
}
