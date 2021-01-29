//
//  FullChecker.swift
//  GridVacine2
//
//  Created by Matt Rips on 1/15/21.
//

import AppKit

class GridChecker: ObservableObject, CellsRemainingEndPointDelegate, GridValidateEndpointDelegate {
    
    /// Constants
    let size: Int
    var countOfFirstCoordinates: Int = 0
    let queue = DispatchQueue.global(qos: .userInitiated)
    var settingUp: Bool = true
    private let checkerQueue = DispatchQueue(label: "checker")
    private let initialSearchState: SearchState?
    var gridValidatorEndpoint: GridValidateEndpoint
    var cellsRemainingEndPoint: CellsRemainingEndPoint
    var findAll: Bool = false
    
    /// Published Variables
    var firstCoordinatesChecked: Int = 0
    var countOfSuccesses: Int = 0
    var validPairs: Array<ValidPair> = []
    var start: Date!
    var workItems: Array<DispatchWorkItem> = []
    var done: Bool = false
    var searchSequence: Array<Coordinate> = []
    var loadingProgress: Double = 0
    var workItemPointer: Int = 0
    var secondCellsChecked: Int = 0
    var totalCountOfSecondCells: Int = 1
    let duration: Duration = Duration()
        
    var pairBatches: Array<PairBatch> = []
    
    init(size: Int, findAll: Bool, searchState: SearchState?, useLocalEndpoint: Bool = false) {
        self.size = size
        self.initialSearchState = searchState
        self.gridValidatorEndpoint = GridValidateEndpoint(size: size, findAll: findAll, useLocalEndpoint: useLocalEndpoint)
        self.cellsRemainingEndPoint = CellsRemainingEndPoint(size: size, useLocalEndpoint: useLocalEndpoint)
        cellsRemainingEndPoint.delegate = self
        gridValidatorEndpoint.delegate = self
    }
    
    func run() {
        start = Date()
        print("running checker")
        determineSearchPath()
    }
    
    func run(findAll: Bool, _ callBack: @escaping (Seeker.CheckResult) -> Void = {_ in }) {
        self.findAll = findAll
        start = Date()
        print("running checker")
        determineSearchPath()
    }
    
//    private func prepareToRun() {
//        let a = NoAntiVaxBotEndStateAndSequence(size: size)
//        let initialPointSequence = Array(a.firstVisits.reversed())
//        countOfFirstCoordinates = initialPointSequence.count
//        var grids: Array<(Coordinate, Int)> = []
//        for i in 0..<countOfFirstCoordinates {
//            if i.isMultiple(of: 4096) {
//                print(Double(i) / Double(countOfFirstCoordinates), Date().timeIntervalSince(start).hhmmss)
//            }
//            let firstCoordinate = initialPointSequence[i].coordinate
//            let cellsRemaining = OneAntiVaxBotEndStateAndSequence(size: self.size, antiVaxBotLocation: firstCoordinate).gridData.cellsRemaining
//            grids.append((firstCoordinate, cellsRemaining))
//            if i.isMultiple(of: 256) {
//                loadingProgress = Double(i) / Double(countOfFirstCoordinates)
//                DispatchQueue.main.async {
//                    self.objectWillChange.send()
//                }
//            }
//        }
//        grids.sort(by: { $0.1 < $1.1 })
//        searchSequence = grids.map { item in
//            item.0
//        }
//        let cellsPerGrid = size * size
//        totalCountOfSecondCells = grids.reduce(0) {
//            $0 + cellsPerGrid - $1.1
//        }
//        //duration.setUp(with: grids, size: size)
//        settingUp = false
//    }
    
    func determineSearchPath() {
        let naturalEndState = NoAntiVaxBotEndStateAndSequence(size: size)
        cellsRemainingEndPoint.start(with: naturalEndState.runs.chunked(into: 2))        
    }
    
    func completedRequestsForCellsRemaining() {
        DispatchQueue.main.async {
            self.searchSequence = self.cellsRemainingEndPoint.dataItems.map { dataItem in
                dataItem.coordinate
            }
            print("Starting pair validations.")
            self.gridValidatorEndpoint.startSearch(with: self.searchSequence)
        }
    }
    
//    private func createTasks() {
//        var index = 0
//        let partsCount = BatchPart.numberOfParts(for: size)
//        print("\(searchSequence.count) first coordinates to check split into \(partsCount) parts each")
//        for j in 0..<searchSequence.count {
//            let firstCoordinate = searchSequence[j]
//            for partIndex in 0..<partsCount{
//                let part = BatchPart(part: partIndex, parts: partsCount)
//                let task = gridValidatorEndpoint.makeTask(size: size, firstCoordinate: firstCoordinate, part: part, checker: self, index: index, findAll: findAll)
//                gridValidatorEndpoint.tasks.append(task)
//                index += 1
//            }
//            if j.isMultiple(of: 100) {
//                print("\(j) first coordinate tasks created")
//            }
//            if j == 1000 {
//                print("Starting dispatch of tasks")
//                startDispatchingTasks()
//                break
//            }
//        }
//        print("Done creating tasks to run simulations...")
//    }
    
//    private func startDispatchingTasks() {
//        gridValidatorEndpoint.startDispatchingTasks()
//    }
    
