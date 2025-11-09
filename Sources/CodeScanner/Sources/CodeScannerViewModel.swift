//
//  VideoViewModel.swift
//  Lister
//
//  Created by Ryan Spring on 9/14/25.
//

@preconcurrency import AVFoundation
import Combine
import SwiftUI

@MainActor
final class CodeScannerViewModel: NSObject, ObservableObject {
    private struct Constants {
        static let upsideDown: Double = 270.0
        static let defaultZoom: CGFloat = 1.0
        static let allItemTypes: [AVMetadataObject.ObjectType] = [.qr, .itf14, .aztec, .pdf417, .code39Mod43, .code93, .code128, .ean8, .ean13, .interleaved2of5, .upce]
    }
    
    let itemTypes: [AVMetadataObject.ObjectType]
    let previewLayer: AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer()
    nonisolated let session = AVCaptureSession()
    @Published var barcodeData: BarcodeValue?
    
    private var coordinator: AVCaptureDevice.RotationCoordinator?
    private var observer: NSKeyValueObservation?
    
    init(itemTypes: [AVMetadataObject.ObjectType]) {
        self.itemTypes = itemTypes
        super.init()
        setup()
    }
    
    private func setup() {
        guard let camera = getCamera(),
              let input = try? AVCaptureDeviceInput(device: camera),
              session.canAddInput(input) else { return }
        
        previewLayer.videoGravity = .resizeAspectFill
        
        try? camera.lockForConfiguration()
        camera.videoZoomFactor = Constants.defaultZoom
        camera.unlockForConfiguration()
        
        coordinator = AVCaptureDevice.RotationCoordinator(device: camera, previewLayer: previewLayer)
        
        observeOrientation(from: coordinator!)
        
        session.beginConfiguration()
        
        session.addInput(input)
        
        let metadata = AVCaptureMetadataOutput()
        
        if session.canAddOutput(metadata) {
            session.addOutput(metadata)
            metadata.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadata.metadataObjectTypes = itemTypes
        }
        
        session.commitConfiguration()
    }
    
    func startCapture() {
        guard !session.isRunning else { return }
        Task.detached(priority: .background) {
            self.session.startRunning()
            Task { @MainActor [weak self] in
                if let coordinator = self?.coordinator {
                    self?.setRotationAngle(with: coordinator)
                }
            }
        }
    }
    
    func stopCapture() {
        guard session.isRunning else { return }
        Task.detached(priority: .background) {
            self.session.stopRunning()
        }
    }
    
    private func getCamera() -> AVCaptureDevice? {
        let session = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInTrueDepthCamera,
                                                                     .builtInDualCamera,
                                                                     .builtInWideAngleCamera,
                                                                     .builtInTelephotoCamera,
                                                                     .builtInTripleCamera],
                                                       mediaType: .video,
                                                       position: .back)
                
        return session.devices.first
    }
    
    private func observeOrientation(from coordinator: AVCaptureDevice.RotationCoordinator) {
        observer = coordinator.observe(\.videoRotationAngleForHorizonLevelCapture, options: [.new]) { [weak self] _, change in
            Task {
                await self?.setRotationAngle(with: coordinator)
            }
        }
    }
    
    private func setRotationAngle(with coordinator: AVCaptureDevice.RotationCoordinator) {
        guard let connection = previewLayer.connection else { return }
        
        let newAngle = coordinator.videoRotationAngleForHorizonLevelCapture
        
        if connection.isVideoRotationAngleSupported(newAngle), newAngle != Constants.upsideDown  {
            connection.videoRotationAngle = newAngle
        }
    }
}

extension CodeScannerViewModel: AVCaptureMetadataOutputObjectsDelegate {
    nonisolated func metadataOutput(_ output: AVCaptureMetadataOutput,
                                    didOutput metadataObjects: [AVMetadataObject],
                                    from connection: AVCaptureConnection) {
   
        // Needed because compiler does can not infer that this is sendable
        let sendableMetadata: [any Sendable] = metadataObjects
        
        Task {
            if let sendableMetadata = sendableMetadata as? [AVMetadataObject] {
                await handle(metadata: sendableMetadata)
            }
        }
    }
    
    func handle(metadata: [AVMetadataObject]) {
        guard metadata.count > 0 else {
            barcodeData = nil
            return
        }
        
        for object in metadata {
            if let metadataObject = object as? AVMetadataMachineReadableCodeObject, let value = metadataObject.stringValue {
                if let rotatedData = previewLayer.transformedMetadataObject(for: metadataObject) {
                    barcodeData = BarcodeValue(value: value,
                                               bounds: rotatedData.bounds,
                                               type: rotatedData.type)
                }
            }
        }
    }
}
