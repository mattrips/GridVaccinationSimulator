//
//  CellsRemainingEndPoint.swift
//  GridVacine2
//
//  Created by Matt Rips on 1/24/21.
//

import Foundation

protocol CellsRemainingEndPointDelegate {
    func completedRequestsForCellsRemaining()
}

class CellsRemainingEndPoint {
    private let size: Int
    private var tasks: Tasks = Tasks()
    private var runGroups: Array<Array<Run>> = []
    private var runGroupPointer: Int = 0
    private var responses: Array<CellsRemainingResponse> = []
    private var done: Bool = false
    var delegate: CellsRemainingEndPointDelegate? = nil
    var dataItems: Array<CellsRemainingDataItem> = []
    let stopWatch = StopWatch()
    private var useLocalEndpoint: Bool
    private var urlString: String {
        if useLocalEndpoint {
            return "http://127.0.0.1:8080/cellsRemainingForOneBotGrid"
        } else {
            return "https://mattrips-hlg7lvj2cq-uw.a.run.app/cellsRemainingForOneBotGrid"
        }
    }
    private var initialDeploymentCounter: Int = 30
    private let timeoutInterval: TimeInterval = 120
    private let queue: DispatchQueue = DispatchQueue(label: "CellsRemainingEndPointQueue")
    
    init(size: Int, useLocalEndpoint: Bool = false) {
        self.size = size
        self.useLocalEndpoint = useLocalEndpoint
        dataItems.reserveCapacity(size * size)
    }
    
    private func nextRuns() -> Array<Run>? {
        guard runGroupPointer < runGroups.endIndex else { return nil }
        let runs = self.runGroups[runGroupPointer]
        runGroupPointer += 1
        return runs
    }
    
    private func createTask() -> Task? {
        guard let runs = nextRuns() else { return nil }
        var cellsRemainingRequest = CellsRemainingRequest(size: size, runs: runs)
        cellsRemainingRequest.debugInfo.dispatched()
        return createTask(for: cellsRemainingRequest)
    }
    
    func start(with runs: Array<Array<Run>>) {
        self.runGroups = runs
        startDeployingTasks()
    }
    
