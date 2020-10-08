//
//  RestContainer.swift
//  Calculator
//
//  Created by Dima Virych on 07.10.2020.
//

import Foundation

public struct RestContainer {
    private let bigRest = 7 * 3600.0
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
        } else if rest < bigRest && (chain.first ?? bigRest) < bigRest {
            element = rest
        } else {
            chain.append(rest)
        }
        
        if chain.reduce(0, +) >= maxValue {
            finished()
        }
        
        return element
    }
    
    mutating func clear() {
        chain = []
    }
}
