//
//  GridLoadingView.swift
//  GridVacine2
//
//  Created by Matt Rips on 1/22/21.
//

import SwiftUI

struct GridLoadingView: View {
    @ObservedObject var checker: GridChecker
    
    var body: some View {
        VStack {
            Text("Preparing Grid \(checker.size)")
            ProgressView(progressRatio: checker.loadingProgress)
        }
    }
}
