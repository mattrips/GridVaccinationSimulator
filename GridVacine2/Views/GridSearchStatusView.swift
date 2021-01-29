//
//  GridSearchStatusView.swift
//  GridVacine2
//
//  Created by Matt Rips on 1/22/21.
//

import SwiftUI

struct GridSearchStatusView: View {
    @ObservedObject var checker: GridChecker
    
    var body: some View {
        ZStack {
            Color.green
            VStack(spacing: 10) {
                Text("\(checker.firstCoordinatesChecked) of \(checker.countOfFirstCoordinates)").font(Font.system(size: 16, design: .monospaced).monospacedDigit())
                Text("\(percentageCompleteText)%").font(Font.system(size: 20, design: .monospaced).monospacedDigit())
            }.padding(5)
        }
    }
    
    var percentageCompleteText: String {
        String(format: "%.2f", 100 * percentageComplete)
    }
    
    var percentageComplete: Double {
        Double(checker.secondCellsChecked) / Double(checker.totalCountOfSecondCells)
    }
}
