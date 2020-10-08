//
//  Status.swift
//  Calculator
//
//  Created by Dima Virych on 30.09.2020.
//

import Foundation

public enum StatusType: Int, Codable {
    
    case on
    case driving
    case sb
    case off
}

public struct Status: Decodable {
    
    public let startDate: Date
    public var type: StatusType
    public var endDate: Date?
    public var restart: TimeInterval = 0
    
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
    
    public mutating func setType(_ type: StatusType) {
        self.type = type
    }
    
    public func isRest() -> Bool {
        type == .sb || type == .off
    }
    
    public func isWorking() -> Bool {
        type == .on || type == .driving
    }
}
