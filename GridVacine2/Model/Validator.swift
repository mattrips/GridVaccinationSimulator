//
//  Validator.swift
//  GridVacine2
//
//  Created by Matt Rips on 1/21/21.
//

import Foundation

struct Validator {
    
    /// Setup local variables.
    var data: GridData
    var x: Int = 0
    var y: Int = 0
    var direction: Direction = .up
    var loopDetectionCount: Int = 0
    var step: Int = 0
    
    /// Setup local constants.
    let upperBound: Int
    let rowLength: Int
    let lastRowStartByteIndex: Int
    let loopFaultThreshold: Int
    
    init(size: Int, antiVaxBotLocations coordinates: [Coordinate]) {
        self.data = GridData(size: size)
        self.upperBound = size - 1
        self.rowLength = size
        self.lastRowStartByteIndex = Int(rowLength * Int(upperBound))
        self.loopFaultThreshold = size * 4
        data.positionAntiVaxBots(at: coordinates)
    }
    
    init(size: Int, data: GridData, x: Int, y: Int, direction: Direction) {
        self.data = data
        self.x = x
        self.y = y
        self.direction = direction
        self.upperBound = size - 1
        self.rowLength = size
        self.lastRowStartByteIndex = Int(rowLength * Int(upperBound))
        self.loopFaultThreshold = size * 4
    }
        
    @inline(__always) mutating func incrementCurrentCellVisits() {
        data.incrementVisits(x: x, y: y)
    }
    
    @inline(__always) var currentCellVisits: UInt8 {
        data.visits(x: x, y: y)
    }
    
    @inline(__always) var notDone: Bool {
        loopDetectionCount < loopFaultThreshold
    }
    
    var gridImage: String {
        var grid = ""
        for y in 0..<rowLength {
            var row = ""
            for x in 0..<rowLength {
                row += "\(data.state(x: x, y: y)) "
            }
            row += "\n"
            grid += row
        }
        return String(grid.dropLast())
    }
    
    mutating func check() {
        /// Iterate until all cells have received two shots (other than cells
        /// occupied by AntiVax Bots) or until stuck in loop.
        while data.cellsRemaining != 0 && loopDetectionCount < loopFaultThreshold {
            next()
        }
    }
    
    @inline(__always) mutating func next() {
        /// Depending upon current value of cell state, change value of cell state
        /// and/or rotate.
        switch data.state(x: x, y: y) {
        case 2: // fully vaccinated
            loopDetectionCount += 1
        case 0: // not vaccinated
            data.set(x: x, y: y, to: 1)
            direction = direction.rotatedClockwise()
            loopDetectionCount = 0
        case 1: // has received first shot
            data.set(x: x, y: y, to: 2)
            direction = direction.rotatedCounterclockwise()
            loopDetectionCount = 0
            data.decrementCellsRemaining()
        case 3: // antiVax Bot
            direction = direction.rotatedCounterclockwise()
            loopDetectionCount += 1
        default:
            break
        }
        
        /// Move the current (x, y) coordinate and indices
        /// to point to next cell in the current direction.
        switch direction {
        case .up:
            if y != 0 {
                y &-= 1
            } else {
                y = upperBound
            }
        case .right:
            if x != upperBound {
                x &+= 1
            } else {
                x = 0
            }
        case .down:
            if y != upperBound {
                y &+= 1
            } else {
                y = 0
            }
        case .left:
            if x != 0 {
                x &-= 1
            } else {
                x = upperBound
            }
        }
    }
    
    enum Result: Equatable {
        case success, failure
    }
}
