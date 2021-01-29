//
//  ValidPair.swift
//  GridVacine2
//
//  Created by Matt Rips on 1/22/21.
//

import Foundation

struct ValidPair: Identifiable, CustomStringConvertible, Codable {
    let id: UUID
    let p1: Coordinate
    let p2: Coordinate
    let i: Int
    let j: Int
    let bestInBatch: Int
    let worstInBatch: Int
    let averageCellsRemainingInBatch: Int
    
    init(p1: Coordinate, p2: Coordinate, i: Int, j: Int, best: Int, worst: Int, average: Int) {
        self.id = UUID()
        self.p1 = p1
        self.p2 = p2
        self.i = i
        self.j = j
        self.bestInBatch = best
        self.worstInBatch = worst
        self.averageCellsRemainingInBatch = average
    }
    
    var description: String {
        "\(p1) & \(p2) at \(j) of \(i) [\(bestInBatch), \(averageCellsRemainingInBatch), \(worstInBatch)]"
    }
}

struct ValidPairMinimal: Identifiable, CustomStringConvertible, Codable {
    let id: UUID
    let p1: Coordinate
    let p2: Coordinate
    
    init(p1: Coordinate, p2: Coordinate) {
        self.id = UUID()
        self.p1 = p1
        self.p2 = p2
    }
    
    var description: String {
        "\(p1) & \(p2)"
    }
}
