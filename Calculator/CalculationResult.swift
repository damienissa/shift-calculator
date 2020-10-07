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
    public var shift: TimeInterval = 0 {
        didSet {
            if shift < drive {
                drive = shift
            }
        }
    }
    
    public init(rule: ShiftRuleInSeconds) {
        self.drive = rule.driveHours
        self.shift = rule.shiftHours
        self.maxTimeWithoutBreak = rule.breakHours
    }
}
