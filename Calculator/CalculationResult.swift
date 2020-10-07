//
//  CalculationResult.swift
//  Calculator
//
//  Created by Dima Virych on 30.09.2020.
//

import Foundation

public class CalculationResult {
    
    public var drive: TimeInterval = 0
    public var maxTimeWithoutBreak: TimeInterval = 0
    
    public var cycle: TimeInterval = 0
    public var cycleDays: TimeInterval = 0
    
    public var tillRestartHours: TimeInterval = 0
    public var date: Date = Date()
    public var restartHoursCurrent: TimeInterval = 0
    
    public var shift: TimeInterval = 0 {
        didSet {
            if shift < drive {
                drive = shift
            }
        }
    }
    
    public init(rule: ShiftRuleInSeconds, date: Date) {
        
        self.drive = rule.driveHours
        self.shift = rule.shiftHours
        self.maxTimeWithoutBreak = rule.breakHours
        self.cycle = rule.cycleHours
        self.cycleDays = rule.inspectionDays
        self.tillRestartHours = rule.shiftRestartHours
        self.date = date
        self.restartHoursCurrent = rule.restartHours
    }
}
