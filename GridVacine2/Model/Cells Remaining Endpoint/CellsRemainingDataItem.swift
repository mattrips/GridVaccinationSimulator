//
//  CellsRemainingDataItem.swift
//  GridVacine2
//
//  Created by Matt Rips on 1/26/21.
//

import Foundation

struct CellsRemainingDataItem: Codable {
    let coordinate: Coordinate
    let cellsRemaining: Int
}
