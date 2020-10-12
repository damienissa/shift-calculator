//
//  ShiftRuleInSeconds.swift
//  Calculator
//
//  Created by Dima Virych on 30.09.2020.
//

import Foundation

public protocol EZShiftRule {
    
    var days: TimeInterval { get }
    var inspectionDays: TimeInterval { get }
    var cycleHours: TimeInterval { get }
    var shiftHours: TimeInterval { get }
    var driveHours: TimeInterval { get }
    var restartHours: TimeInterval { get }
    var shiftRestartHours: TimeInterval { get }
    var breakHours: TimeInterval { get }
}

public struct ShiftRuleInSeconds: EZShiftRule {
    
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
