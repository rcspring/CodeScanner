//
//  CircleButton.swift
//  CodeScanner
//
//  Created by Ryan Spring on 11/7/25.
//

import SwiftUI

struct CircleButton: View {
    @State var pressed: Bool = false
    @Environment(\.colorScheme) var colorScheme
    let closure: () -> Void
    
    var lineWidth: CGFloat {
        pressed ? 8 : 5
    }
    
    var buttonColor: Color {
        colorScheme == .dark ? .white : .red
    }
    
    var body: some View {
            Circle()
                .fill(buttonColor)
                .frame(width: 80, height: 80)
                .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
                    .onChanged { _ in
                        if !pressed {
                            withAnimation {
                                pressed.toggle()
                            }
                        }
                    }.onEnded { _ in
                        withAnimation {
                            pressed.toggle()
                            closure()
                        }
                    })
                .padding(8)
                .glassEffect(.regular.interactive())

    }
}

#Preview(traits: .sizeThatFitsLayout) {
    CircleButton {
        print("Button Pressed")
    }
}
