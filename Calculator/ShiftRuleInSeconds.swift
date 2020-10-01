//
//  ShiftRuleInSeconds.swift
//  Calculator
//
//  Created by Dima Virych on 30.09.2020.
//

import Foundation

public struct ShiftRuleInSeconds {
    
    public let days: TimeInterval = 8 * hInSec * 24
    public let inspectionDays: TimeInterval = 8 * hInSec * 24
    public let cycleHours: TimeInterval = 70 * hInSec
    public let shiftHours: TimeInterval = 14 * hInSec
    public let driveHours: TimeInterval = 11 * hInSec
    public let restartHours: TimeInterval = 34 * hInSec
    public let shiftRestartHours: TimeInterval = 10 * hInSec
    public let breakHours: TimeInterval = 8 * hInSec
    
    public init() {}
}
