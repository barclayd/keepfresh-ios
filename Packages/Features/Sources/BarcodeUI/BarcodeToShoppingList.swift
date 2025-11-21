import CodeScanner
import DesignSystem
import Environment
import Models
import Network
import Router
import SwiftUI

private func roundedRectangleWithHoleInMask(
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

private func shapeHeightOffset(geometry: GeometryProxy) -> CGFloat {
    (geometry.size.height / 10) * 1.25
}

private func shapeHeight(geometry: GeometryProxy) -> CGFloat {
    (geometry.size.height / 10) * 4
}

private func shapeWidth(geometry: GeometryProxy) -> CGFloat {
    (geometry.size.width / 10) * 6
}

public struct BarcodeToShoppingList: View {
    @Environment(Router.self) var router
    @Environment(Shopping.self) var shopping

    @State private var barcodeIndex: Int = 0
    @State private var isAnimating: Bool = false

    public init() {}

    let barcodeIcons = [
        "text.magnifyingglass", "text.page.badge.magnifyingglass", "rectangle.and.text.magnifyingglass",
    ]

    public var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack {
                    CodeScannerView(codeTypes: [.ean8, .ean13, .upce], scanMode: .continuous, simulatedData: "5059697710001") { response in
                        switch response {
                        case let .success(result):
                            guard let shoppingItem = shopping.findItem(barcode: result.string) else {
                                shopping.addItem(barcode: result.string)

                                router.presentedSheet = nil
                                return
                            }

                            router.presentedSheet = .addInventoryItemFromShopping(shoppingItem)
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
                            .offset(
                                x: isAnimating ?
                                    (shapeWidth(geometry: geometry) / 2) - 20 :
                                    ((shapeWidth(geometry: geometry) / 2) * -1) + 20)
                            .frame(height: 50)
                            .onAppear {
                                withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                                    isAnimating = true
                                }
                            }
                            .task {
                                try? await Task.sleep(for: .seconds(3))
                                while !Task.isCancelled {
                                    barcodeIndex = (barcodeIndex + 1) % barcodeIcons.count
                                    try? await Task.sleep(for: .seconds(3))
                                }
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
            }
        }
    }
}
