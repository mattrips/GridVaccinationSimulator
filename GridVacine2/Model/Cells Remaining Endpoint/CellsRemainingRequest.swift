//
//  File.swift
//  
//
//  Created by Matt Rips on 1/24/21.
//

import Foundation

struct CellsRemainingRequest: Codable, Hashable, Equatable {
    let size: Int
    let runs: Array<Run>
    var debugInfo: DebugInfo = DebugInfo()
}
