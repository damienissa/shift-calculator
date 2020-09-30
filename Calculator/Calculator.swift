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
    private let longRestTime = 7.0 * 3600
    private let shortRestTime = 2.0 * 3600
    private let specialTime = 2.0 * 3600
    
    private var reseted = false
    private var maxTimeWithoutBreak: TimeInterval = 0 {
        didSet {
            if maxTimeWithoutBreak > rule.breakHours {
                maxTimeWithoutBreak = rule.breakHours
            }
        }
    }
    private var drive: TimeInterval = 0
    private var shift: TimeInterval = 0 {
        didSet {
            if shift < drive {
                drive = shift
            }
        }
    }
    private var restChain: RestContainer!
    
    
    // MARK: - Lifecycle
    
    public init() {
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
            if status.type == .off && status.statusLength >= rule.shiftRestartHours && index == 0 {
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
            
            if status.type != .driving && maxTimeWithoutBreak > 0 {
                maxTimeWithoutBreak = rule.breakHours
            }
        }
        
        return .init(shift: shift, drive: drive, maxTimeWithoutBreak: maxTimeWithoutBreak)
    }
    
    private func fillRestStatus(_ status: Status) {
       
        if status.statusLength >= longRestTime && status.type == .sb {
            shift -= restChain.insert(status.statusLength)
        } else if status.statusLength >= shortRestTime {
            shift -= restChain.insert(status.statusLength)
        } else {
            shift -= status.statusLength
        }
    }
    
    private func fillOnStatus(_ status: Status) {
        
        shift -= status.statusLength
    }
    
    private func fillDrivingStatus(_ status: Status) {
        
        drive -= status.statusLength
        shift -= status.statusLength
        maxTimeWithoutBreak -= status.statusLength
    }
    
    private func reset() {
        
        drive = rule.driveHours
        shift = rule.shiftHours
        maxTimeWithoutBreak = rule.breakHours
        restChain.clear()
        reseted = false
    }
    
    private func fillSpecials(_ specials: [StatusSpecialsType]) {
        
        specials.forEach {
            switch $0 {
            case .adverseDriving:
                drive += specialTime
                if !specials.contains(.hourException) {
                   shift += specialTime
                }
            case .hourException:
                shift += specialTime
            }
        }
    }
   
    private func getStatusesWithEndDate(_ statuses: [Status], checkDate: Date) -> [Status] {
        
        var workingCopy = statuses
        workingCopy.removeAll { $0.startDate.timeIntervalSince1970 >= checkDate.timeIntervalSince1970 }
        
        var previousStatus: Status?
        var st: [Status] = []
        for i in 0 ..< workingCopy.count {
            
            if i + 1 == workingCopy.count {
                workingCopy[i].setEndDate(checkDate)
            } else {
                workingCopy[i].setEndDate(workingCopy[i + 1].startDate)
            }
            
            if previousStatus != nil,
               previousStatus!.statusLength < longRestTime,
               previousStatus!.isRest() && workingCopy[i].isRest() {
                
                previousStatus?.setEndDate(workingCopy[i].endDate!)
            } else {
                if previousStatus != nil  {
                    st.append(previousStatus!)
                }
                previousStatus = workingCopy[i]
            }
        }
        
        st.append(previousStatus!)
        
        return st.reversed()
    }
}
