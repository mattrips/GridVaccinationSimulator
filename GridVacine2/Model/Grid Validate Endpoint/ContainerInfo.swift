//
//  ContainerInfo.swift
//  GridVacine2
//
//  Created by Matt Rips on 1/25/21.
//

import Foundation

struct ContainerInfo: Codable {
    let creationDate: String
    let currentDate: String
    let uuid: UUID
    let text: String
}
