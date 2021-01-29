//
//  Date.swift
//  GridVacine2
//
//  Created by Matt Rips on 1/27/21.
//

import Foundation

extension Date {
    var elapsedTime: TimeInterval {
        Date().timeIntervalSince(self)
    }
}

struct StopWatch: Codable, CustomStringConvertible, Equatable, Hashable {
    let start: Date
    
    init() {
        self.start = Date()
    }
    
    var startTime: Date {
        return start
    }
    
    var time: TimeInterval {
        Date().timeIntervalSince(start)
    }
    
    var description: String {
        "\(time.hhmmss)"
    }
}
