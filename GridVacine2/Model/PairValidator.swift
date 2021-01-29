//
//  Validator.swift
//  GridVacine2
//
//  Created by Matt Rips on 1/15/21.
//

import Foundation

struct PairValidator {
    private let size: Int
    var validator: Validator
    private var startData: GridData
    private var secondCoordinate: Coordinate
    var startX: Int = 0
    var startY: Int = 0
    var startDirection: Direction = .up
    private let firstAntiVaxBotCoordinate: Coordinate
    
    init(size: Int, firstAntiVaxBotLocation: Coordinate) {
        self.size = size
        self.validator = Validator(size: size, antiVaxBotLocations: [firstAntiVaxBotLocation])
        self.startData = validator.data
        self.secondCoordinate = .zero
        self.firstAntiVaxBotCoordinate = firstAntiVaxBotLocation
        self.setSecondCoordinate(to: .zero)
    }
    
    mutating func run(for coordinate: Coordinate) {
        changePositionOfSecondAntiVaxBot(to: coordinate)
        setupFreshValidator()
        advanceValidatorToSecondAntiVaxBot()
        saveGridDataAndState()
        runValidator()
    }
    
    mutating func runReverse(for coordinate: Coordinate) {
        validator = Validator(size: size, antiVaxBotLocations: [firstAntiVaxBotCoordinate, coordinate])
        validator.check()
    }
    
    var result: Validator.Result {
        validator.data.cellsRemaining == 0 ? .success : .failure
    }
    
    private mutating func setSecondCoordinate(to coordinate: Coordinate) {
        secondCoordinate = coordinate
        startData.positionAntiVaxBots(at: [coordinate])
    }
    
    private mutating func setupFreshValidator() {
        validator = Validator(size: size, data: startData, x: startX, y: startY, direction: startDirection)
    }
    
    private mutating func changePositionOfSecondAntiVaxBot(to coordinate: Coordinate) {
        startData.set(secondCoordinate, to: 0)
        secondCoordinate = coordinate
        startData.set(coordinate, to: 3)
    }
    
    private mutating func advanceValidatorToSecondAntiVaxBot() {
        while validator.x != secondCoordinate.x || validator.y != secondCoordinate.y {
            validator.next()
        }
    }
    
    private mutating func saveGridDataAndState() {
        startData = validator.data
        startX = validator.x
        startY = validator.y
        startDirection = validator.direction
    }
    
    private mutating func runValidator() {
        validator.check()
    }
}
