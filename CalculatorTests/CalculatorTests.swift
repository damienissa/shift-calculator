//
//  CalculatorTests.swift
//  CalculatorTests
//
//  Created by Dima Virych on 29.09.2020.
//

import XCTest
import Calculator

public extension Date {
    static func from(_ hour: TimeInterval) -> Date {
        Date(timeIntervalSince1970: hour * 3600)
    }
}

extension TimeInterval {
    static func minutes(_ min: TimeInterval) -> TimeInterval {
        min / 60
    }
    
    static func seconds(_ seconds: TimeInterval) -> TimeInterval {
        .minutes(seconds / 60)
    }
}

class CalculatorTests: XCTestCase {

    func test_example() {
        let sut = makeSUT()
        let firstCase = [
            Status(type: .on, startDate: .from(0)),
            Status(type: .driving, startDate: .from(1)),
            Status(type: .off, startDate: .from(7)),
            Status(type: .on, startDate: .from(10)),
            Status(type: .driving, startDate: .from(12)),
            Status(type: .sb, startDate: .from(17)),
            Status(type: .off, startDate: .from(24)),
            
        ]

        let result = sut.calculate(firstCase, on: .from(14), specials: [])
        assert(result.drive, 3)
        assert(result.shift, 3)
        
        let result2 = sut.calculate(firstCase, on: .from(17), specials: [])
        assert(result2.drive, 0)
        assert(result2.shift, 0)
        
        let result3 = sut.calculate(firstCase, on: .from(24), specials: [])
        assert(result3.drive, 6)
        assert(result3.shift, 7)
    }
    
    func test_secondCase() {
        
        let sut = makeSUT()
        let firstCase = [
            Status(type: .off, startDate: .from(0)),
            Status(type: .driving, startDate: .from(10)),
            Status(type: .sb, startDate: .from(15)),
            Status(type: .driving, startDate: .from(23)),
            Status(type: .sb, startDate: .from(24 + 4)),
            Status(type: .driving, startDate: .from(24 + 5.5)),
            Status(type: .off, startDate: .from(24 + 13)),
        ]

        let result = sut.calculate(firstCase, on: .from(37), specials: [])
        assert(result.drive, -6.5)
        assert(result.shift, -5)
    }
    
    func test_noviolationData() {
        
        let statuses = [
            Status(type: .off, startDate: .from(0)),
            Status(type: .on, startDate: .from(10)),
            Status(type: .driving, startDate: .from(11)),
            Status(type: .off, startDate: .from(13)),
            Status(type: .driving, startDate: .from(14)),
            Status(type: .on, startDate: .from(17)),
            Status(type: .off, startDate: .from(18)),
            Status(type: .on, startDate: .from(19)),
            Status(type: .driving, startDate: .from(20)),
            Status(type: .on, startDate: .from(23)),
            Status(type: .off, startDate: .from(26)),
        ]
        
        let sut = makeSUT()
        
        let result2 = sut.calculate(statuses, on: .from(26), specials: [.hourException])
        assert(result2.drive, 0)
        assert(result2.shift, 0)
        
        let result = sut.calculate(statuses, on: .from(36), specials: [.hourException])
        assert(result.drive, 11)
        assert(result.shift, 14)
    }
    
    func test_violationData() {
        
        let statuses = [
            Status(type: .off, startDate: .from(0)),
            Status(type: .on, startDate: .from(10)),
            Status(type: .driving, startDate: .from(12)),
            Status(type: .off, startDate: .from(16)),
            Status(type: .driving, startDate: .from(17)),
            Status(type: .off, startDate: .from(20)),
            Status(type: .driving, startDate: .from(21)),
            Status(type: .on, startDate: .from(22)),
            Status(type: .driving, startDate: .from(24)),
            Status(type: .off, startDate: .from(27)),
        ]
        
        let sut = makeSUT()
        
        let result2 = sut.calculate(statuses, on: .from(36), specials: [.hourException])
        assert(result2.drive, -1)
        assert(result2.shift, -1)
    }
    
