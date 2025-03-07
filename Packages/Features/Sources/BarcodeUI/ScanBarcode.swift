import AVFoundation
import SwiftUI

public struct ScanBarcode: UIViewRepresentable {
    public var supportBarcode: [AVMetadataObject.ObjectType]?
    public typealias UIViewType = CameraPreview

    private let session = AVCaptureSession()
    private let delegate = ScanBarcodeDelegate()
    private let metadataOutput = AVCaptureMetadataOutput()

    public init(supportBarcode: [AVMetadataObject.ObjectType]) {
        self.supportBarcode = supportBarcode
    }

    public func torchLight(isOn: Bool) -> ScanBarcode {
        if let backCamera = AVCaptureDevice.default(for: AVMediaType.video) {
            if backCamera.hasTorch {
                try? backCamera.lockForConfiguration()
                if isOn {
                    backCamera.torchMode = .on
                } else {
                    backCamera.torchMode = .off
                }
                backCamera.unlockForConfiguration()
            }
        }
        return self
    }

    public func interval(delay: Double) -> ScanBarcode {
        delegate.scanInterval = delay
        return self
    }

    public func found(result: @escaping (String) -> Void) -> ScanBarcode {
        delegate.onResult = result
        return self
    }

    public func simulator(mockBarCode: String) -> ScanBarcode {
        delegate.mockData = mockBarCode
        return self
    }

    func setupCamera(_ uiView: CameraPreview) {
        guard let backCamera = AVCaptureDevice.default(for: AVMediaType.video), let input = try? AVCaptureDeviceInput(device: backCamera) else {
            return
        }

        session.sessionPreset = .photo

        if session.canAddInput(input) {
            session.addInput(input)
        }
        if session.canAddOutput(metadataOutput) {
            session.addOutput(metadataOutput)
            metadataOutput.metadataObjectTypes = supportBarcode
            metadataOutput.setMetadataObjectsDelegate(delegate, queue: DispatchQueue.main)
        }
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)

        uiView.backgroundColor = UIColor.gray
        previewLayer.videoGravity = .resizeAspectFill
        uiView.layer.addSublayer(previewLayer)
        uiView.previewLayer = previewLayer

        session.startRunning()
    }

    public func makeUIView(context: UIViewRepresentableContext<ScanBarcode>) -> ScanBarcode.UIViewType {
        let cameraView = CameraPreview(session: session)

        #if targetEnvironment(simulator)
            cameraView.createSimulatorView(delegate: delegate)
        #else
            checkCameraAuthorizationStatus(cameraView)
        #endif

        return cameraView
    }

    public static func dismantleUIView(_ uiView: CameraPreview, coordinator: ()) {
        uiView.session.stopRunning()
    }

    private func checkCameraAuthorizationStatus(_ uiView: CameraPreview) {
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        if cameraAuthorizationStatus == .authorized {
            setupCamera(uiView)
        } else {
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.sync {
                    if granted {
                        self.setupCamera(uiView)
                    }
                }
            }
        }

        DispatchQueue.global(qos: .background).async {
            var isActive = true
            while isActive {
                DispatchQueue.main.sync {
                    if !self.session.isRunning {
                        isActive = false
                    }
                }
                sleep(1)
            }
        }
    }

    public func updateUIView(_ uiView: CameraPreview, context: UIViewRepresentableContext<ScanBarcode>) {
        uiView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        uiView.setContentHuggingPriority(.defaultLow, for: .horizontal)
    }
}

public class CameraPreview: UIView {
    var previewLayer: AVCaptureVideoPreviewLayer?
    var session = AVCaptureSession()
    private var label: UILabel?
    var delegate: ScanBarcodeDelegate?

    init(session: AVCaptureSession) {
        super.init(frame: .zero)
        self.session = session
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func createSimulatorView(delegate: ScanBarcodeDelegate) {
        self.delegate = delegate
        backgroundColor = UIColor.black
        label = UILabel(frame: bounds)
        label?.numberOfLines = 1
        label?.text = "Simulator mode"
        label?.textColor = UIColor.white
        label?.textAlignment = .center
        guard let label = label else { return }
        addSubview(label)
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        #if targetEnvironment(simulator)
            label?.frame = bounds
        #else
            previewLayer?.frame = bounds
        #endif
    }
}

class ScanBarcodeDelegate: NSObject, AVCaptureMetadataOutputObjectsDelegate {
    var scanInterval: Double = 1.0
    var lastTime = Date(timeIntervalSince1970: 0)

    var onResult: (String) -> Void = { _ in }
    var mockData: String?

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard let metadataObject = metadataObjects.first,
            let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
            let stringValue = readableObject.stringValue else { return }

        foundBarcode(stringValue)
    }

    @objc func onSimulateScanning() {
        foundBarcode(mockData ?? "Please set up mock data to display when using the simulator")
    }

    func foundBarcode(_ stringValue: String) {
        let now = Date()
        if now.timeIntervalSince(lastTime) >= scanInterval {
            lastTime = now
            onResult(stringValue)
        }
    }
}
