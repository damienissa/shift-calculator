//
//  RestContainer.swift
//  Calculator
//
//  Created by Dima Virych on 07.10.2020.
//

import Foundation

extension Array where Element == EZSCStatus {
    func getMinimalItemIndex() -> Int {
        let min = map(\.statusLength).sorted().first!
        return firstIndex(where: { $0.statusLength == min })!
    }
    
    mutating func removeMin() -> Element? {
        
        return isEmpty ? nil : remove(at: getMinimalItemIndex())
    }
}

struct RestContainer {
  
    private let bigRest = 7 * 3600.0
    private var maxValue: TimeInterval
    private var finished: (EZSCStatus?) -> Void
    private var chain: [EZSCStatus] = []
    
    var value: TimeInterval {
        chain.map(\.statusLength).reduce(0, +)
    }
    
    init(finished: @escaping (EZSCStatus?) -> Void, maxValue: TimeInterval) {
        self.finished = finished
        self.maxValue = maxValue
    }
    
    mutating func insert(_ rest: EZSCStatus) -> EZSCStatus? {
        
        var element: EZSCStatus?
        if chain.count == 2 {
            element = chain.removeMin()
        } else if rest.statusLength < bigRest && (chain.first?.statusLength ?? bigRest) < bigRest {
            element = rest
        } else {
            chain.append(rest)
        }
        
        if value >= maxValue {
            finished(chain.last)
            chain = []
        }
        
        return element
    }
    
    mutating func clear() {
        chain = []
    }
}
