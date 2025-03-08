import CodeScanner
import DesignSystem
import SwiftUI

func roundedRectangleWithHoleInMask(
    in rect: CGRect, shapeWidthOffset: CGFloat, shapeHeightOffset: CGFloat, shapeWidth: CGFloat,
    shapeHeight: CGFloat
) -> Path {
    var shape = Rectangle().path(in: rect)
    shape.addPath(
        RoundedRectangle(cornerRadius: 25).path(
            in: CGRect(x: shapeWidthOffset, y: shapeHeightOffset, width: shapeWidth, height: shapeHeight))
    )
    return shape
}

func shapeHeightOffset(geometry: GeometryProxy) -> CGFloat {
    (geometry.size.height / 10) * 1.25
}

func shapeHeight(geometry: GeometryProxy) -> CGFloat {
    (geometry.size.height / 10) * 4
}

func shapeWidth(geometry: GeometryProxy) -> CGFloat {
    (geometry.size.width / 10) * 6
}

public struct BarcodeView: View {
    @State private var isFlashOn: Bool = false
    @State private var isAnimating: Bool = false
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack {
                    CodeScannerView(codeTypes: [.ean8, .ean13], simulatedData: "012345789") { response in
                        switch response {
                        case let .success(result):
                            print("Found code: \(result.string)")
                        case let .failure(error):
                            print(error.localizedDescription)
                        }
                    }
                    
                    Rectangle()
                        .fill(Color.black).opacity(0.7)
                        .mask(
                            roundedRectangleWithHoleInMask(
                                in: CGRect(
                                    x: 0, y: 0, width: geometry.size.width, height: geometry.size.height * 1.5),
                                shapeWidthOffset: (geometry.size.width - shapeWidth(geometry: geometry)) / 2,
                                shapeHeightOffset: shapeHeightOffset(geometry: geometry),
                                shapeWidth: shapeWidth(geometry: geometry),
                                shapeHeight: shapeHeight(geometry: geometry)
                            ).fill(style: FillStyle(eoFill: true)))
                    
                    VStack {
                        Image(systemName: "text.magnifyingglass")
                            .foregroundStyle(.white200)
                            .font(.system(size: 36))
                            .offset(x: isAnimating ? (-1 * shapeWidth(geometry: geometry) / 2) : (shapeWidth(geometry: geometry) / 2))
                            .animation(
                                Animation.easeInOut(duration: 1.5)
                                    .repeatForever(autoreverses: true),
                                value: isAnimating
                            ).onAppear {
                                isAnimating = true
                            }
                        Text("Scan a barcode")
                            .foregroundStyle(.white200)
                            .fontWeight(.bold)
                            .font(.headline)
                    }.padding(.top, 10)
                }
                .ignoresSafeArea(.all)
                .onAppear {
                    isAnimating = true
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            // dismiss
                        }) {
                            Image(systemName: "chevron.down")
                                .foregroundColor(.gray200)
                        }
                    }
                }
            }
        }
    }
}
