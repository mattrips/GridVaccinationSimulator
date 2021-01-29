//
//  Seeker.swift
//  GridVacine2
//
//  Created by Matt Rips on 1/21/21.
//

import Foundation

class Seeker: ObservableObject {
    var currentGridSize: Int = 4
    var checker: GridChecker = GridChecker(size: 4, findAll: false, searchState: nil)
    var results: CheckResults
    
    private let queue = DispatchQueue(label: "seeker")
    
    init() {
        self.results = CheckResults.readFromDisk() ?? CheckResults()
    }
    
    func run(findLocationsInGrid findSize: Int? = nil) {
        if let seedSize = findSize {
            objectWillChange.send()
            currentGridSize = seedSize
            queue.async { [weak self] in
                self?.checker = GridChecker(size: seedSize, findAll: false, searchState: nil)
                DispatchQueue.main.async {
                    self?.objectWillChange.send()
                }
                self?.checker.run(findAll: true) { _ in }
            }
        } else {
            objectWillChange.send()
            currentGridSize = results.nextUncheckedGridSize
            var searchState: GridChecker.SearchState? = GridChecker.SearchState.readFromDisk(filename: "GridSearchState")
            if searchState?.gridSize != currentGridSize { searchState = nil }
            queue.async { [weak self] in
                guard let size = self?.currentGridSize else {
                    fatalError()
                }
                self?.checker = GridChecker(size: size, findAll: false, searchState: searchState)
                DispatchQueue.main.async {
                    self?.objectWillChange.send()
                }
                self?.checker.run(findAll: false) {[weak self] result in
                    DispatchQueue.main.async {
                        guard self?.currentGridSize == result.gridSize else {
                            return // debounce
                        }
                        self?.objectWillChange.send()
                        self?.results.store(result)
                        self?.run()
                    }
                }
            }
        }
    }
    
    private func storeResult(checker: GridChecker, i: Int, j: Int, elapsedTime: TimeInterval) {
        guard let validPair = checker.validPairs.first else {
            fatalError("No valid pair present in: \(checker)")
        }
        let result = CheckResult(gridSize: checker.size, validPair: validPair, searchPrimaryStep: i, searchSecondaryStep: j, elapsedTime: elapsedTime)
        results.store(result)
    }
    
    struct CheckResults: Codable {
        var data: Array<CheckResult> = []
        
        mutating func store(_ result: CheckResult) {
            data.append(result)
            Self.writeToDisk(self)
        }
        
        var nextUncheckedGridSize: Int {
            let actualValue = (data.sorted(by: { $0.gridSize < $1.gridSize }).last?.gridSize ?? 3) + 1
            return actualValue < 243 ? 243 : actualValue
        }
        
        private static let filename = "VaccineSeeker3.json"
        
        static func writeToDisk(_ value: Self) {
            let pathDirectory = getDocumentsDirectory()
            try? FileManager().createDirectory(at: pathDirectory, withIntermediateDirectories: true)
            let filePath = pathDirectory.appendingPathComponent(filename)
            let json = try? JSONEncoder().encode(value)
            do {
                 try json!.write(to: filePath)
            } catch {
                print("Failed to write JSON data: \(error.localizedDescription)")
            }
        }
        
        static func readFromDisk() -> Self? {
            let pathDirectory = getDocumentsDirectory()
            let filePath = pathDirectory.appendingPathComponent(filename)
            do {
                let data = try Data(contentsOf: filePath)
                let decoder = JSONDecoder()
                let jsonData = try decoder.decode(Self.self, from: data)
                print("Data read from disk for \(filename).")
                return jsonData
            } catch {
                if (error as NSError).code == 260 {
                    print("Data not on disk for \(filename).")
                } else {
                    fatalError("unhandled error when attempting to read data from disk: \(error)")
                }
                return nil
            }
        }
        
        static func getDocumentsDirectory() -> URL {
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            return paths[0]
        }
    }
    
    struct CheckResult: Identifiable, Codable, CustomStringConvertible {
        let id = UUID()
        let gridSize: Int
        let validPair: ValidPair
        let searchPrimaryStep: Int
        let searchSecondaryStep: Int
        let elapsedTime: TimeInterval
        
        var description: String {
            "Grid \(gridSize): Step \(searchPrimaryStep), \(searchSecondaryStep): \(Int(elapsedTime)) Seconds: \(validPair)"
        }
    }
}
