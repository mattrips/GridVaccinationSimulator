//
//  GridSizeView.swift
//  GridVacine2
//
//  Created by Matt Rips on 1/22/21.
//

import SwiftUI

struct GridSizeView: View {
    var size: Int
    
    var body: some View {
        ZStack {
            Color.red
            VStack {
                Text("Grid Size")
                Text("\(size)").font(.largeTitle)
            }.padding(3)
        }
    }
}
