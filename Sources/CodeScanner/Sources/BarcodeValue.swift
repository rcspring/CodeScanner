//
//  BarcodeValue.swift
//  CodeScanner
//
//  Created by Ryan Spring on 10/19/25.
//

import AVFoundation
import Foundation

struct BarcodeValue {
    let value: String
    let bounds: CGRect
    let type: AVMetadataObject.ObjectType
}

extension BarcodeValue: Equatable {
    static func == (lhs: BarcodeValue, rhs: BarcodeValue) -> Bool {
        lhs.value == rhs.value &&
        lhs.type == rhs.type &&
        lhs.bounds == rhs.bounds
    }
}
