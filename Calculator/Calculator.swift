//
//  Calculator.swift
//  Calculator
//
//  Created by Dima Virych on 29.09.2020.
//

import Foundation

let hInSec = 3600.0

public protocol Calculator {
    
    func calculate(_ statuses: [Status], on date: Date, specials: [StatusSpecialsType]) -> CalculationResult
}



public class Calc: Calculator {
    
    private let rule = ShiftRuleInSeconds()
    private let longRestTime = 7.0 * hInSec
    private let shortRestTime = 2.0 * hInSec
    private let specialTime = 2.0 * hInSec
    private let halfHour = 0.5 * hInSec
    
    private var reseted = false
    private var needCheckTillRestart = true
    
    // MARK: - Calculated values
    
    private var result: CalculationResult
    private var restChain: RestContainer!
    
    
    // MARK: - Lifecycle
    
    public init() {
        
        result = CalculationResult.init(rule: rule, date: Date())
        restChain = RestContainer(finished: {
            self.reseted = true
        }, maxValue: rule.shiftRestartHours)
    }
    
    
    // MARK: - Actions
    
    public func calculate(_ st: [Status], on date: Date, specials: [StatusSpecialsType] = []) -> CalculationResult {
        
        reset(date: date)
        
        let statuses = getStatusesWithEndDate(st, checkDate: date)
        fillSpecials(specials)
        
        fillCycle(statuses)
        
        for index in 0 ..< statuses.count {
            
            let status = statuses[index]
            if status.isRest() && status.statusLength >= rule.shiftRestartHours && index == 0 {
                restartShift()
                break
            }
            if reseted {
                break
            }
            switch status.type {
            case .driving:
                fillDrivingStatus(status)
            case .sb, .off:
                fillRestStatus(status)
            case .on:
                fillOnStatus(status)
            }
            
            if status.type != .driving && status.statusLength > halfHour {
                result.maxTimeWithoutBreak = rule.breakHours
            }
        }
        
        return result
    }
    
    private func fillCycle(_ st: [Status]) {
        
        result.restartHoursCurrent = st.first?.restart ?? rule.restartHours
        
        for status in st.reversed() {
            
            if status.isWorking() {
                
                result.cycle -= status.statusLength
                result.restartHoursCurrent = rule.restartHours
            } else {
                result.restartHoursCurrent -= status.statusLength
            }
            
            result.cycleDays -= status.statusLength
            
            if status.statusLength >= rule.restartHours {
                
                result.cycle = rule.cycleHours
                result.cycleDays = rule.inspectionDays
            }
        }
    }
    
    private func fillRestStatus(_ status: Status) {
        
        if status.statusLength >= longRestTime && status.type == .sb {
            result.shift -= restChain.insert(status.statusLength)
        } else if status.statusLength >= shortRestTime {
            result.shift -= restChain.insert(status.statusLength)
        } else {
            result.shift -= status.statusLength
        }
        
        if needCheckTillRestart {
            result.tillRestartHours -= status.statusLength
        }
    }
    
    private func fillOnStatus(_ status: Status) {
        
        result.shift -= status.statusLength
        needCheckTillRestart = false
    }
    
    private func fillDrivingStatus(_ status: Status) {
        
        result.drive -= status.statusLength
        result.shift -= status.statusLength
        
        result.maxTimeWithoutBreak -= status.statusLength
        
        needCheckTillRestart = false
    }
    
    private func reset(date: Date) {
        
        result = CalculationResult(rule: rule, date: date)
        restChain.clear()
        reseted = false
    }
    
    private func restartShift() {
        
        result.shift = rule.shiftHours
        result.drive = rule.driveHours
        restChain.clear()
        reseted = false
    }
    
    private func fillSpecials(_ specials: [StatusSpecialsType]) {
        
        specials.forEach {
            switch $0 {
            case .adverseDriving:
                result.drive += specialTime
                if !specials.contains(.hourException) {
                    result.shift += specialTime
                }
            case .hourException:
                result.shift += specialTime
            }
        }
    }
    
    private func getStatusesWithEndDate(_ statuses: [Status], checkDate: Date) -> [Status] {
        
        var workingCopy = statuses
        workingCopy.removeAll { $0.startDate.timeIntervalSince1970 >= checkDate.timeIntervalSince1970 }
        workingCopy.setEndDate(checkDate)
        workingCopy = workingCopy.joinedSame(with: .sb).joinedSame(with: .off).joinedRest(rule.shiftRestartHours)
        #if DEBUG
        workingCopy.draw()
        #endif
        
        return workingCopy.reversed()
    }
}

#if DEBUG
extension String {
    
    func replace(_ index: Int, _ newChar: Character) -> String {
        
        var chars = Array(self)     // gets an array of characters
        chars[index] = newChar
        let modifiedString = String(chars)
        return modifiedString
    }
}

extension Array where Element == Status {
    
    @discardableResult
    public func draw() -> String {
        
        let numberOfItems = Int(map(\.statusLength).reduce(0, +) / 3600)
        var str = ""
        for _ in 0 ..< 4 {
            for _ in 0 ..< numberOfItems {
                str.append("_")
            }
            str.append("\n")
        }
        
        var totalH = 0
        
        for item in self {
            let h = Int(item.statusLength / 3600)
            for i in totalH ..< totalH + h {
                str = str.replace(((numberOfItems + 1) * (3 - item.type.rawValue)) + i, "●")
            }
            
            totalH += h
        }
        str = "\n\n-----------------------------------------------------------------\n\n" + str
        str.append("\n\n-----------------------------------------------------------------\n\n")
        print(str)
        return str
    }
}
#endif
