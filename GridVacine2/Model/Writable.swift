//
//  Writable.swift
//  GridVacine2
//
//  Created by Matt Rips on 1/23/21.
//

import Foundation

protocol Writable: Codable {
    func writeToDisk()
    static func readFromDisk(filename: String) -> Self?
    static func getDocumentsDirectory() -> URL
    var filename: String { get }
}

extension Writable {
    func writeToDisk() {
        let pathDirectory = Self.getDocumentsDirectory()
        try? FileManager().createDirectory(at: pathDirectory, withIntermediateDirectories: true)
        let filePath = pathDirectory.appendingPathComponent(self.filename)
        let json = try? JSONEncoder().encode(self)
        do {
             try json!.write(to: filePath)
        } catch {
            print("Failed to write JSON data: \(error.localizedDescription)")
        }
    }
    
    static func readFromDisk(filename: String) -> Self? {
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