    private func startDeployingTasks() {
        print("starting dispatch: \(runGroups.count)")
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let counter = self?.initialDeploymentCounter else {
                timer.invalidate()
                return
            }
            guard self?.done == false else { return }
            if counter > 0 {
                self?.deployNextTask()
                self?.initialDeploymentCounter -= 1
            } else {
                timer.invalidate()
            }
        }
    }
    
    func combineAndSortDataItems() {
        responses.forEach { response in
            dataItems.append(contentsOf: response.dataItems)
        }
        dataItems.sort(by: { $0.cellsRemaining < $1.cellsRemaining })
    }
    
    private func createTask(for cellsRemainingRequest: CellsRemainingRequest) -> Task {
        let urlTask = makeURLTask(for: cellsRemainingRequest)
        let task = Task(cellsRemainingRequest: cellsRemainingRequest, urlTask: urlTask)
        tasks.insert(task)
        return task
    }
    
    private func makeURLTask(for cellsRemainingRequest: CellsRemainingRequest) -> URLSessionDataTask {
        guard let url = URL(string:  urlString) else {
            fatalError()
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.timeoutInterval = 600
        let jsonEncoder = JSONEncoder()
        jsonEncoder.dateEncodingStrategy = .iso8601
        let jsonData = try! jsonEncoder.encode(cellsRemainingRequest)
        urlRequest.httpBody = jsonData
        let task = URLSession.shared.dataTask(with: urlRequest) { [weak self] (data, response, error) in
            self?.queue.async {
                self?.responseHandler(cellsRemainingRequest: cellsRemainingRequest, data: data, response: response, error: error)
            }
        }
        return task
    }
    
    private func deployNextTask() {
        queue.async { [weak self] in
            guard self?.done == false else { return }
            if let task = self?.createTask() {
                task.deploy()
            }
        }
    }
    
    private func responseHandler(cellsRemainingRequest: CellsRemainingRequest, data: Data?, response: URLResponse?, error: Error?) {
        /// If end point has completed all requests, disregard further responses.
        guard done == false else { return }
        
        /// If error is present, report it, and resubmit the request.
        guard error == nil else {
            print("Error occurred:\n\(error!)")
            resubmit(cellsRemainingRequest)
            return
        }
    
        /// Response must be present.  Handle it.
        guard let response = response as? HTTPURLResponse else {
            fatalError("No response in response to CellsRemainingRequest: \(cellsRemainingRequest)")
        }
        switch response.statusCode {
        case 200:
            handle(data, with: cellsRemainingRequest)
        case 408:
            print("\(cellsRemainingRequest): timeout error; resubmiting request.")
            resubmit(cellsRemainingRequest)
        default:
            let dataString = String(data: data!, encoding: .utf8)!
            print("Unhandled status code: \(response.statusCode)")
            print(dataString)
        }
    }
    
    private func handle(_ data: Data?, with cellsRemainingRequest: CellsRemainingRequest) {
        /// Data should be present.  Handle it.
        guard let data = data else {
            fatalError("No error in response to CellsRemainingRequest, yet no data either: \(cellsRemainingRequest)")
        }
        do {
            let jsonDecoder = JSONDecoder()
            jsonDecoder.dateDecodingStrategy = .iso8601
            var cellsRemainingResponse = try jsonDecoder.decode(CellsRemainingResponse.self, from: data)
            cellsRemainingResponse.request.debugInfo.receivedByClient()
            handle(cellsRemainingResponse)
            removeTask(cellsRemainingRequest)
            deployNextTask()
        } catch {
            handle(data, for: cellsRemainingRequest, with: error)
            resubmit(cellsRemainingRequest)
        }
    }
    
    private func handle(_ cellsRemainingResponse: CellsRemainingResponse) {
        responses.append(cellsRemainingResponse)
        DispatchQueue.main.async { [weak self] in
            guard let resultCount = self?.responses.count else { fatalError() }
            guard let stopWatch = self?.stopWatch else { fatalError() }
            let request = cellsRemainingResponse.request
            print("\(resultCount) completed: \(request.runs.map { $0.x }) - Container \(Containers.getId(for: cellsRemainingResponse.containerInfo)) - \(cellsRemainingResponse.elapsedTime.mmssSSS) - \(request.debugInfo) - \(stopWatch)")
        }
    }
    
    private func removeTask(_ cellsRemainingRequest: CellsRemainingRequest) {
        tasks.remove(for: cellsRemainingRequest)
        if isComplete {
            done = true
            combineAndSortDataItems()
            print(stopWatch)
            delegate?.completedRequestsForCellsRemaining()
        }
    }
    
    private var isComplete: Bool {
        tasks.isEmpty && runGroups.endIndex == runGroupPointer
    }
    
    private func handle(_ data: Data, for cellsRemainingRequest: CellsRemainingRequest, with error: Error) {
        DispatchQueue.main.async {
            if let dataString = String(data: data, encoding: .utf8) {
                print("COULD NOT DECODE:")
                print("\(cellsRemainingRequest): \(dataString)")
            } else {
                print(error)
            }
        }
    }
    
    private func resubmit(_ cellsRemainingRequest: CellsRemainingRequest) {
        guard !done else { return }
        guard !tasks.hasReachedRetryLimit(for: cellsRemainingRequest) else { return }
        let task = makeURLTask(for: cellsRemainingRequest)
        task.resume()
        tasks.markRetry(for: cellsRemainingRequest)
    }
    
    struct Task: Equatable {
        let cellsRemainingRequest: CellsRemainingRequest
        let urlTask: URLSessionDataTask
        var retryAttemptCount: Int = 0
        
        static func == (lhs: Task, rhs: Task) -> Bool {
            lhs.cellsRemainingRequest == rhs.cellsRemainingRequest
        }
        
        func deploy() {
            urlTask.resume()
        }
        
        mutating func markRetry() {
            retryAttemptCount += 1
        }
        
        var hasReachedRetryLimit: Bool {
            retryAttemptCount >= 3
        }
    }
    
    struct Tasks {
        private var data: Dictionary<CellsRemainingRequest, Task> = [:]
        private var deploymentKey: Int = 0
    
//        subscript(_ x: Int) -> Task? {
//            get { data[x] }
//            set { data[x] = newValue }
//        }
        
        mutating func insert(_ task: Task) {                data[task.cellsRemainingRequest] = task
        }
        
        mutating func remove(for cellsRemainingRequest: CellsRemainingRequest) {
            data[cellsRemainingRequest] = nil
        }
        
//        mutating func deploy(for cellsRemainingRequest: CellsRemainingRequest) {
//            data[cellsRemainingRequest]?.deploy()
//        }
        
        mutating func markRetry(for cellsRemainingRequest: CellsRemainingRequest) {
            data[cellsRemainingRequest]?.markRetry()
        }
                
        var count: Int { data.count }
        
        var isEmpty: Bool { data.isEmpty }
        
        func hasReachedRetryLimit(for cellsRemainingRequest: CellsRemainingRequest) -> Bool {
            guard let task = data[cellsRemainingRequest] else { return true }
            return task.hasReachedRetryLimit
            
        }
    }
}
