//
//  Duration.swift
//  GridVacine2
//
//  Created by Matt Rips on 1/23/21.
//

import Foundation

class Duration: ObservableObject {
    private var _start: Date
    private var totalPairs: Int = 0
    private var pairsChecked: Int = 0
    private var weightedValues = Array<Int>()
    private var totalWeight: Int = 0
    private var pointer: Int = 0
    private var weightChecked: Int = 0
    
    init() {
        self._start = Date()
    }
    
    /// Grids should be presorted with smallest number of cellsRemaining first.
    func setUp(with grids: Array<(Coordinate, GridData)>, size: Int) {
        let cellsPerGrid = size * size
        totalPairs = grids.reduce(0) {
            $0 + cellsPerGrid - $1.1.cellsRemaining
        }
        grids.forEach {
            weightedValues.append(contentsOf: Array(repeating: cellsPerGrid - $0.1.cellsRemaining, count: $0.1.cellsRemaining))
        }
        totalWeight = weightedValues.reduce(0) { $0 + $1 }
    }
    
    var start: Date { _start }
    
    var elapsedTime: TimeInterval {
        Date().timeIntervalSince(_start)
    }
    
    var rawRatioComplete: Double {
        Double(pairsChecked) / Double(totalPairs)
    }
    
    var weightedRatioComplete: Double {
        Double(weightChecked) / Double(totalWeight)
    }
    
    var weightedEstimatedTotalTime: TimeInterval {
        elapsedTime / weightedRatioComplete
    }
    
    var weightedEstimatedTimeRemaining: TimeInterval {
        weightedEstimatedTotalTime - elapsedTime
    }
    
    func increment() {
        pairsChecked += 1
        if pointer < weightedValues.endIndex {
            weightChecked += weightedValues[pointer]
        }
        pointer += 1
    }
    
}