    func test_34Restart() {
        
        let statuses = [
            Status(type: .off, startDate: .from(0)),
            Status(type: .driving, startDate: .from(34)),
            Status(type: .off, startDate: .from(40)),
            Status(type: .driving, startDate: .from(41)),
            Status(type: .on, startDate: .from(45)),
            Status(type: .driving, startDate: .from(47)),
            Status(type: .off, startDate: .from(48)),
            Status(type: .driving, startDate: .from(58)),
            Status(type: .off, startDate: .from(63)),
            Status(type: .driving, startDate: .from(64)),
            Status(type: .on, startDate: .from(69)),
            Status(type: .driving, startDate: .from(71)),
        ]
        
        let sut = makeSUT()
        
        let result = sut.calculate(statuses, on: .from(48), specials: [])
        assert(result.drive, 0)
        assert(result.shift, 0)
        
        let result2 = sut.calculate(statuses, on: .from(64), specials: [])
        assert(result2.drive, 6)
        assert(result2.shift, 8)
        
        let result3 = sut.calculate(statuses, on: .from(72), specials: [])
        assert(result3.drive, 0)
        assert(result3.shift, 0)
    }
    
    func test_testCaseFromDmytro() {
        
        let statuses = [
            Status(type: .off, startDate: .from(0)),
            Status(type: .sb, startDate: .from(24)),
        ]
        
        let sut = makeSUT()
        
        let result = sut.calculate(statuses, on: .from(28.5), specials: [])
        assert(result.drive, 11)
        assert(result.shift, 14)
    }
    
    func test_testAdverseDrivingConditions() {
        
        let statuses = [
            Status(type: .driving, startDate: .from(0)),
            Status(type: .off, startDate: .from(3)),
            Status(type: .driving, startDate: .from(4)),
            Status(type: .on, startDate: .from(8)),
            Status(type: .off, startDate: .from(9)),
            Status(type: .driving, startDate: .from(10)),
            Status(type: .off, startDate: .from(15)),
        ]
        
        let sut = makeSUT()
        
        let result = sut.calculate(statuses, on: .from(15), specials: [.adverseDriving])
        assert(result.drive, 1)
        assert(result.shift, 1)
        
        let result2 = sut.calculate(statuses, on: .from(25), specials: [.adverseDriving])
        assert(result2.drive, 11)
        assert(result2.shift, 14)
    }
    
    func test_testAdverseDrivingConditionsWithHourException() {
        
        let statuses = [
            Status(type: .driving, startDate: .from(0)),
            Status(type: .off, startDate: .from(3)),
            Status(type: .driving, startDate: .from(4)),
            Status(type: .on, startDate: .from(8)),
            Status(type: .off, startDate: .from(9)),
            Status(type: .driving, startDate: .from(10)),
            Status(type: .off, startDate: .from(15)),
        ]
        
        let sut = makeSUT()
        
        let result = sut.calculate(statuses, on: .from(15), specials: [.adverseDriving, .hourException])
        assert(result.drive, 1)
        assert(result.shift, 1)
        
        let result2 = sut.calculate(statuses, on: .from(25), specials: [.adverseDriving, .hourException])
        assert(result2.drive, 11)
        assert(result2.shift, 14)
    }
    
    func test_30Min_Changes() {
        
        let statuses = [
            Status(type: .driving, startDate: .from(0)),
            Status(type: .off, startDate: .from(3)),
            Status(type: .driving, startDate: .from(4)),
            Status(type: .on, startDate: .from(8)),
            Status(type: .off, startDate: .from(9)),
            Status(type: .driving, startDate: .from(10)),
            Status(type: .off, startDate: .from(15)),
        ]
        
        let sut = makeSUT()
        
        let result = sut.calculate(statuses, on: .from(15), specials: [.adverseDriving])
        assert(result.drive, 1)
        assert(result.shift, 1)
    }
    
