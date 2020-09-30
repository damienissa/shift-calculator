//
//  CalculationResult.swift
//  Calculator
//
//  Created by Dima Virych on 30.09.2020.
//

import Foundation

public struct CalculationResult {
    
    public let shift: TimeInterval
    public let drive: TimeInterval
    public let maxTimeWithoutBreak: TimeInterval
    
    public init(shift: TimeInterval, drive: TimeInterval, maxTimeWithoutBreak: TimeInterval) {
        
        self.shift = shift
        self.drive = drive
        self.maxTimeWithoutBreak = maxTimeWithoutBreak
    }
}
