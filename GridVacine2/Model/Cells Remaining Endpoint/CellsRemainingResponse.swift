//
//  File.swift
//  
//
//  Created by Matt Rips on 1/24/21.
//

import Foundation

struct CellsRemainingResponse: Codable {
    var request: CellsRemainingRequest
    let containerInfo: ContainerInfo
    let elapsedTime: TimeInterval
    let dataItems: Array<CellsRemainingDataItem>
}
