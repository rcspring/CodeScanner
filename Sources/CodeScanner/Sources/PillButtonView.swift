//
//  PillButtonView.swift
//  CodeScanner
//
//  Created by Ryan Spring on 10/3/25.
//

import SwiftUI

struct PillButtonView: View {
    let title: String
    let color: Color
    let action: () -> Void
    
    init(_ title: String,
         color: Color,
         action: @escaping () -> Void) {
        self.title = title
        self.color = color
        self.action = action
    }
    
    var body: some View {
        Button(title, action: action)
            .tint(color)
            .padding()
            .buttonStyle(.borderedProminent)
    }
}

#Preview {
    PillButtonView("Test", color: .blue) {
        print("Test")
    }
}
