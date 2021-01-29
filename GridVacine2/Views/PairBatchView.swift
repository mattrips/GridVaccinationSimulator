//
//  PairBatchView.swift
//  GridVacine2
//
//  Created by Matt Rips on 1/22/21.
//

import SwiftUI

struct PairBatchView: View {
    @ObservedObject var batch: PairBatch
    
    var body: some View {
        ZStack {
            Color.purple
            HStack {
                ProgressView(progressRatio: batch.progress).padding(EdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 0))
                Text("\(batch.firstCoordinate.description): \(batch.pointsToCheck) cells in \(batch.elapsedTime.hhmmss) [\(batch.best), \(batch.averageCellsRemaining), \(batch.worst)]").font(Font.system(size: 10, design: .monospaced).monospacedDigit())
                Spacer()
            }.animation(.default)
        }
    }
    
    var backgroundColor: Color {
        switch batch.threadName {
        case "0":
            return Color(.sRGB, red: 35, green: 107, blue: 181, opacity: 1)
        case "1":
            return Color(.sRGB, red: 38, green: 115, blue: 195, opacity: 1)
        case "2":
            return Color(.sRGB, red: 43, green: 124, blue: 208, opacity: 1)
        case "3":
            return Color(.sRGB, red: 46, green: 132, blue: 221, opacity: 1)
        case "4":
            return Color(.sRGB, red: 49, green: 139, blue: 232, opacity: 1)
        case "5":
            return Color(.sRGB, red: 50, green: 144, blue: 241, opacity: 1)
        default:
            return Color(.sRGB, red: 51, green: 148, blue: 249, opacity: 1)
        }
    }
}
