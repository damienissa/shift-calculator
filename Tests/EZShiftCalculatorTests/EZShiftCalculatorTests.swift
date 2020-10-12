import XCTest
import EZShiftCalculator

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
            EZSCStatus(type: .on, startDate: .from(0)),
            EZSCStatus(type: .driving, startDate: .from(1)),
            EZSCStatus(type: .off, startDate: .from(7)),
            EZSCStatus(type: .on, startDate: .from(10)),
            EZSCStatus(type: .driving, startDate: .from(12)),
            EZSCStatus(type: .sb, startDate: .from(17)),
            EZSCStatus(type: .off, startDate: .from(24)),
            
        ]

        let result = sut.calculate(firstCase, on: .from(14), specials: [])
        assert(result.drive, 0)
        assert(result.shift, 0)
        assert(result.cycle, 59)
        assert(result.cycleDays, 178)
        
        let result2 = sut.calculate(firstCase, on: .from(17), specials: [])
        assert(result2.drive, -3)
        assert(result2.shift, -3)
        assert(result2.cycle, 56)
        assert(result2.cycleDays, 175)
        
        let result3 = sut.calculate(firstCase, on: .from(24), specials: [])
        assert(result3.drive, 6)
        assert(result3.shift, 7)
        assert(result3.cycle, 56)
        assert(result3.cycleDays, 168)
    }
    
    func test_secondCase() {
        
        let sut = makeSUT()
        let firstCase = [
            EZSCStatus(type: .off, startDate: .from(0)),
            EZSCStatus(type: .driving, startDate: .from(10)),
            EZSCStatus(type: .sb, startDate: .from(15)),
            EZSCStatus(type: .driving, startDate: .from(23)),
            EZSCStatus(type: .sb, startDate: .from(24 + 4)),
            EZSCStatus(type: .driving, startDate: .from(24 + 5.5)),
            EZSCStatus(type: .off, startDate: .from(24 + 13)),
        ]

        let result = sut.calculate(firstCase, on: .from(37), specials: [])
        assert(result.drive, -13)
        assert(result.shift, -13)
        assert(result.cycle, 52.5)
        assert(result.cycleDays, 155)
    }
    
    func test_noviolationData() {
        
        let statuses = [
            EZSCStatus(type: .off, startDate: .from(0)),
            EZSCStatus(type: .on, startDate: .from(10)),
            EZSCStatus(type: .driving, startDate: .from(11)),
            EZSCStatus(type: .off, startDate: .from(13)),
            EZSCStatus(type: .driving, startDate: .from(14)),
            EZSCStatus(type: .on, startDate: .from(17)),
            EZSCStatus(type: .off, startDate: .from(18)),
            EZSCStatus(type: .on, startDate: .from(19)),
            EZSCStatus(type: .driving, startDate: .from(20)),
            EZSCStatus(type: .on, startDate: .from(23)),
            EZSCStatus(type: .off, startDate: .from(26)),
        ]
        
        let sut = makeSUT()
        
        let result = sut.calculate(statuses, on: .from(36), specials: [.hourException])
        assert(result.drive, 11)
        assert(result.shift, 14)
        assert(result.cycle, 56)
        assert(result.cycleDays, 156)
        
        let result2 = sut.calculate(statuses, on: .from(26), specials: [.hourException])
        assert(result2.drive, 0)
        assert(result2.shift, 0)
        assert(result2.cycle, 56)
        assert(result2.cycleDays, 166)
    }
    
    func test_violationData() {
        
        let statuses = [
            EZSCStatus(type: .off, startDate: .from(0)),
            EZSCStatus(type: .on, startDate: .from(10)),
            EZSCStatus(type: .driving, startDate: .from(12)),
            EZSCStatus(type: .off, startDate: .from(16)),
            EZSCStatus(type: .driving, startDate: .from(17)),
            EZSCStatus(type: .off, startDate: .from(20)),
            EZSCStatus(type: .driving, startDate: .from(21)),
            EZSCStatus(type: .on, startDate: .from(22)),
            EZSCStatus(type: .driving, startDate: .from(24)),
            EZSCStatus(type: .off, startDate: .from(27)),
        ]
        
        let sut = makeSUT()
        
        let result2 = sut.calculate(statuses, on: .from(36), specials: [.hourException])
        assert(result2.drive, -10)
        assert(result2.shift, -10)
        assert(result2.cycle, 55)
        assert(result2.cycleDays, 156)
    }
    
    func test_34Restart() {
        
        let statuses = [
            EZSCStatus(type: .driving, startDate: .from(-6)),
            EZSCStatus(type: .off, startDate: .from(0)),
            EZSCStatus(type: .driving, startDate: .from(34)),
            EZSCStatus(type: .off, startDate: .from(40)),
            EZSCStatus(type: .driving, startDate: .from(41)),
            EZSCStatus(type: .on, startDate: .from(45)),
            EZSCStatus(type: .driving, startDate: .from(47)),
            EZSCStatus(type: .off, startDate: .from(48)),
            EZSCStatus(type: .driving, startDate: .from(58)),
            EZSCStatus(type: .off, startDate: .from(63)),
            EZSCStatus(type: .driving, startDate: .from(64)),
            EZSCStatus(type: .on, startDate: .from(69)),
            EZSCStatus(type: .driving, startDate: .from(71)),
        ]
        
        let sut = makeSUT()
        
        let result = sut.calculate(statuses, on: .from(48), specials: [])
        assert(result.drive, 0)
        assert(result.shift, 0)
        assert(result.cycle, 57)
        assert(result.cycleDays, 178)
        
        let result2 = sut.calculate(statuses, on: .from(64), specials: [])
        assert(result2.drive, 6)
        assert(result2.shift, 8)
        assert(result2.cycle, 52)
        assert(result2.cycleDays, 162)
        
        let result3 = sut.calculate(statuses, on: .from(72), specials: [])
        assert(result3.drive, 0)
        assert(result3.shift, 0)
        assert(result3.cycle, 44)
        assert(result3.cycleDays, 154)
        assert(result3.restartHoursCurrent, 34)
        
        let result4 = sut.calculate(statuses, on: .from(41), specials: [])
        assert(result4.drive, 5)
        assert(result4.shift, 7)
        assert(result4.cycle, 64)
        assert(result4.cycleDays, 185)
        assert(result4.tillRestartHours, 10)

        let result5 = sut.calculate(statuses, on: .from(34), specials: [])
        assert(result5.restartHoursCurrent, 0)
    }
    
    func test_testCaseFromDmytro() {
        
        let statuses = [
            EZSCStatus(type: .off, startDate: .from(0)),
            EZSCStatus(type: .sb, startDate: .from(24)),
        ]
        
        let sut = makeSUT()
        
        let result = sut.calculate(statuses, on: .from(28.5), specials: [])
        assert(result.drive, 11)
        assert(result.shift, 14)
        assert(result.cycle, 70)
        assert(result.cycleDays, 163.5)
    }
    
    func test_testAdverseDrivingConditions() {
        
        let statuses = [
            EZSCStatus(type: .driving, startDate: .from(0)),
            EZSCStatus(type: .off, startDate: .from(3)),
            EZSCStatus(type: .driving, startDate: .from(4)),
            EZSCStatus(type: .on, startDate: .from(8)),
            EZSCStatus(type: .off, startDate: .from(9)),
            EZSCStatus(type: .driving, startDate: .from(10)),
            EZSCStatus(type: .off, startDate: .from(15)),
        ]
        
        let sut = makeSUT()
        
        let result = sut.calculate(statuses, on: .from(15), specials: [.adverseDriving])
        assert(result.drive, 1)
        assert(result.shift, 1)
        assert(result.cycle, 57)
        assert(result.cycleDays, 177)
        
        let result2 = sut.calculate(statuses, on: .from(25), specials: [.adverseDriving])
        assert(result2.drive, 11)
        assert(result2.shift, 14)
        assert(result2.cycle, 57)
        assert(result2.cycleDays, 167)
    }
    
    func test_testAdverseDrivingConditionsWithHourException() {
        
        let statuses = [
            EZSCStatus(type: .driving, startDate: .from(0)),
            EZSCStatus(type: .off, startDate: .from(3)),
            EZSCStatus(type: .driving, startDate: .from(4)),
            EZSCStatus(type: .on, startDate: .from(8)),
            EZSCStatus(type: .off, startDate: .from(9)),
            EZSCStatus(type: .driving, startDate: .from(10)),
            EZSCStatus(type: .off, startDate: .from(15)),
        ]
        
        let sut = makeSUT()
        
        let result = sut.calculate(statuses, on: .from(15), specials: [.adverseDriving, .hourException])
        assert(result.drive, 1)
        assert(result.shift, 1)
        assert(result.cycle, 57)
        assert(result.cycleDays, 177)
        
        let result2 = sut.calculate(statuses, on: .from(25), specials: [.adverseDriving, .hourException])
        assert(result2.drive, 11)
        assert(result2.shift, 14)
        assert(result2.cycle, 57)
        assert(result2.cycleDays, 167)
    }
    
    func test_30Min_Changes() {
        
        let statuses = [
            EZSCStatus(type: .driving, startDate: .from(0)),
            EZSCStatus(type: .off, startDate: .from(3)),
            EZSCStatus(type: .driving, startDate: .from(4)),
            EZSCStatus(type: .on, startDate: .from(8)),
            EZSCStatus(type: .off, startDate: .from(9)),
            EZSCStatus(type: .driving, startDate: .from(10)),
            EZSCStatus(type: .off, startDate: .from(15)),
        ]
        
        let sut = makeSUT()
        
        let result = sut.calculate(statuses, on: .from(15), specials: [.adverseDriving])
        assert(result.drive, 1)
        assert(result.shift, 1)
        assert(result.cycle, 57)
        assert(result.cycleDays, 177)
    }
    
    func test_sleeperBerth2Days() {
        
        let statuses = [
            EZSCStatus(type: .off, startDate: .from(0)),
            EZSCStatus(type: .on, startDate: .from(2)),
            EZSCStatus(type: .driving, startDate: .from(3)),
            EZSCStatus(type: .sb, startDate: .from(8)),
            EZSCStatus(type: .driving, startDate: .from(10)),
            EZSCStatus(type: .sb, startDate: .from(14)),
            EZSCStatus(type: .on, startDate: .from(24)),
            EZSCStatus(type: .driving, startDate: .from(24 + 1)),
            EZSCStatus(type: .sb, startDate: .from(24 + 5)),
            EZSCStatus(type: .driving, startDate: .from(24 + 7)),
            EZSCStatus(type: .sb, startDate: .from(24 + 13)),
            EZSCStatus(type: .driving, startDate: .from(24 + 21)),
        ]
        
        let sut = makeSUT()
        
        let result = sut.calculate(statuses, on: .from(48), specials: [])
        assert(result.drive, 2)
        assert(result.shift, 5)
        assert(result.cycle, 46)
        assert(result.cycleDays, 144)
    }
    
    func test_sleeperBerth() {
        
        let statuses = [
            EZSCStatus(type: .off, startDate: .from(0)),
            EZSCStatus(type: .on, startDate: .from(2)),
            EZSCStatus(type: .driving, startDate: .from(3)),
            EZSCStatus(type: .sb, startDate: .from(8)),
            EZSCStatus(type: .driving, startDate: .from(10)),
            EZSCStatus(type: .sb, startDate: .from(14)),
        ]
        
        let sut = makeSUT()
        
        let result = sut.calculate(statuses, on: .from(14), specials: [])
        assert(result.drive, 0)
        assert(result.shift, 0)
        assert(result.cycle, 60)
        assert(result.cycleDays, 178)
    }
    
    func test_example19() {
        
        let statuses = [
            EZSCStatus(type: .off, startDate: .from(-8)),
            EZSCStatus(type: .on, startDate: .from(2)),
            EZSCStatus(type: .driving, startDate: .from(3)),
            EZSCStatus(type: .sb, startDate: .from(8)),
            EZSCStatus(type: .driving, startDate: .from(10)),
            EZSCStatus(type: .sb, startDate: .from(16)),
            EZSCStatus(type: .on, startDate: .from(24)),
            EZSCStatus(type: .driving, startDate: .from(25)),
            EZSCStatus(type: .sb, startDate: .from(29)),
            EZSCStatus(type: .driving, startDate: .from(31)),
            EZSCStatus(type: .sb, startDate: .from(37)),
            EZSCStatus(type: .driving, startDate: .from(45)),
        ]
        
        let sut = makeSUT()
        
        let result = sut.calculate(statuses, on: .from(2), specials: [])
        assert(result.drive, 11)
        assert(result.shift, 14)
        assert(result.cycle, 70)
        assert(result.cycleDays, 182)
        
        let result2 = sut.calculate(statuses, on: .from(10), specials: [])
        assert(result2.drive, 6)
        assert(result2.shift, 6)
        assert(result2.cycle, 64)
        assert(result2.cycleDays, 174)
        
        let result3 = sut.calculate(statuses, on: .from(24), specials: [])
        assert(result3.drive, 5)
        assert(result3.shift, 8)
        assert(result3.cycle, 58)
        assert(result3.cycleDays, 160)
        
        let result4 = sut.calculate(statuses, on: .from(24 + 7), specials: [])
        assert(result4.drive, 7)
        assert(result4.shift, 9)
        assert(result4.cycle, 53)
        assert(result4.cycleDays, 153)
        
        let result5 = sut.calculate(statuses, on: .from(48), specials: [])
        assert(result5.drive, 2)
        assert(result5.shift, 5)
        assert(result5.cycle, 44)
        assert(result5.cycleDays, 136)
    }
    
    func test_30MinutesBreakeChanges() {
        
        let statuses = [
            EZSCStatus(type: .driving, startDate: .from(0)),
            EZSCStatus(type: .on, startDate: .from(5)),
            EZSCStatus(type: .driving, startDate: .from(5.5)),
            EZSCStatus(type: .on, startDate: .from(10.5)),
            EZSCStatus(type: .driving, startDate: .from(11.5)),
            EZSCStatus(type: .on, startDate: .from(12.5)),
            EZSCStatus(type: .off, startDate: .from(14)),
        ]
        
        let sut = makeSUT()
        
        let result = sut.calculate(statuses, on: .from(10.5), specials: [])
        assert(result.drive, 1)
        assert(result.shift, 3.5)
        assert(result.maxTimeWithoutBreak, -2)
        assert(result.cycle, 59.5)
        assert(result.cycleDays, 181.5)
        
        let result2 = sut.calculate(statuses, on: .from(14), specials: [])
        assert(result2.drive, 0)
        assert(result2.shift, 0)
        assert(result2.maxTimeWithoutBreak, -2)
        assert(result2.cycle, 56)
        assert(result2.cycleDays, 178)
    }
    
    func test_30MinutesBreakeChanges_Violation() {
        
        let statuses = [
            EZSCStatus(type: .on, startDate: .from(0)),
            EZSCStatus(type: .driving, startDate: .from(1)),
            EZSCStatus(type: .on, startDate: .from(9.5)),
            EZSCStatus(type: .driving, startDate: .from(10)),
            EZSCStatus(type: .off, startDate: .from(12))
        ]
        
        let sut = makeSUT()
        
        let result = sut.calculate(statuses, on: .from(9.5), specials: [])
        assert(result.drive, 2.5)
        assert(result.shift, 4.5)
        assert(result.maxTimeWithoutBreak, 8)
        assert(result.cycle, 60.5)
        assert(result.cycleDays, 182.5)
    }
    
    func test_shiftViolation() {
        
        let statuses = [
            EZSCStatus(type: .driving, startDate: .from(0)),
            EZSCStatus(type: .on, startDate: .from(7.5)),
            EZSCStatus(type: .off, startDate: .from(9)),
            EZSCStatus(type: .sb, startDate: .from(10)),
            EZSCStatus(type: .off, startDate: .from(11)),
            EZSCStatus(type: .driving, startDate: .from(12)),
            EZSCStatus(type: .on, startDate: .from(13.5)),
            EZSCStatus(type: .driving, startDate: .from(16)),
            EZSCStatus(type: .sb, startDate: .from(17.5)),
        ]
        
        let sut = makeSUT()
        
        let result = sut.calculate(statuses, on: .from(17), specials: [])
        assert(result.drive, -3)
        assert(result.shift, -3)
        assert(result.cycle, 56)
        assert(result.cycleDays, 175)
    }
    
    func test_EmptyEZSCStatus() {
        
        let status = EZSCStatus(type: .driving, startDate: .from(1))
        
        XCTAssertEqual(status.statusLength, 0)
    }
    
    func test_11Violation() {
        
        let statuses = [
            EZSCStatus(type: .off, startDate: .from(0)),
            EZSCStatus(type: .on, startDate: .from(7)),
            EZSCStatus(type: .driving, startDate: .from(8)),
            EZSCStatus(type: .off, startDate: .from(13.5)),
            EZSCStatus(type: .driving, startDate: .from(16.5)),
            EZSCStatus(type: .sb, startDate: .from(22)),
            EZSCStatus(type: .on, startDate: .from(24)),
            EZSCStatus(type: .sb, startDate: .from(25)),
            EZSCStatus(type: .driving, startDate: .from(28)),
            EZSCStatus(type: .sb, startDate: .from(29)),
        ]
        
        let sut = makeSUT()
        
        let result = sut.calculate(statuses, on: .from(29), specials: [])
        assert(result.drive, -5)
        assert(result.shift, -5)
        assert(result.cycle, 56)
        assert(result.cycleDays, 163)
    }
    
    func test_11Violation_() {
        
        let statuses = [
            EZSCStatus(type: .sb, startDate: .from(0)),
            EZSCStatus(type: .on, startDate: .from(9 + .minutes(54) + .seconds(49))),
            EZSCStatus(type: .driving, startDate: .from(10 + .minutes(23) + .seconds(50))),
            EZSCStatus(type: .on, startDate: .from(11 + .minutes(42) + .seconds(28))),
            EZSCStatus(type: .driving, startDate: .from(11 + .minutes(56) + .seconds(43))),
            EZSCStatus(type: .off, startDate: .from(12 + .minutes(8) + .seconds(59))),
            EZSCStatus(type: .driving, startDate: .from(14 + .minutes(3) + .seconds(48))),
            EZSCStatus(type: .on, startDate: .from(14 + .minutes(10) + .seconds(53))),
            EZSCStatus(type: .driving, startDate: .from(14 + .minutes(39) + .seconds(44))),
            EZSCStatus(type: .off, startDate: .from(17 + .minutes(18) + .seconds(13))),
            EZSCStatus(type: .driving, startDate: .from(17 + .minutes(38) + .seconds(57))),
            EZSCStatus(type: .sb, startDate: .from(22 + .minutes(11) + .seconds(18))),
        ]
        
        let sut = makeSUT()
        
        let result = sut.calculate(statuses, on: .from(22 + .minutes(15)), specials: [])
        assert(result.maxTimeWithoutBreak, 8)
    }
   
    func test_offMoreThan30() {
        
        let statuses = [
            EZSCStatus(type: .driving, startDate: .from(0)),
            EZSCStatus(type: .off, startDate: .from(8)),
            EZSCStatus(type: .driving, startDate: .from(8.5)),
            EZSCStatus(type: .off, startDate: .from(11.5)),
        ]
        
        let sut = makeSUT()
        
        let result = sut.calculate(statuses, on: .from(11.5), specials: [])
        assert(result.drive, 0)
        assert(result.shift, 2.5)
        assert(result.cycle, 59)
        assert(result.cycleDays, 180.5)
    }
    
    func test_offMoreThan30Viol() {
        
        let statuses = [
            EZSCStatus(type: .driving, startDate: .from(0)),
            EZSCStatus(type: .off, startDate: .from(8)),
            EZSCStatus(type: .driving, startDate: .from(8.45)),
            EZSCStatus(type: .off, startDate: .from(11.5)),
        ]
        
        let sut = makeSUT()
        
        let result = sut.calculate(statuses, on: .from(11.5), specials: [])
        assert(result.drive, -0.05)
        assert(result.shift, 2.5)
        assert(result.cycle, 58.95)
        assert(result.cycleDays, 180.5)
    }
    
    func test_sbMoreThan30() {
        
        let statuses = [
            EZSCStatus(type: .driving, startDate: .from(0)),
            EZSCStatus(type: .sb, startDate: .from(8)),
            EZSCStatus(type: .driving, startDate: .from(8.5)),
            EZSCStatus(type: .off, startDate: .from(11.5)),
        ]
        
        let sut = makeSUT()
        
        let result = sut.calculate(statuses, on: .from(11.5), specials: [])
        assert(result.drive, 0)
        assert(result.shift, 2.5)
    }
    
    func test_sbMoreThan30Viol() {
        
        let statuses = [
            EZSCStatus(type: .driving, startDate: .from(0)),
            EZSCStatus(type: .sb, startDate: .from(8)),
            EZSCStatus(type: .driving, startDate: .from(8.45)),
            EZSCStatus(type: .off, startDate: .from(11.5)),
        ]
        
        let sut = makeSUT()
        
        let result = sut.calculate(statuses, on: .from(11.5), specials: [])
        assert(result.drive, -0.05)
        assert(result.shift, 2.5)
    }

    
    func test_onMoreThan30() {
        
        let statuses = [
            EZSCStatus(type: .driving, startDate: .from(0)),
            EZSCStatus(type: .on, startDate: .from(8)),
            EZSCStatus(type: .driving, startDate: .from(8.5)),
            EZSCStatus(type: .off, startDate: .from(11.5)),
        ]
        
        let sut = makeSUT()
        
        let result = sut.calculate(statuses, on: .from(11.5), specials: [])
        assert(result.drive, 0)
        assert(result.shift, 2.5)
    }
    
    func test_onMoreThan30Viol() {
        
        let statuses = [
            EZSCStatus(type: .driving, startDate: .from(0)),
            EZSCStatus(type: .on, startDate: .from(8)),
            EZSCStatus(type: .driving, startDate: .from(8.45)),
            EZSCStatus(type: .off, startDate: .from(11.5)),
        ]
        
        let sut = makeSUT()
        
        let result = sut.calculate(statuses, on: .from(11.5), specials: [])
        assert(result.drive, -0.05)
        assert(result.shift, 2.5)
    }
    
    func test_offMoreThan10() {
        let statuses = [
            EZSCStatus(type: .driving, startDate: .from(0)),
            EZSCStatus(type: .off, startDate: .from(8)),
            EZSCStatus(type: .driving, startDate: .from(18)),
        ]
        
        let sut = makeSUT()
        
        let result = sut.calculate(statuses, on: .from(24), specials: [])
        assert(result.drive, 5)
        assert(result.shift, 8)
    }
    
    func test_offMoreThan10Viol() {
        let statuses = [
            EZSCStatus(type: .driving, startDate: .from(0)),
            EZSCStatus(type: .off, startDate: .from(8)),
            EZSCStatus(type: .driving, startDate: .from(17.75)),
        ]
        
        let sut = makeSUT()
        
        let result = sut.calculate(statuses, on: .from(24), specials: [])
        assert(result.drive, -10)
        assert(result.shift, -10)
    }
    
    func test_sbMoreThan10() {
        let statuses = [
            EZSCStatus(type: .driving, startDate: .from(0)),
            EZSCStatus(type: .sb, startDate: .from(8)),
            EZSCStatus(type: .driving, startDate: .from(18)),
        ]
        
        let sut = makeSUT()
        
        let result = sut.calculate(statuses, on: .from(24), specials: [])
        assert(result.drive, 5)
        assert(result.shift, 8)
    }
    
    func test_sbMoreThan10Viol() {
        let statuses = [
            EZSCStatus(type: .driving, startDate: .from(0)),
            EZSCStatus(type: .sb, startDate: .from(8)),
            EZSCStatus(type: .driving, startDate: .from(17.75)),
        ]
        
        let sut = makeSUT()
        
        let result = sut.calculate(statuses, on: .from(24), specials: [])
        assert(result.drive, -10)
        assert(result.shift, -10)
    }
    
    func test_2to8() {
        let statuses = [
            EZSCStatus(type: .driving, startDate: .from(0)),
            EZSCStatus(type: .off, startDate: .from(2)),
            EZSCStatus(type: .driving, startDate: .from(4)),
            EZSCStatus(type: .sb, startDate: .from(12)),
            EZSCStatus(type: .driving, startDate: .from(20)),
            EZSCStatus(type: .on, startDate: .from(23)),
        ]
        
        let sut = makeSUT()
        
        let result = sut.calculate(statuses, on: .from(24), specials: [])
        assert(result.drive, 0)
        assert(result.shift, 2)
    }
    
    func test_big_bigShift() {
        
        let statuses = [
            EZSCStatus(type: .on, startDate: .from(0)),
            EZSCStatus(type: .driving, startDate: .from(1)),
            EZSCStatus(type: .off, startDate: .from(7)),
            EZSCStatus(type: .on, startDate: .from(10)),
            EZSCStatus(type: .driving, startDate: .from(12)),
            EZSCStatus(type: .off, startDate: .from(16)),
            EZSCStatus(type: .sb, startDate: .from(17)),
            EZSCStatus(type: .off, startDate: .from(24)),
            EZSCStatus(type: .driving, startDate: .from(25)),
            EZSCStatus(type: .sb, startDate: .from(31)),
        ]
        
        let sut = makeSUT()
        
        let result = sut.calculate(statuses, on: .from(34), specials: [])
        assert(result.drive, 5)
        assert(result.shift, 7)
    }
    
    func test_big_bigShift_driving() {
        
        let statuses = [
            EZSCStatus(type: .on, startDate: .from(0)),
            EZSCStatus(type: .driving, startDate: .from(1)),
            EZSCStatus(type: .off, startDate: .from(7)),
            EZSCStatus(type: .on, startDate: .from(10)),
            EZSCStatus(type: .driving, startDate: .from(12)),
            EZSCStatus(type: .off, startDate: .from(16)),
            EZSCStatus(type: .sb, startDate: .from(17)),
            EZSCStatus(type: .off, startDate: .from(24)),
            EZSCStatus(type: .driving, startDate: .from(25)),
        ]
        
        let sut = makeSUT()
        
        let result = sut.calculate(statuses, on: .from(32), specials: [])
        assert(result.drive, -1)
        assert(result.shift, -1)
    }
    
    func test_big_bigShift_twoSB() {
        
        let statuses = [
            EZSCStatus(type: .on, startDate: .from(0)),
            EZSCStatus(type: .driving, startDate: .from(1)),
            EZSCStatus(type: .off, startDate: .from(7)),
            EZSCStatus(type: .on, startDate: .from(10)),
            EZSCStatus(type: .driving, startDate: .from(12)),
            EZSCStatus(type: .off, startDate: .from(16)),
            EZSCStatus(type: .sb, startDate: .from(17)),
            EZSCStatus(type: .sb, startDate: .from(20)),
            EZSCStatus(type: .off, startDate: .from(24)),
            EZSCStatus(type: .driving, startDate: .from(25)),
        ]
        
        let sut = makeSUT()
        
        let result = sut.calculate(statuses, on: .from(32), specials: [])
        assert(result.drive, -1)
        assert(result.shift, -1)
    }
    
    func test_big_bigShift_multiple_SB() {
        
        let statuses = [
            EZSCStatus(type: .on, startDate: .from(0)),
            EZSCStatus(type: .driving, startDate: .from(1)),
            EZSCStatus(type: .off, startDate: .from(7)),
            EZSCStatus(type: .on, startDate: .from(10)),
            EZSCStatus(type: .driving, startDate: .from(12)),
            EZSCStatus(type: .off, startDate: .from(16)),
            EZSCStatus(type: .sb, startDate: .from(17)),
            EZSCStatus(type: .sb, startDate: .from(18)),
            EZSCStatus(type: .sb, startDate: .from(19)),
            EZSCStatus(type: .sb, startDate: .from(20)),
            EZSCStatus(type: .sb, startDate: .from(21)),
            EZSCStatus(type: .sb, startDate: .from(22)),
            EZSCStatus(type: .sb, startDate: .from(23)),
            EZSCStatus(type: .off, startDate: .from(24)),
            EZSCStatus(type: .driving, startDate: .from(25)),
        ]
        
        let sut = makeSUT()
        
        let result = sut.calculate(statuses, on: .from(32), specials: [])
        assert(result.drive, -1)
        assert(result.shift, -1)
    }
    
    func test_two_off_with_rest_shift() {
        
        let statuses = [
            EZSCStatus(type: .off, startDate: .from(0)),
            EZSCStatus(type: .on, startDate: .from(13)),
            EZSCStatus(type: .off, startDate: .from(14)),
            EZSCStatus(type: .sb, startDate: .from(16)),
            EZSCStatus(type: .off, startDate: .from(23)),
        ]
        
        let sut = makeSUT()
        
        let result = sut.calculate(statuses, on: .from(24), specials: [])
        assert(result.drive, 11)
        assert(result.shift, 14)
    }
    
    func test_two_off_with_rest_two_long_shift() {
        
        let statuses = [
            EZSCStatus(type: .driving, startDate: .from(0)),
            EZSCStatus(type: .sb, startDate: .from(1)),
            EZSCStatus(type: .driving, startDate: .from(8)),
            EZSCStatus(type: .sb, startDate: .from(9)),
            EZSCStatus(type: .driving, startDate: .from(16)),
            EZSCStatus(type: .off, startDate: .from(21)),
        ]
        
        let sut = makeSUT()
        
        let result = sut.calculate(statuses, on: .from(16), specials: [])
        assert(result.drive, 10)
        assert(result.shift, 13)
    }
    
    func test_two_off_with_rest_two_long_shift_date() {
        
        let statuses = [
            EZSCStatus(type: .driving, startDate: .from(0)),
            EZSCStatus(type: .sb, startDate: .from(1)),
            EZSCStatus(type: .driving, startDate: .from(8)),
            EZSCStatus(type: .sb, startDate: .from(9)),
            EZSCStatus(type: .driving, startDate: .from(16)),
            EZSCStatus(type: .off, startDate: .from(21)),
        ]
        
        let sut = makeSUT()
        
        let result = sut.calculate(statuses, on: .from(16), specials: [])
        assert(result.drive, 10)
        assert(result.shift, 13)
        assert(result.date.timeIntervalSince1970, 16)
    }
    
    func test_ideal_3_7_split() {
        
        let statuses = [
            EZSCStatus(type: .on, startDate: .from(0)),
            EZSCStatus(type: .driving, startDate: .from(1)),
            EZSCStatus(type: .off, startDate: .from(7)),
            EZSCStatus(type: .on, startDate: .from(10)),
            EZSCStatus(type: .driving, startDate: .from(12)),
            EZSCStatus(type: .sb, startDate: .from(17)),
        ]
        
        let sut = makeSUT()
        
        let result = sut.calculate(statuses, on: .from(17), specials: [])
        assert(result.drive, -3)
        assert(result.shift, -3)
        
        let result2 = sut.calculate(statuses, on: .from(14), specials: [])
        assert(result2.drive, 0)
        assert(result2.shift, 0)
        
        let result3 = sut.calculate(statuses, on: .from(24), specials: [])
        assert(result3.drive, 6)
        assert(result3.shift, 7)
    }
    
    func test_corona_status() {
        
        let statuses = [
            EZSCStatus(type: .sb, startDate: .from(0)),
            EZSCStatus(type: .on, startDate: .from(7)),
            EZSCStatus(type: .driving, startDate: .from(9)),
            EZSCStatus(type: .sb, startDate: .from(15.75)),
            EZSCStatus(type: .driving, startDate: .from(24)),
            EZSCStatus(type: .on, startDate: .from(25.25)),
            EZSCStatus(type: .sb, startDate: .from(29)),
            EZSCStatus(type: .sb, startDate: .from(29.25)),
            EZSCStatus(type: .off, startDate: .from(29.75)),
            EZSCStatus(type: .driving, startDate: .from(31.25)),
            EZSCStatus(type: .off, startDate: .from(32)),
        ]
        
        let sut = makeSUT()
        
        let result = sut.calculate(statuses, on: .from(24), specials: [])
        assert(result.drive, 4.25)
        assert(result.shift, 5.25)
        
        let result2 = sut.calculate(statuses, on: .from(32), specials: [])
        assert(result2.drive, 8.25)
        assert(result2.shift, 8.25)
    }
    
    func test_big_bigShift_multiple_Off_SB() {
        
        let statuses = [
            EZSCStatus(type: .on, startDate: .from(0)),
            EZSCStatus(type: .driving, startDate: .from(1)),
            EZSCStatus(type: .off, startDate: .from(7)),
            EZSCStatus(type: .on, startDate: .from(10)),
            EZSCStatus(type: .driving, startDate: .from(12)),
            EZSCStatus(type: .off, startDate: .from(16)),
            EZSCStatus(type: .sb, startDate: .from(17)),
            EZSCStatus(type: .off, startDate: .from(20)),
            EZSCStatus(type: .sb, startDate: .from(21)),
        ]
        
        let sut = makeSUT()
        
        let result = sut.calculate(statuses, on: .from(24), specials: [])
        assert(result.drive, -10)
        assert(result.shift, -10)
        
        let result2 = sut.calculate(statuses, on: .from(14), specials: [])
        assert(result2.drive, 0)
        assert(result2.shift, 0)
    }
    
    func makeSUT() -> EZShiftCalculator {
        EZShiftCalculator(SPY())
    }
    
    class SPY: RuleProvider {
        func getRule(for date: Date) -> EZShiftRule {
            ShiftRuleInSeconds()
        }
    }
}

