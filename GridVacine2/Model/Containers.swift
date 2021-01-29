//
//  Containers.swift
//  GridVacine2
//
//  Created by Matt Rips on 1/27/21.
//

import Foundation

class Containers {
    static var dict: Dictionary<UUID, Int> = [:]
    static var nextId: Int = 1
    
    static func getId(for containerInfo: ContainerInfo) -> Int {
        if let id = dict[containerInfo.uuid] {
            return id
        } else {
            let id = nextId
            dict[containerInfo.uuid] = id
            nextId += 1
            return id
        }
    }
}
