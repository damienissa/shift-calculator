//
//  Status.swift
//  Calculator
//
//  Created by Dima Virych on 30.09.2020.
//

import Foundation

public enum StatusType {
    
    case on
    case driving
    case sb
    case off
}

public struct Status {
    
    public let startDate: Date
    public var type: StatusType
    public var endDate: Date?
    
    public var statusLength: TimeInterval {
        endDate == nil ? 0 : endDate!.timeIntervalSince1970 - startDate.timeIntervalSince1970
    }
    
    public init(type: StatusType, startDate: Date) {
        self.type = type
        self.startDate = startDate
    }
    
    public mutating func setEndDate(_ date: Date) {
        endDate = date
    }
    
    public func isRest() -> Bool {
        type == .sb || type == .off
    }
}
