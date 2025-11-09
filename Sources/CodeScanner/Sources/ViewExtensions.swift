//
//  ViewExtensions.swift
//  CodeScanner
//
//  Created by Ryan Spring on 10/3/25.
//

import SwiftUI

extension View {
    func frame(size: CGSize) -> some View {
        self.frame(width: size.width, height: size.height)
    }
    
    func offset(position: CGPoint) -> some View {
        return self.offset(x: position.x, y: position.y)
    }
}
