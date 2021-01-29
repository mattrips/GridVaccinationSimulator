//
//  Coordinate.swift
//  GridVacine2
//
//  Created by Matt Rips on 1/3/21.
//

import Foundation

struct Coordinate: Equatable, Hashable, CustomStringConvertible, Codable {
    let x: Int
    let y: Int
    
    static var zero: Coordinate { Coordinate(x: 0, y: 0) }
    
    var description: String {
        "(\(x), \(y))"
    }
}
