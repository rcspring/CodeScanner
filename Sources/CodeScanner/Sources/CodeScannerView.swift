//
//  Photo.swift
//  Photo
//
//  Created by Ryan Spring on 9/14/25.
//

import AVFoundation
import Foundation
import SwiftUI

public enum CodeScannerMode {
    case button
    case first
}

public struct Constants {
    public static let allItemTypes: [AVMetadataObject.ObjectType] = [.qr, .itf14, .aztec, .pdf417, .code39Mod43, .code93, .code128, .ean8, .ean13, .interleaved2of5, .upce]
}

public struct CodeScannerView: View {
    @StateObject var viewModel: CodeScannerViewModel
    @Environment(\.dismiss) var dismiss
    @Binding var barcodeData: String?
    let scannerMode: CodeScannerMode
    
    public init(_ barcode: Binding<String?>,
                mode: CodeScannerMode = .button,
                itemTypes: [AVMetadataObject.ObjectType] = Constants.allItemTypes) {
        _viewModel = StateObject(wrappedValue: .init(itemTypes: itemTypes))
        _barcodeData = barcode
        self.scannerMode = mode
    }
    
    public var body: some View {
        ZStack(alignment: .topLeading) {
            PreviewView(previewLayer: viewModel.previewLayer,
                        session: viewModel.session)
            ItemBoxView(item: $viewModel.barcodeData)
        }
        .overlay(alignment: .bottom) {
            if let barcode = viewModel.barcodeData,
                scannerMode == .button {
                CircleButton {
                    finish(barcode.value)
                }
            }
        }
        .onChange(of: viewModel.barcodeData) {
            if let barcode = viewModel.barcodeData,
               scannerMode == .first {
                finish(barcode.value)
            }
        }
        .ignoresSafeArea()
        .onAppear {
            viewModel.startCapture()
        }
        .onDisappear {
            viewModel.stopCapture()
        }
    }
    
    private func finish(_ value: String ) {
        barcodeData = value
        dismiss()
    }
}

#Preview {
    CodeScannerView(.constant(nil))
}

