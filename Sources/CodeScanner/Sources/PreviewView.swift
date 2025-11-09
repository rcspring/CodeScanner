//
//  PreviewView.swift
//  CodeScanner
//
//  Created by Ryan Spring on 10/3/25.
//

import AVFoundation
import SwiftUI
import UIKit

struct PreviewView: UIViewRepresentable {
    let previewLayer: AVCaptureVideoPreviewLayer
    let session: AVCaptureSession
    
    init(previewLayer: AVCaptureVideoPreviewLayer,
         session: AVCaptureSession) {
        self.previewLayer = previewLayer
        self.session = session
    }
    
    func makeUIView(context: Context) -> PreviewUIView {
        let preview = PreviewUIView(previewLayer: previewLayer)
        previewLayer.session = session
        return preview
    }
     
    func updateUIView(_ uiView: PreviewUIView, context: Context) {}
}