    func test_sleeperBerth2Days() {
        
        let statuses = [
            Status(type: .off, startDate: .from(0)),
            Status(type: .on, startDate: .from(2)),
            Status(type: .driving, startDate: .from(3)),
            Status(type: .sb, startDate: .from(8)),
            Status(type: .driving, startDate: .from(10)),
            Status(type: .sb, startDate: .from(14)),
            Status(type: .on, startDate: .from(24)),
            Status(type: .driving, startDate: .from(24 + 1)),
            Status(type: .sb, startDate: .from(24 + 5)),
            Status(type: .driving, startDate: .from(24 + 7)),
            Status(type: .sb, startDate: .from(24 + 13)),
            Status(type: .driving, startDate: .from(24 + 21)),
        ]
        
        let sut = makeSUT()
        
        let result = sut.calculate(statuses, on: .from(48), specials: [])
        assert(result.drive, 2)
        assert(result.shift, 5)
    }
    
    func test_sleeperBerth() {
        
        let statuses = [
            Status(type: .off, startDate: .from(0)),
            Status(type: .on, startDate: .from(2)),
            Status(type: .driving, startDate: .from(3)),
            Status(type: .sb, startDate: .from(8)),
            Status(type: .driving, startDate: .from(10)),
            Status(type: .sb, startDate: .from(14)),
        ]
        
        let sut = makeSUT()
        
        let result = sut.calculate(statuses, on: .from(14), specials: [])
        assert(result.drive, 2)
        assert(result.shift, 4)
    }
    
    func test_example19() {
        
        let statuses = [
            Status(type: .off, startDate: .from(-8)),
            Status(type: .on, startDate: .from(2)),
            Status(type: .driving, startDate: .from(3)),
            Status(type: .sb, startDate: .from(8)),
            Status(type: .driving, startDate: .from(10)),
            Status(type: .sb, startDate: .from(16)),
            Status(type: .on, startDate: .from(24)),
            Status(type: .driving, startDate: .from(25)),
            Status(type: .sb, startDate: .from(29)),
            Status(type: .driving, startDate: .from(31)),
            Status(type: .sb, startDate: .from(37)),
            Status(type: .driving, startDate: .from(45)),
        ]
        
        let sut = makeSUT()
        
        let result = sut.calculate(statuses, on: .from(2), specials: [])
        assert(result.drive, 11)
        assert(result.shift, 14)
        
        let result2 = sut.calculate(statuses, on: .from(10), specials: [])
        assert(result2.drive, 6)
        assert(result2.shift, 8)
        
        let result3 = sut.calculate(statuses, on: .from(24), specials: [])
        assert(result3.drive, 5)
        assert(result3.shift, 8)
        
        let result4 = sut.calculate(statuses, on: .from(24 + 7), specials: [])
        assert(result4.drive, 7)
        assert(result4.shift, 9)
        
        let result5 = sut.calculate(statuses, on: .from(48), specials: [])
        assert(result5.drive, 2)
        assert(result5.shift, 5)
    }
    
    func test_30MinutesBreakeChanges() {
        
        let statuses = [
            Status(type: .driving, startDate: .from(0)),
            Status(type: .on, startDate: .from(5)),
            Status(type: .driving, startDate: .from(5.5)),
            Status(type: .on, startDate: .from(10.5)),
            Status(type: .driving, startDate: .from(11.5)),
            Status(type: .on, startDate: .from(12.5)),
            Status(type: .off, startDate: .from(14)),
        ]
        
        let sut = makeSUT()
        
        let result = sut.calculate(statuses, on: .from(10.5), specials: [])
        assert(result.drive, 1)
        assert(result.shift, 3.5)
        assert(result.maxTimeWithoutBreak, -2)
        
        let result2 = sut.calculate(statuses, on: .from(14), specials: [])
        assert(result2.drive, 0)
        assert(result2.shift, 0)
        assert(result2.maxTimeWithoutBreak, -2)
    }
    
