//
//  ElapsedTimeView.swift
//  GridVacine2
//
//  Created by Matt Rips on 1/22/21.
//

import SwiftUI

struct ElapsedTimeView: View {
    @ObservedObject var checker: GridChecker
    
    var body: some View {
        HStack {
            Text("Elapsed Time: \(checker.duration.elapsedTime.hhmmss)").font(Font.system(size: 12, design: .monospaced).monospacedDigit())
            Spacer()
            Text("Estimated Time Remaining (HH:MM): \(checker.duration.weightedEstimatedTimeRemaining.hhmm)").font(Font.system(size: 12, design: .monospaced).monospacedDigit())
        }.animation(.default)
    }
    
    var estimatedTimeRemaining: String {
        percentageComplete != 0 ? ((elapsedTime / percentageComplete) - elapsedTime).hhmm : "..."
    }
    
    var elapsedTime: Double {
        Date().timeIntervalSince(checker.start)
    }
    
    var percentageComplete: Double {
        Double(checker.secondCellsChecked) / Double(checker.totalCountOfSecondCells)
    }
}
