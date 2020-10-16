//
//  Calculator.swift
//  Calculator
//
//  Created by Dima Virych on 29.09.2020.
//

import Foundation

let hInSec = 3600.0

public protocol RuleProvider {
    func getRule(for date: Date) -> EZShiftRule
}

public class EZShiftCalculator {
    
    private let provider: RuleProvider
    private let longRestTime = 7.0 * hInSec
    private let shortRestTime = 2.0 * hInSec
    private let specialTime = 2.0 * hInSec
    private let halfHour = 0.5 * hInSec
    
    private var rule: EZShiftRule = ShiftRuleInSeconds()
    private var reseted = false
    private var needCheckTillRestart = true
    
    // MARK: - Calculated values
    
    private var result: EZSCCalculationResult
    private var restChain: RestContainer!
    
    
    // MARK: - Lifecycle
    
    public init(_ provider: RuleProvider) {
        
        self.provider = provider
        result = EZSCCalculationResult.init(rule: rule, date: Date())
        restChain = RestContainer(finished: { statuses in
            self.reseted = true
            self.result.splitDate = statuses.last?.endDate
            self.result.splitDateEnd = statuses.first?.startDate
        }, maxValue: rule.shiftRestartHours)
    }
    
    
    // MARK: - Actions
    
    public func calculate(_ st: [EZSCStatus], on date: Date, specials: [EZSCStatusSpecialsType] = []) -> EZSCCalculationResult {
        
        reset(date: date)
        
        let statuses = getEZSCStatusesWithEndDate(st, checkDate: date)
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
                fillDrivingEZSCStatus(status)
            case .sb, .off:
                fillRestEZSCStatus(status)
            case .on:
                fillOnEZSCStatus(status)
            }
            
            if status.type != .driving && status.statusLength > halfHour {
                result.maxTimeWithoutBreak = rule.breakHours
            }
        }
        
        result.shiftCandidate = result.shift + restChain.value
        result.shift -= restChain.value
        
        return result
    }
    
    private func fillCycle(_ st: [EZSCStatus]) {
        
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
    
    private func fillRestEZSCStatus(_ status: EZSCStatus) {
        
        guard status.statusLength < rule.shiftRestartHours else {
            return (reseted = true)
        }
        
        if status.statusLength >= longRestTime && status.type == .sb {
            result.shift -= restChain.insert(status)?.statusLength ?? 0
        } else if status.statusLength >= shortRestTime && status.statusLength < longRestTime  {
            result.shift -= restChain.insert(status)?.statusLength ?? 0
        } else {
            result.shift -= status.statusLength
        }
        
        if needCheckTillRestart {
            result.tillRestartHours -= status.statusLength
        }
    }
    
    private func fillOnEZSCStatus(_ status: EZSCStatus) {
        
        result.shift -= status.statusLength
        needCheckTillRestart = false
    }
    
    private func fillDrivingEZSCStatus(_ status: EZSCStatus) {
        
        result.drive -= status.statusLength
        result.shift -= status.statusLength
        
        result.maxTimeWithoutBreak -= status.statusLength
        
        needCheckTillRestart = false
    }
    
    private func reset(date: Date) {
        
        result = EZSCCalculationResult(rule: provider.getRule(for: date), date: date)
        restChain.clear()
        reseted = false
    }
    
    private func restartShift() {
        
        result.shift = rule.shiftHours
        result.drive = rule.driveHours
        restChain.clear()
        reseted = false
    }
    
    private func fillSpecials(_ specials: [EZSCStatusSpecialsType]) {
        
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
    
    private func getEZSCStatusesWithEndDate(_ statuses: [EZSCStatus], checkDate: Date) -> [EZSCStatus] {
        
        var workingCopy = statuses
        workingCopy.removeAll { $0.startDate.timeIntervalSince1970 >= checkDate.timeIntervalSince1970 }
        workingCopy.setEndDate(checkDate)
        workingCopy = workingCopy.joinedSame(with: .sb).joinedSame(with: .off).joinedRest(rule.shiftRestartHours).joinedRest()
        #if DEBUG
//        workingCopy.draw()
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

extension Array where Element == EZSCStatus {
    
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
