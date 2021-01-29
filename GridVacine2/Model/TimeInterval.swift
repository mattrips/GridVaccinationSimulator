//
//  TimeInterval.swift
//  GridVacine2
//
//  Created by Matt Rips on 1/21/21.
//

import Foundation

extension TimeInterval {
    var hhmmss: String {
        let endingDate = Date()
        let startingDate = endingDate.addingTimeInterval(-self)
        let calendar = Calendar.current
        let componentsNow = calendar.dateComponents([.hour, .minute, .second], from: startingDate, to: endingDate)
        if let hour = componentsNow.hour, let minute = componentsNow.minute, let seconds = componentsNow.second {
            if hour > 0 {
                return "\(String(format: "%02d", hour)):\(String(format: "%02d", minute)):\(String(format: "%02d", seconds))"
            } else {
                return "\(String(format: "%02d", minute)):\(String(format: "%02d", seconds))"
            }
        } else {
            return "00:00:00"
        }
    }
    
    var mmssSSS: String {
        let endingDate = Date()
        let startingDate = endingDate.addingTimeInterval(-self)
        let calendar = Calendar.current
        let componentsNow = calendar.dateComponents([.minute, .second, .nanosecond], from: startingDate, to: endingDate)
        if let minute = componentsNow.minute, let seconds = componentsNow.second, let nanoSecond = componentsNow.nanosecond {
            let milliSecond = nanoSecond / 1_000_000
            return "\(String(format: "%02d", minute)):\(String(format: "%02d", seconds)).\(String(format: "%03d", milliSecond))"
        } else {
            return "00:00.000"
        }
    }
    
    var hhmm: String {
        let endingDate = Date()
        let startingDate = endingDate.addingTimeInterval(-self)
        let calendar = Calendar.current
        let componentsNow = calendar.dateComponents([.hour, .minute, .second], from: startingDate, to: endingDate)
        if let hour = componentsNow.hour, let minute = componentsNow.minute, let seconds = componentsNow.second {
            return "\(String(format: "%02d", hour)):\(String(format: "%02d", minute))"
        } else {
            return "00:00:00"
        }
    }
}
