//
//  PreviewUIKit.swift
//  CodeScanner
//
//  Created by Ryan Spring on 10/3/25.
//

import AVFoundation
import UIKit

public final class PreviewUIView: UIView {
    let previewLayer: AVCaptureVideoPreviewLayer
    
    init(previewLayer: AVCaptureVideoPreviewLayer) {
        self.previewLayer = previewLayer
        super.init(frame: .zero)
        layer.addSublayer(previewLayer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override var frame: CGRect {
        get {
            super.frame
        }
        set {
            previewLayer.frame = newValue
            super.frame = newValue
        }
    }
}
