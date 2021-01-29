//
//  PostRequest.swift
//  GridVacine2
//
//  Created by Matt Rips on 1/23/21.
//

import Foundation

protocol GridValidateEndpointDelegate {
    func completedGridValidation()
}

class GridValidateEndpoint {
    let size: Int
    let findAll: Bool
    var searchIndex: Int = 0
    var searchSequence: Array<Coordinate> = []
    var taskIndex: Int = 0
    var results: Array<CheckGridResponse> = []
    var done: Bool = false
    var delegate: GridValidateEndpointDelegate? = nil
    private var useLocalEndpoint: Bool
    private var urlString: String {
        if useLocalEndpoint {
            return "http://127.0.0.1:8080/validateGridFuture"
        } else {
            return "https://mattrips-hlg7lvj2cq-uw.a.run.app/validateGridFuture"
        }
    }
    private let queue: DispatchQueue = DispatchQueue(label: "GridValidateEndpointQueue")
    private let session: URLSession

    
    /// https://www.appsdeveloperblog.com/http-post-request-example-in-swift/
    
    init(size: Int, findAll: Bool, useLocalEndpoint: Bool) {
        self.size = size
        self.findAll = findAll
        self.useLocalEndpoint = useLocalEndpoint
        self.session = URLSession(configuration: URLSessionConfiguration.ephemeral)
        self.session.sessionDescription = "Grid Validation URLSession"
    }
    
    func startSearch(with sequence: Array<Coordinate>) {
        self.searchSequence = sequence
        start()
    }
    
    var isComplete: Bool {
        searchIndex == searchSequence.endIndex && (results.endIndex + 10) == taskIndex
    }
    
    func makeTask(firstCoordinate: Coordinate, part: BatchPart, index: Int) -> URLSessionDataTask {
        // Prepare URL
        guard let url = URL(string:  urlString) else {
            fatalError()
        }

        // Prepare URL Request Object
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Set HTTP Request Headers
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.timeoutInterval = 600
        
        // Set HTTP Request Body Using Codable Struct
        var checkGridRequest = CheckGridRequest(size: size, firstCoordinate: firstCoordinate, part: part)
        checkGridRequest.debugInfo.dispatched()
        
        let jsonEncoder = JSONEncoder()
        jsonEncoder.dateEncodingStrategy = .iso8601
        let jsonData = try! jsonEncoder.encode(checkGridRequest)
        request.httpBody = jsonData
        
        func resubmit() {
            print(checkGridRequest)
            guard !done else { return }
            let newTask = makeTask(firstCoordinate: firstCoordinate, part: part, index: index)
            newTask.resume()
            print("Task resubmitted...")
        }

        // Perform HTTP Request
        let task = session.dataTask(with: request) { [weak self] (data, response, error) in
            guard self?.done == false else { return }
                    
            // Check for Error
            if let error = error {
                print("Error took place \(error)")
                resubmit()
                return
            }
            
            // Convert HTTP Response Data to a Codable Struct
            guard let data = data else { return }
            do {
                let jsonDecoder = JSONDecoder()
                jsonDecoder.dateDecodingStrategy = .iso8601
                var checkGridResponse = try jsonDecoder.decode(CheckGridResponse.self, from: data)
                checkGridResponse.request.debugInfo.receivedByClient()
                self?.results.append(checkGridResponse)
                let requestCount = self!.taskIndex
                DispatchQueue.main.async {
                    guard let resultCount = self?.results.count else { return }
                    print("\(resultCount) completed: \(self!.results[resultCount - 1].elapsedTime.hhmmss) - part \(part.part + 1) of \(part.parts) of \(firstCoordinate) - request index \(index) of \(requestCount) - Container \(Containers.getId(for: checkGridResponse.containerInfo)) - \(checkGridResponse.request.debugInfo)")
                    if checkGridResponse.hasValidPairs {
                        print("Valid pair(s) found at index \(index) including \(checkGridResponse.validPairs.first!).")
                        if self?.findAll == false {
                            self?.endSession()
                        }
                    }
                    if self?.isComplete == true {
                        self?.endSession()
                    }
                    self?.deployNextTask()
                }
            } catch {
                DispatchQueue.main.async {
                    if let dataString = String(data: data, encoding: .utf8) {
                        print("\(firstCoordinate): \(dataString)")
                        resubmit()
                    } else {
                        print(error)
                        resubmit()
                    }
                    if self?.done == false {
                        self?.deployNextTask()
                    }
                }
            }
        }
        return task
    }
    
    private func endSession() {
        done = true
        session.invalidateAndCancel()
        delegate?.completedGridValidation()
    }
    
    private func nextFirstCoordinate() -> Coordinate? {
        guard searchIndex < searchSequence.endIndex else { return nil }
        let firstCoordinate = self.searchSequence[searchIndex]
        searchIndex += 1
        return firstCoordinate
    }
    
    private func createTasks() -> [URLSessionDataTask]? {
        guard let firstCoordinate = nextFirstCoordinate() else { return nil }
        let partsCount = BatchPart.numberOfParts(for: size)
        var taskAccumulator: [URLSessionDataTask] = []
        for part in 0..<partsCount {
            let batchPart = BatchPart(part: part, parts: partsCount)
            let task = makeTask(firstCoordinate: firstCoordinate, part: batchPart, index: taskIndex)
            taskIndex += 1
            taskAccumulator.append(task)
        }
        return taskAccumulator
    }

    func deployNextTask() {
        queue.async { [weak self] in
            guard self?.done == false else { return }
            guard self?.isNumberOfPendingTasksLow == true else { return }
            if let newTasks = self?.createTasks() {
                newTasks.forEach { newTask in
                    newTask.resume()
                }
            }
        }
    }
    
    private var isNumberOfPendingTasksLow: Bool {
        let taskCount = self.taskIndex
        let resultCount = self.results.count
        return (taskCount - resultCount) < 100
    }
    
    func start() {
        deployNextTask()
    }
}
