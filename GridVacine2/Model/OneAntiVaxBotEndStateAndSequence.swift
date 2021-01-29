//
//  OneAntiVaxBotEndStateAndSequence.swift
//  GridVacine2
//
//  Created by Matt Rips on 1/21/21.
//

import Foundation

struct OneAntiVaxBotEndStateAndSequence {
    var validator: Validator
    var firstVisits: Array<FirstVisit> = []
    
    init(size: Int, antiVaxBotLocation: Coordinate) {
        self.validator = Validator(size: size, antiVaxBotLocations: [antiVaxBotLocation])
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
    }
}