    func test_30MinutesBreakeChanges_Violation() {
        
        let statuses = [
            Status(type: .on, startDate: .from(0)),
            Status(type: .driving, startDate: .from(1)),
            Status(type: .on, startDate: .from(9.5)),
            Status(type: .driving, startDate: .from(10)),
            Status(type: .off, startDate: .from(12))
        ]
        
        let sut = makeSUT()
        
        let result = sut.calculate(statuses, on: .from(9.5), specials: [])
        assert(result.drive, 2.5)
        assert(result.shift, 4.5)
        assert(result.maxTimeWithoutBreak, 8)
    }
    
    func test_shiftViolation() {
        
        let statuses = [
            Status(type: .driving, startDate: .from(0)),
            Status(type: .on, startDate: .from(7.5)),
            Status(type: .off, startDate: .from(9)),
            Status(type: .sb, startDate: .from(10)),
            Status(type: .off, startDate: .from(11)),
            Status(type: .driving, startDate: .from(12)),
            Status(type: .on, startDate: .from(13.5)),
            Status(type: .driving, startDate: .from(16)),
            Status(type: .sb, startDate: .from(17.5)),
        ]
        
        let sut = makeSUT()
        
        let result = sut.calculate(statuses, on: .from(17), specials: [])
        assert(result.drive, 0)
        assert(result.shift, 0)
    }
    
    func test_EmptyStatus() {
        
        let status = Status(type: .driving, startDate: .from(1))
        
        XCTAssertEqual(status.statusLength, 0)
    }
    
    func test_11Violation() {
        
        let statuses = [
            Status(type: .off, startDate: .from(0)),
            Status(type: .on, startDate: .from(7)),
            Status(type: .driving, startDate: .from(8)),
            Status(type: .off, startDate: .from(13.5)),
            Status(type: .driving, startDate: .from(16.5)),
            Status(type: .sb, startDate: .from(22)),
            Status(type: .on, startDate: .from(24)),
            Status(type: .sb, startDate: .from(24.5)),
            Status(type: .driving, startDate: .from(28.75)),
            Status(type: .sb, startDate: .from(29)),
        ]
        
        let sut = makeSUT()
        
        let result = sut.calculate(statuses, on: .from(24), specials: [])
        assert(result.drive, 0)
        assert(result.shift, 0)
    }
    
    func test_11Violation_() {
        
        let statuses = [
            Status(type: .sb, startDate: .from(0)),
            Status(type: .on, startDate: .from(9 + .minutes(54) + .seconds(49))),
            Status(type: .driving, startDate: .from(10 + .minutes(23) + .seconds(50))),
            Status(type: .on, startDate: .from(11 + .minutes(42) + .seconds(28))),
            Status(type: .driving, startDate: .from(11 + .minutes(56) + .seconds(43))),
            Status(type: .off, startDate: .from(12 + .minutes(8) + .seconds(59))),
            Status(type: .driving, startDate: .from(14 + .minutes(3) + .seconds(48))),
            Status(type: .on, startDate: .from(14 + .minutes(10) + .seconds(53))),
            Status(type: .driving, startDate: .from(14 + .minutes(39) + .seconds(44))),
            Status(type: .off, startDate: .from(17 + .minutes(18) + .seconds(13))),
            Status(type: .driving, startDate: .from(17 + .minutes(38) + .seconds(57))),
            Status(type: .sb, startDate: .from(22 + .minutes(11) + .seconds(18))),
        ]
        
        let sut = makeSUT()
        
        let result = sut.calculate(statuses, on: .from(22 + .minutes(15)), specials: [])
        assert(result.maxTimeWithoutBreak, 8)
    }
   
    func makeSUT() -> Calculator {
        Calc()
    }
}

func assert(_ result: TimeInterval, _ expected: TimeInterval, file: StaticString = #file, line: UInt = #line) {
    
    XCTAssert(result == expected * 3600, "Difference: \((result - expected * 3600) / 3600), Expected: \(expected), Actual: \((result / 3600))", file: file, line: line)
}