    func completedGridValidation() {
        completed()
    }
    
    func completed() {
        var validPairs: Array<ValidPairMinimal> = []
        gridValidatorEndpoint.results.forEach { result in
            validPairs.append(contentsOf: result.validPairs)
        }
        print("Grid Size \(size): \(validPairs.count) Valid Pairs:")
        validPairs.forEach { print($0) }
        print("Total elapsed time: \(Date().timeIntervalSince(start).hhmmss)")
    }
    
    private func createWorkItems(with callBack: @escaping (Seeker.CheckResult) -> Void, findAll: Bool) {
        loadingProgress = 0
        for i in searchSequence.indices {
            createWorkItem(i: i, firstCoordinate: searchSequence[i], callBack: callBack, findAll: findAll)
            if i.isMultiple(of: 256) {
                loadingProgress = Double(i) / Double(countOfFirstCoordinates)
                DispatchQueue.main.async {
                    self.objectWillChange.send()
                }
            }
        }
    }
    
    private func createWorkItem(i: Int, firstCoordinate: Coordinate,
                                callBack: @escaping (Seeker.CheckResult) -> Void, findAll: Bool) {
        let workItem = DispatchWorkItem() { [weak self] in
            let batch = PairBatch(firstCoordinate: firstCoordinate, i: i, callBack: callBack)
            batch.run(checker: self, findAll: findAll)
            self?.onSafeQueue {
                self?.firstCoordinatesChecked += 1
                self?.updateUI()
                self?.saveState(with: firstCoordinate)
                self?.dispatchNextWorkItem()
            }
        }
        workItems.append(workItem)
    }
    
    private func advanceToInitialSearchState() {
        guard let searchState = initialSearchState else { return }
        guard let position = searchSequence.firstIndex(where: { $0 == searchState.lastFirstCoordinateDone }) else { return }
        firstCoordinatesChecked = position
        workItemPointer = position + 1
        start = Date().advanced(by: -searchState.elapsedTime)
        secondCellsChecked = searchState.secondCellsChecked
    }
    
    private func dispatchInitialWorkItems(count: Int) {
        for _ in 0..<count {
            onSafeQueue {
                self.dispatchNextWorkItem()
            }
        }
    }
    
    private func updateUI() {
        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
    }
    
    private func saveState(with firstCoordinate: Coordinate) {
        checkerQueue.async {
            let state = SearchState(gridSize: self.size,
                                    lastFirstCoordinateDone: firstCoordinate,
                                    secondCellsChecked: self.secondCellsChecked,
                                    elapsedTime: Date().timeIntervalSince(self.start))
            state.writeToDisk()
        }
    }
    
    private func dispatchNextWorkItem() {
        guard !done else { return }
        if workItemPointer < workItems.endIndex {
            queue.async(execute: workItems[workItemPointer])
            workItemPointer += 1
        }
    }
    
    func onSafeQueue(_ block: @escaping ()->Void) {
        checkerQueue.async {
            block()
        }
    }
    
    var gridProgress: Double {
        Double(secondCellsChecked) / Double(totalCountOfSecondCells)
    }
    
    /// Determine whether a coordinate that is to be used as the second coordinate
    /// in a pair already was used as a first coordinate, such that the proposed pair
    /// already has been checked.  ISSUE: This may result in skipping over a pair that
    /// has not yet been checked.
    func alreadyPaired(_ coordinate: Coordinate, priorTo position: Int) -> Bool {
        searchSequence[0..<position].contains { $0 == coordinate }
    }
    
    func reportSuccessAndCancelWork(pair: ValidPair, i: Int, j: Int, callBack: @escaping (Seeker.CheckResult) -> Void) {
        onSafeQueue {
            guard self.done == false else { return }
            self.done = true
            self.countOfSuccesses += 1
            self.validPairs.append(pair)
            print("Grid \(self.size) on search step \(i), \(j):  \(pair)")
            self.workItems.forEach { workItem in
                workItem.cancel()
            }
            let result = Seeker.CheckResult(gridSize: self.size, validPair: pair, searchPrimaryStep: i, searchSecondaryStep: j, elapsedTime: Date().timeIntervalSince(self.start))
            callBack(result)
        }
    }
    
    func copyResultsToClipboard() {
        var result = ""
        result += "Grid Size: \(size)\n"
        result += "Number of Valid Pairs: \(validPairs.count)\n"
        result += "\n"
        validPairs.forEach { pair in
            result += "\(pair)\n"
        }
        result.removeLast()
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(result, forType: .string)
    }
    
    struct SearchState: Writable {
        let gridSize: Int
        let lastFirstCoordinateDone: Coordinate /// could result in skipping of up to three
        let secondCellsChecked: Int
        let elapsedTime: TimeInterval
        var filename: String = "GridSearchState"
    }
}


