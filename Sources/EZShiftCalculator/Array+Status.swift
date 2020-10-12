//
//  Array+Status.swift
//  Calculator
//
//  Created by Dima Virych on 07.10.2020.
//

import Foundation

extension Array where Element == EZSCStatus {
    
    public mutating func setEndDate(_ checkDate: Date) {
        for i in 0 ..< count {
            if i + 1 == self.count {
                self[i].setEndDate(checkDate)
            } else {
                self[i].setEndDate(self[i + 1].startDate)
            }
        }
    }
    
    public func joinedSame(with type: EZSCStatusType) -> Self {
        
        var new: Self = []
        var previous: EZSCStatus?
        
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
        
        new.setEndDate(new.last?.endDate ?? Date())
        
        return new
    }
    
    public func joinedRest(_ minRestValue: TimeInterval) -> Self {

        var new: Self = []
        var sub: Self = []

        for element in self {
            if element.isRest() {
                sub.append(element)
                if sub.map(\.statusLength).reduce(0, +) >= minRestValue {
                    var st = EZSCStatus(type: .sb, startDate: sub.first!.startDate)
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
    
    public func joinedRest() -> Self {

        var new: Self = []
        var sub: Self = []
        
        let maxRestValue = 7 * 3600.0

        for element in self {
            if element.isRest() {
                sub.append(element)
                if sub.map(\.statusLength).reduce(0, +) <= maxRestValue {
                    var st = EZSCStatus(type: .sb, startDate: sub.first!.startDate)
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
