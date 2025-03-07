import SwiftUI

public struct BarcodeView: View {
    @State private var isFlashOn: Bool = false
    
    public init() {}

    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                ScanBarcode(supportBarcode: [.ean8, .ean13])
                    .interval(delay: 1.0)
                    .found {
                       print($0)
                    }.simulator(mockBarCode: "123456")
                    .torchLight(isOn: isFlashOn)
            }.edgesIgnoringSafeArea(.all)
        }
    }
}
