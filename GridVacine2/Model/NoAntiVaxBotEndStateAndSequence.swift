//
//  NoAntiVaxBotEndStateAndSequence.swift
//  GridVacine2
//
//  Created by Matt Rips on 1/21/21.
//

import Foundation

struct NoAntiVaxBotEndStateAndSequence {
    var size: Int
    var validator: Validator
    var firstVisits: Array<FirstVisit> = []
    var runs: Array<Run> = []
    
    init(size: Int) {
        self.size = size
        self.validator = Validator(size: size, antiVaxBotLocations: [])
        print("creating NoAntiVaxBot...")
        run()
    }
    
    var gridData: GridData {
        validator.data
    }
    
    private mutating func run() {
        /// Iterate until all cells have received two shots (other than cells
        /// occupied by AntiVax Bots) or until stuck in loop.
        while validator.notDone {
            validator.incrementCurrentCellVisits()
            if validator.currentCellVisits == 8 {
                firstVisits.append(FirstVisit(coordinate: Coordinate(x: validator.x, y: validator.y), step: validator.step))
            }
            validator.next()
        }
        assembleRuns()
    }
    
    private mutating func assembleRuns() {
        for x in 0..<size {
            var startIndex: Int? = nil
            for y in 0..<size {
                let state = gridData.rawData[y][x].state
                if startIndex == nil {
                    if state != 0 {
                        startIndex = y
                    }
                } else {
                    if state == 0 {
                        runs.append(Run(x: x, yRange: startIndex!..<y))
                        startIndex = nil
                    }
                }
            }
            if startIndex != nil {
                runs.append(Run(x: x, yRange: startIndex!..<size))
                startIndex = -1
            }
        }
        print("Done assembling runs: \(runs.count) runs.")
    }
}
