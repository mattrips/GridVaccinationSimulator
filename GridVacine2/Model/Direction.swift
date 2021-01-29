//
//  Direction.swift
//  GridVacine2
//
//  Created by Matt Rips on 1/3/21.
//

import Foundation

enum Direction: UInt8 {
    case up, right, down, left
    
    @inline(__always) func rotatedClockwise() -> Direction {
        if self != .left {
            return Direction(rawValue: rawValue + 1)!
        } else {
            return .up
        }
    }
    
    @inline(__always) func rotatedCounterclockwise() -> Direction {
        if self != .up {
            return Direction(rawValue: rawValue - 1)!
        } else {
            return .left
        }
    }
}
