import CodeScanner
import DesignSystem
import Models
import Router
import SwiftUI

@MainActor let productSearchItem: ProductSearchItemResponse = .init(
    name: "Semi Skimmed Milk",
    brand: "Sainburys",
    category: ProductSearchItemCategory(
        id: 123,
        name: "Milk",
        path: "Fresh Food > Milk", recommendedStorageLocation: .fridge),
    amount: 4,
    unit: "pints",
    icon: "chicken",
    source: ProductSearchItemSource(
        id: 1,
        ref: "Local Store"))

func roundedRectangleWithHoleInMask(
    in rect: CGRect,
    shapeWidthOffset: CGFloat,
    shapeHeightOffset: CGFloat,
    shapeWidth: CGFloat,
    shapeHeight: CGFloat) -> Path
{
    var shape = Rectangle().path(in: rect)
    shape.addPath(RoundedRectangle(cornerRadius: 25).path(in: CGRect(
        x: shapeWidthOffset,
        y: shapeHeightOffset,
        width: shapeWidth,
        height: shapeHeight)))
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
    @Environment(Router.self) var router

    @State private var isFlashOn: Bool = false
    @State private var offsetX: CGFloat = ((UIScreen.main.bounds.width / 10) * -3) + 20
    @State private var barcodeIndex: Int = 0

    public init() {}

    let timer = Timer.publish(every: 3, tolerance: 1, on: .main, in: .common).autoconnect()
    let barcodeIcons = [
        "text.magnifyingglass", "text.page.badge.magnifyingglass", "rectangle.and.text.magnifyingglass",
    ]

    public var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack {
                    CodeScannerView(codeTypes: [.ean8, .ean13], simulatedData: "012345789") { response in
                        switch response {
                        case let .success(result):
                            print("Found code: \(result.string)")
                            router.navigateTo(.addProduct(product: productSearchItem))
                            router.presentedSheet = nil
                        case let .failure(error):
                            print(error.localizedDescription)
                        }
                    }

                    Rectangle()
                        .fill(Color.blue800).opacity(0.95)
                        .mask(
                            roundedRectangleWithHoleInMask(
                                in: CGRect(
                                    x: 0,
                                    y: 0,
                                    width: geometry.size.width,
                                    height: geometry.size.height * 1.5),
                                shapeWidthOffset: (
                                    geometry.size
                                        .width - shapeWidth(geometry: geometry)) / 2,
                                shapeHeightOffset: shapeHeightOffset(geometry: geometry),
                                shapeWidth: shapeWidth(geometry: geometry),
                                shapeHeight: shapeHeight(geometry: geometry))
                                .fill(style: FillStyle(eoFill: true)))

                    VStack(spacing: 20) {
                        Image(systemName: barcodeIcons[barcodeIndex])
                            .foregroundStyle(.white200)
                            .font(.system(size: 36))
                            .offset(x: offsetX)
                            .animation(
                                Animation.easeInOut(duration: 3)
                                    .repeatForever(autoreverses: true),
                                value: offsetX)
                            .frame(height: 50)
                            .onReceive(timer) { _ in
                                barcodeIndex = (barcodeIndex + 1) % barcodeIcons.count
                            }

                        Text("Scan a barcode")
                            .foregroundStyle(.white200)
                            .fontWeight(.bold)
                            .font(.headline)
                    }.padding(.top, shapeHeight(geometry: geometry) * 0.25)
                }
                .ignoresSafeArea(.all)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            router.presentedSheet = nil
                        }) {
                            Image(systemName: "chevron.down")
                                .foregroundColor(.gray200)
                        }
                        .transaction { $0.animation = nil }
                    }
                }
                .onAppear {
                    withAnimation(
                        Animation.easeInOut(duration: 3)
                            .repeatForever(autoreverses: true))
                    {
                        offsetX = (shapeWidth(geometry: geometry) / 2) - 20
                    }
                }
            }
        }
    }
}
