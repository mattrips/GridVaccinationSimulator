//
//  GridData.swift
//  GridVacine2
//
//  Created by Matt Rips on 1/16/21.
//

import Foundation

struct GridData {
    private var data: Array<Array<Cell>>
    private(set) var cellsRemaining: Int
    
    init(size: Int) {
        let clearCell = Cell()
        let clearRow = Array(repeating: clearCell, count: size)
        self.data = Array(repeating: clearRow, count: size)
        self.cellsRemaining = size * size
    }
    
    @inline(__always) mutating func set(_ coordinate: Coordinate, to state: UInt8) {
        data[coordinate.y][coordinate.x].state = state
    }
    
    @inline(__always) mutating func set(x: Int, y: Int, to state: UInt8) {
        data[y][x].state = state
    }
    
    @inline(__always) func state(at coordinate: Coordinate) -> UInt8 {
        data[coordinate.y][coordinate.x].state
    }
    
    @inline(__always) func state(x: Int, y: Int) -> UInt8 {
        data[y][x].state
    }
    
    @inline(__always) mutating func incrementVisits(x: Int, y: Int) {
        data[y][x].visited()
    }
    
    @inline(__always) func visits(x: Int, y: Int) -> UInt8 {
        data[y][x].visits
    }
    
    @inline(__always) mutating func positionAntiVaxBots(at coordinates: [Coordinate]) {
        for coordinate in coordinates {
            data[coordinate.y][coordinate.x].state = 3 // antiVax Bot
            cellsRemaining &-= 1
        }
    }
    
    @inline(__always) mutating func decrementCellsRemaining() {
        cellsRemaining &-= 1
    }
    
    var rawData: Array<Array<Cell>> {
        data
    }
    
    var gridImage: String {
        var grid = ""
        for y in 0..<data.count {
            var row = ""
            for x in 0..<data.count {
                row += "\(data[y][x].stateSymbol) "
            }
            row += "\n"
            grid += row
        }
        return String(grid.dropLast())
    }
    
    struct Cell {
        private var value: UInt8 = 0b00000100
        
        /// 0 = not vacinatted; 1 = has received first shot; 2 = fully vaccinated; 3 = antiVaxBot
        var state: UInt8 {
            get {
                value & 0b00000011
            }
            set {
                assert(newValue <= 3)
                value &= 0b11111100
                value |= newValue
            }
        }
        
        /// 4 = not visited; 8 = once visited; 12 = visited more than once
        @inline(__always) var visits: UInt8 {
            get {
                value & 0b00001100
            }
            set {
                assert(newValue == 4 || newValue == 8 || newValue == 12)
                value &= 0b11110011
                value |= newValue
            }
        }
        
        @inline(__always) mutating func visited() {
            visits = (visits == 4) ? 8 : 12
        }
        
        var stateSymbol: String {
            switch state {
            case 0:
                return "0"
            case 1:
                return "X"
            case 2:
                return "·"
            case 3:
                return "*"
            default:
                return "@"
            }
        }
    }
}
