//
//  PairBatch.swift
//  GridVacine2
//
//  Created by Matt Rips on 1/23/21.
//

import Foundation

class PairBatch: Identifiable, Equatable, Hashable, ObservableObject {
    let id = UUID()
    let firstCoordinate: Coordinate
    let i: Int
    let callBack: (Seeker.CheckResult) -> Void
    var progress: Double = 0
    var threadName: String = "unknown"
    var pointsToCheck: Int = 0
    var start: Date = Date()
    var aggregateCellsRemaining: Int = 0
    var pointsChecked: Int = 1
    var best: Int = 999999
    var worst: Int = 0
    
    static func ==(lhs: PairBatch, rhs: PairBatch) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    init(firstCoordinate: Coordinate, i: Int, callBack: @escaping (Seeker.CheckResult) -> Void) {
        self.firstCoordinate = firstCoordinate
        self.i = i
        self.callBack = callBack
    }
    
    func run(checker: GridChecker?, findAll: Bool) {
        start = Date()
        setThreadName()
        addToActive(in: checker)
        guard let size = checker?.size else { return }
        var pairValidator = PairValidator(size: size, firstAntiVaxBotLocation: firstCoordinate)
        let secondPointSequence = OneAntiVaxBotEndStateAndSequence(size: size, antiVaxBotLocation: firstCoordinate).firstVisits
        let countOfSecondPoints = secondPointSequence.count
        pointsToCheck = countOfSecondPoints
        let initialSecondPointToProcess = 0
        updateUI(with: checker)
        for j in (initialSecondPointToProcess..<countOfSecondPoints).reversed() {
            let secondCoordinate = secondPointSequence[j].coordinate
            guard secondCoordinate != firstCoordinate else {
                pointsChecked += 1
                updateCountOfCellsChecked(in: checker)
                continue
            }
            guard checker?.alreadyPaired(secondCoordinate, priorTo: i) == false else {
                pointsChecked += 1
                updateCountOfCellsChecked(in: checker)
                continue
            }
            pairValidator.runReverse(for: secondCoordinate)
            let cellsRemaining = pairValidator.validator.data.cellsRemaining
            aggregateCellsRemaining += cellsRemaining
            pointsChecked += 1
            if cellsRemaining < best { best = cellsRemaining }
            if cellsRemaining > worst { worst = cellsRemaining }
            if pairValidator.result == .success {
                let pair = ValidPair(p1: firstCoordinate, p2: secondCoordinate, i: i, j: j, best: best, worst: worst, average: averageCellsRemaining)
                if !findAll {
                    checker?.reportSuccessAndCancelWork(pair: pair, i: i, j: j, callBack: callBack)
                } else {
                    checker?.onSafeQueue {
                        checker?.validPairs.append(pair)
                    }
                }
            }
            if j.isMultiple(of: 128) {
                progress = Double(countOfSecondPoints - j) / Double(countOfSecondPoints)
                updateUI(with: checker)
            }
            updateCountOfCellsChecked(in: checker)
        }
        removeFromActive(in: checker)
    }
    
    var elapsedTime: TimeInterval {
        Date().timeIntervalSince(start)
    }
    
    var averageCellsRemaining: Int {
        aggregateCellsRemaining / pointsChecked
    }
    
    private func setThreadName() {
        if Thread.current.name == "" {
            Thread.current.name = String(i)
        }
        threadName = Thread.current.name ?? "no name"
    }
    
    private func addToActive(in checker: GridChecker?) {
        checker?.onSafeQueue {
            checker?.pairBatches.append(self)
        }
    }
    
    private func removeFromActive(in checker: GridChecker?) {
        checker?.onSafeQueue {
            if let batchIndex = checker?.pairBatches.firstIndex(of: self) {
                checker?.pairBatches.remove(at: batchIndex)
            }
        }
    }
    
    private func updateCountOfCellsChecked(in checker: GridChecker?) {
        checker?.onSafeQueue {
            checker?.secondCellsChecked += 1
            checker?.duration.increment()
        }
    }
    
    private func updateUI(with checker: GridChecker?) {
        DispatchQueue.main.async {
            checker?.objectWillChange.send()
            self.objectWillChange.send()
        }
    }
}
