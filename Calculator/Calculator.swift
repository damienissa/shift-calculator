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

public struct RestContainer {
    
    private var maxValue: TimeInterval
    private var finished: () -> Void
    private var chain: [TimeInterval] = []
    
    public init(finished: @escaping () -> Void, maxValue: TimeInterval) {
        self.finished = finished
        self.maxValue = maxValue
    }
    
    mutating func insert(_ rest: TimeInterval) -> TimeInterval {
        
        var element = 0.0
        if chain.count == 2 {
            element = chain.removeFirst()
        }
        chain.append(rest)
        
        if chain.reduce(0, +) >= maxValue {
            finished()
        }
        
        return element
    }
    
    mutating func clear() {
        chain = []
    }
}

public class Calc: Calculator {
    
    private let rule = ShiftRuleInSeconds()
    private let longRestTime = 7.0 * hInSec
    private let shortRestTime = 2.0 * hInSec
    private let specialTime = 2.0 * hInSec
    private let halfHour = 0.5 * hInSec
    
    private var reseted = false
    
    // MARK: - Calculated values
    
    private var result: CalculationResult
    private var restChain: RestContainer!
    
    
    // MARK: - Lifecycle
    
    public init() {
        
        result = CalculationResult.init(rule: rule)
        restChain = RestContainer(finished: {
            self.reseted = true
        }, maxValue: rule.shiftRestartHours)
    }
    
    
    // MARK: - Actions
    
    public func calculate(_ st: [Status], on date: Date, specials: [StatusSpecialsType] = []) -> CalculationResult {
        
        reset()
        
        let statuses = getStatusesWithEndDate(st, checkDate: date)
        fillSpecials(specials)
        for index in 0 ..< statuses.count {
            
            let status = statuses[index]
            if status.isRest() && status.statusLength >= rule.shiftRestartHours && index == 0 {
                reset()
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
    
    private func fillRestStatus(_ status: Status) {
        
        if status.statusLength >= longRestTime && status.type == .sb {
            result.shift -= restChain.insert(status.statusLength)
        } else if status.statusLength >= shortRestTime {
            result.shift -= restChain.insert(status.statusLength)
        } else {
            result.shift -= status.statusLength
        }
    }
    
    private func fillOnStatus(_ status: Status) {
        
        result.shift -= status.statusLength
    }
    
    private func fillDrivingStatus(_ status: Status) {
        
        result.drive -= status.statusLength
        result.shift -= status.statusLength
        result.maxTimeWithoutBreak -= status.statusLength
    }
    
    private func reset() {
        
        result.drive = rule.driveHours
        result.shift = rule.shiftHours
        result.maxTimeWithoutBreak = rule.breakHours
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
        workingCopy.draw()
        workingCopy = workingCopy.joinedSame(with: .sb).joinedSame(with: .off).joinedRest()
        workingCopy.draw()
        
        return workingCopy.reversed()
    }
}


extension Array where Element == Status {
    
    public mutating func setEndDate(_ checkDate: Date) {
        for i in 0 ..< count {
            if i + 1 == self.count {
                self[i].setEndDate(checkDate)
            } else {
                self[i].setEndDate(self[i + 1].startDate)
            }
        }
    }
    
    public func joinedSame(with type: StatusType) -> Self {
        
        var new: Self = []
        var previous: Status?
        
        for element in self {
            if element.type == type {
                if previous == nil {
                    previous = element
                    previous?.setType(type)
                    new.append(element)
                }
            } else {
                previous = nil
                new.append(element)
            }
        }
        
        new.setEndDate(new.last!.endDate!)
        
        return new
    }
    
    func joinedRest() -> Self {

        var new: Self = []
        var sub: Self = []

        for element in self {
            if element.isRest() {
                sub.append(element)
                if sub.map(\.statusLength).reduce(0, +) / 3600 >= 10 {
                    var st = Status(type: .off, startDate: sub.first!.startDate)
                    st.setEndDate(element.endDate!)
                    sub = [st]
                }
            } else {
                new.append(contentsOf: sub)
                sub = []
                new.append(element)
            }
        }
        
        new.append(contentsOf: sub)
        
        return new
    }
}

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
                str.append(".")
            }
            str.append("\n")
        }
        
        var totalH = 0
        
        for item in self {
            let h = Int(item.statusLength / 3600)
            for i in totalH ..< totalH + h {
                str = str.replace(((numberOfItems) * (3 - item.type.rawValue)) + i, "-")
            }
            
            totalH += h
        }
        
        print(str)
        return str
    }
}
