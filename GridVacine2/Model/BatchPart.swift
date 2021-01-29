//
//  BatchPart.swift
//  GridVacine2
//
//  Created by Matt Rips on 1/24/21.
//

import Foundation

struct BatchPart: Codable {
    let part: Int
    let parts: Int
    
    func range(within count: Int) -> Range<Int> {
        let unitsPerPart = count / parts
        let startIndex = unitsPerPart * part
        let endIndex = (part == parts - 1) ? count : (unitsPerPart * (part + 1))
        return startIndex..<endIndex
    }
    
    static func numberOfParts(for size: Int) -> Int {
        guard size > 200 else { return 1 }
        let scale = Double(size) / Double(200)
        return Int(scale * scale * scale * scale * scale * scale)
    }
}
