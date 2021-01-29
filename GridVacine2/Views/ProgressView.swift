//
//  ProgressView.swift
//  GridVacine2
//
//  Created by Matt Rips on 1/22/21.
//

import SwiftUI

struct ProgressView: View {
    var progressRatio: Double
    
    var body: some View {
        ZStack(alignment: .leading) {
            Color.black.frame(width: 200, height: 3)
            Color.white.frame(width: 200 * CGFloat(progressRatio), height: 3)
        }.animation(.default)
    }
}
