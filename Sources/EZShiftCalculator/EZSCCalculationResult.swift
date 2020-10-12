//
//  CalculationResult.swift
//  Calculator
//
//  Created by Dima Virych on 30.09.2020.
//

import Foundation

public class EZSCCalculationResult {
    
    public var drive: TimeInterval
    public var maxTimeWithoutBreak: TimeInterval
    
    public var cycle: TimeInterval
    public var cycleDays: TimeInterval
    
    public var tillRestartHours: TimeInterval
    public var date: Date
    public var restartHoursCurrent: TimeInterval
    
    public var splitDate: Date?
    
    public var shiftCandidate: TimeInterval = 0
    public var shift: TimeInterval = 0 {
        didSet {
            if shift < drive {
                drive = shift
            }
        }
    }
    
    public init(rule: EZShiftRule, date: Date) {
        
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
