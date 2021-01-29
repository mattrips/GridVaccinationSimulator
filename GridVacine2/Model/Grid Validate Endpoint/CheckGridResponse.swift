//
//  CheckGridResponse.swift
//  GridVacine2
//
//  Created by Matt Rips on 1/25/21.
//

import Foundation

struct CheckGridResponse: Codable {
    var request: CheckGridRequest
    let containerInfo: ContainerInfo
    let elapsedTime: TimeInterval
    let validPairs: Array<ValidPairMinimal>
}

extension CheckGridResponse {
    var hasValidPairs: Bool {
        !validPairs.isEmpty
    }
}
