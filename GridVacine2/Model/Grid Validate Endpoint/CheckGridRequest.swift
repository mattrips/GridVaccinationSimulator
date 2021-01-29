//
//  CheckGridRequest.swift
//  GridVacine2
//
//  Created by Matt Rips on 1/25/21.
//

import Foundation

struct CheckGridRequest: Codable {
    let size: Int
    let firstCoordinate: Coordinate
    let part: BatchPart
    var debugInfo = DebugInfo()
}
