//
//  File.swift
//  
//
//  Created by Matt Rips on 1/28/21.
//

import Foundation

struct DebugInfo: Codable, CustomStringConvertible, Equatable, Hashable {
    private let stopWatch: StopWatch
    private var clientDispatched: TimeInterval? = nil
    private var serverReceived: TimeInterval? = nil
    private var serverProcessingStarted: TimeInterval? = nil
    private var serverProcessingEnded: TimeInterval? = nil
    private var clientReceived: TimeInterval? = nil
    
    init() {
        self.stopWatch = StopWatch()
    }
    
    mutating func dispatched() { clientDispatched = stopWatch.time }
    mutating func receivedByServer() { serverReceived = stopWatch.time }
    mutating func processingStarted() { serverProcessingStarted = stopWatch.time }
    mutating func processingEnded() { serverProcessingEnded = stopWatch.time }
    mutating func receivedByClient() { clientReceived = stopWatch.time }
    
    var description: String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .long
        dateFormatter.dateStyle = .none
        let startString = dateFormatter.string(from: stopWatch.startTime)
        return "\(startString) -> \(clientDispatched?.mmssSSS ?? "NA") -> \(serverReceived?.mmssSSS ?? "NA") -> \(serverProcessingStarted?.mmssSSS ?? "NA") -> \(serverProcessingEnded?.mmssSSS ?? "NA") -> \(clientReceived?.mmssSSS ?? "NA")"
    }
}