func assert(_ result: TimeInterval, _ expected: TimeInterval, file: StaticString = #file, line: UInt = #line) {
    
    XCTAssert(result == expected * 3600, "Difference: \((result - expected * 3600) / 3600), Expected: \(expected), Actual: \((result / 3600))", file: file, line: line)
}


var realEZSCStatuses: [EZSCStatus] {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .secondsSince1970
    return (try? decoder.decode([EZSCStatus].self, from: realEZSCStatusesFromELDAccount.data(using: .utf8)!)) ?? []
}

let realEZSCStatusesFromELDAccount =
    """
[{
    "startDate": 1599801300,
    "type": 1,
    "endDate": 1600276500,
    "restart": 122400
}, {
    "startDate": 1600276500,
    "type": 3,
    "endDate": 1600732800,
    "restart": 122400
}, {
    "startDate": 1600732800,
    "type": 0,
    "endDate": 1600736400,
    "restart": -333645
}, {
    "startDate": 1600736400,
    "type": 1,
    "endDate": 1600761600,
    "restart": 122400
}, {
    "startDate": 1600761600,
    "type": 2,
    "endDate": 1600763400,
    "restart": 122400
}, {
    "startDate": 1600763400,
    "type": 1,
    "endDate": 1600777800,
    "restart": 120600
}, {
    "startDate": 1600777800,
    "type": 3,
    "endDate": 1600781400,
    "restart": 122400
}, {
    "startDate": 1600781400,
    "type": 2,
    "endDate": 1600819200,
    "restart": 118800
}, {
    "startDate": 1600819200,
    "type": 0,
    "endDate": 1600822800,
    "restart": 81000
}, {
    "startDate": 1600822800,
    "type": 1,
    "endDate": 1600844400,
    "restart": 122400
}, {
    "startDate": 1600844400,
    "type": 3,
    "endDate": 1600855200,
    "restart": 122400
}, {
    "startDate": 1600855200,
    "type": 0,
    "endDate": 1600862400,
    "restart": 111600
}, {
    "startDate": 1600862400,
    "type": 1,
    "endDate": 1600880400,
    "restart": 122400
}, {
    "startDate": 1600880400,
    "type": 2,
    "endDate": 1600905600,
    "restart": 122400
}, {
    "startDate": 1600905600,
    "type": 3,
    "endDate": 1600992000,
    "restart": 97200
}, {
    "startDate": 1600992000,
    "type": 0,
    "endDate": 1601021700,
    "restart": 10800
}, {
    "startDate": 1601021700,
    "type": 1,
    "endDate": 1601021700,
    "restart": 122400
}, {
    "startDate": 1601021700,
    "type": 3,
    "endDate": 1601078400,
    "restart": 122400
}, {
    "startDate": 1601078400,
    "type": 0,
    "endDate": 1601082000,
    "restart": 66408
}, {
    "startDate": 1601082000,
    "type": 1,
    "endDate": 1601103600,
    "restart": 122400
}, {
    "startDate": 1601103600,
    "type": 3,
    "endDate": 1601114400,
    "restart": 122400
}, {
    "startDate": 1601114400,
    "type": 0,
    "endDate": 1601121600,
    "restart": 111600
}, {
    "startDate": 1601121600,
    "type": 1,
    "endDate": 1601139600,
    "restart": 122400
}, {
    "startDate": 1601139600,
    "type": 2,
    "endDate": 1601164800,
    "restart": 122400
}, {
    "startDate": 1601164800,
    "type": 3,
    "endDate": 1601251200,
    "restart": 97200
}, {
    "startDate": 1601251200,
    "type": 3,
    "endDate": 1601337600,
    "restart": 10800
}, {
    "startDate": 1601337600,
    "type": 3,
    "endDate": 1601424000,
    "restart": -50400
}, {
    "startDate": 1601424000,
    "type": 3,
    "endDate": 1601510400,
    "restart": -136800
}, {
    "startDate": 1601510400,
    "type": 0,
    "endDate": 1601514000,
    "restart": -223200
}, {
    "startDate": 1601514000,
    "type": 1,
    "endDate": 1601532000,
    "restart": 122400
}, {
    "startDate": 1601532000,
    "type": 3,
    "endDate": 1601542800,
    "restart": 122400
}, {
    "startDate": 1601542800,
    "type": 0,
    "endDate": 1601550000,
    "restart": 111600
}, {
    "startDate": 1601550000,
    "type": 1,
    "endDate": 1601596800,
    "restart": 122400
}, {
    "startDate": 1601596800,
    "type": 3,
    "endDate": 1601683200,
    "restart": 122400
}, {
    "startDate": 1601683200,
    "type": 3,
    "endDate": 1601733600,
    "restart": 36000
}, {
    "startDate": 1601733600,
    "type": 3,
    "endDate": 1601769600,
    "restart": -14400
}, {
    "startDate": 1601769600,
    "type": 3,
    "endDate": 1601787600,
    "restart": -50400
}, {
    "startDate": 1601787600,
    "type": 0,
    "endDate": 1601791200,
    "restart": -68400
}, {
    "startDate": 1601791200,
    "type": 1,
    "endDate": 1601802000,
    "restart": 122400
}, {
    "startDate": 1601802000,
    "type": 3,
    "endDate": 1601809200,
    "restart": 122400
}, {
    "startDate": 1601809200,
    "type": 0,
    "endDate": 1601812800,
    "restart": 115200
}, {
    "startDate": 1601812800,
    "type": 3,
    "endDate": 1601856000,
    "restart": 122400
}, {
    "startDate": 1601856000,
    "type": 3,
    "endDate": 1601920800,
    "restart": 79200
}, {
    "startDate": 1601920800,
    "type": 0,
    "endDate": 1601924400,
    "restart": 14400
}, {
    "startDate": 1601924400,
    "type": 1,
    "endDate": 1601942400,
    "restart": 122400
}, {
    "startDate": 1601942400,
    "type": 1,
    "endDate": 1601946000,
    "restart": 122400
}, {
    "startDate": 1601946000,
    "type": 3,
    "endDate": 1601956800,
    "restart": 122400
}, {
    "startDate": 1601956800,
    "type": 0,
    "endDate": 1601964000,
    "restart": 111600
}, {
    "startDate": 1601964000,
    "type": 1,
    "endDate": 1602028800,
    "restart": 122400
}, {
    "startDate": 1602028800,
    "type": 1,
    "endDate": 1602029700,
    "restart": 122400
}, {
    "startDate": 1602029700,
    "type": 3,
    "endDate": 1602115200,
    "restart": 122400
}, {
    "startDate": 1602115200,
    "type": 3,
    "endDate": 1602125100,
    "restart": 122400
}]
"""
