//
//  BoundsView.swift
//  Lister
//
//  Created by Ryan Spring on 9/14/25.
//

import SwiftUI

struct ItemBoxView: View {
    @Binding var item: BarcodeValue?

    var body: some View {
        if let item = item {
            GeometryReader { proxy in
                Rectangle()
                    .frame(size: item.bounds.size)
                    .opacity(0.0)
                    .border(.blue)
                    .offset(position: item.bounds.origin)
            }
        }
    }
}
