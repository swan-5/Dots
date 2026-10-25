import XCTest
@testable import Dots

final class ChronologyTests: XCTestCase {

    private func makeDot(_ title: String, _ dateString: String, createdOffset: TimeInterval = 0) -> Dot {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(identifier: "UTC")
        let date = formatter.date(from: dateString)!
        let dot = Dot(title: title, eventDate: date)
        dot.createdAt = Date(timeIntervalSince1970: createdOffset)
        return dot
    }

    func testChronologyIndependentOfCreationOrder() {
        // Acceptance criterion #2: dots created out of order still sort correctly by eventDate.
        let dot2025 = makeDot("2025", "2025-01-01", createdOffset: 0)
        let dot2023 = makeDot("2023", "2023-01-01", createdOffset: 1)
        let dot2024 = makeDot("2024", "2024-01-01", createdOffset: 2)

        let ascending = ChronologySort.sorted([dot2025, dot2023, dot2024], direction: .oldestFirst)
        XCTAssertEqual(ascending.map { $0.title }, ["2023", "2024", "2025"])

        let descending = ChronologySort.sorted([dot2025, dot2023, dot2024], direction: .newestFirst)
        XCTAssertEqual(descending.map { $0.title }, ["2025", "2024", "2023"])
    }

    func testSameDateTiebreaksByCreationTimeDeterministically() {
        let first = makeDot("first", "2024-05-01", createdOffset: 0)
        let second = makeDot("second", "2024-05-01", createdOffset: 10)

        let result1 = ChronologySort.sorted([second, first], direction: .newestFirst).map { $0.title }
        let result2 = ChronologySort.sorted([first, second], direction: .newestFirst).map { $0.title }

        // Order must be stable/deterministic regardless of input order.
        XCTAssertEqual(result1, result2)
        XCTAssertEqual(result1, ["first", "second"])
    }

    func testEditingDateChangesOrderWithoutMutatingOtherFields() {
        let dot = makeDot("movable", "2024-01-01")
        let anchor = makeDot("anchor", "2024-06-01")

        var ordered = ChronologySort.sorted([dot, anchor], direction: .oldestFirst)
        XCTAssertEqual(ordered.map { $0.title }, ["movable", "anchor"])

        dot.eventDate = DateFormatter.dotsTestUTC.date(from: "2024-12-01")!
        ordered = ChronologySort.sorted([dot, anchor], direction: .oldestFirst)
        XCTAssertEqual(ordered.map { $0.title }, ["anchor", "movable"])
    }

    func testGroupedByMonthPreservesIncomingOrderAndGroupsCorrectly() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!

        let a = makeDot("a", "2024-03-05")
        let b = makeDot("b", "2024-03-20")
        let c = makeDot("c", "2024-04-01")

        let sorted = ChronologySort.sorted([a, b, c], direction: .oldestFirst)
        let groups = ChronologySort.groupedByMonth(sorted, calendar: calendar)

        XCTAssertEqual(groups.count, 2)
        XCTAssertEqual(groups[0].dots.map { $0.title }, ["a", "b"])
        XCTAssertEqual(groups[1].dots.map { $0.title }, ["c"])
    }
}

extension DateFormatter {
    static let dotsTestUTC: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(identifier: "UTC")
        return formatter
    }()
}
