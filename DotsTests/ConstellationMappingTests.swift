import XCTest
@testable import Dots

final class ConstellationMappingTests: XCTestCase {

    private func makeDot(_ title: String, daysFromEpoch: Int) -> Dot {
        let date = Date(timeIntervalSince1970: TimeInterval(daysFromEpoch * 86_400))
        return Dot(title: title, eventDate: date)
    }

    func testExactFillHasNoPlaceholdersAndNoOverflow() {
        let template = ConstellationCatalog.cassiopeia // 5 anchors
        let dots = (0..<5).map { makeDot("dot\($0)", daysFromEpoch: $0) }

        let mapping = ConstellationMapper.map(memberDots: dots, template: template)

        XCTAssertEqual(mapping.assignments.count, 5)
        XCTAssertTrue(mapping.unfilledAnchors.isEmpty)
        XCTAssertTrue(mapping.overflowDots.isEmpty)
        XCTAssertFalse(mapping.isPartial)
        XCTAssertFalse(mapping.hasOverflow)
    }

    func testFewerDotsThanAnchorsProducesPartialWithMostProminentAnchorsFilled() {
        let template = ConstellationCatalog.orion // 7 anchors
        let dots = (0..<3).map { makeDot("dot\($0)", daysFromEpoch: $0) }

        let mapping = ConstellationMapper.map(memberDots: dots, template: template)

        XCTAssertEqual(mapping.assignments.count, 3)
        XCTAssertEqual(mapping.unfilledAnchors.count, 4)
        XCTAssertTrue(mapping.isPartial)
        XCTAssertTrue(mapping.overflowDots.isEmpty)

        // The three filled anchors must be the three most prominent (lowest prominence value).
        let filledProminences = Set(mapping.assignments.map { $0.anchor.prominence })
        XCTAssertEqual(filledProminences, [1, 2, 3])

        // Earliest dot (chronologically) maps to the single most prominent anchor.
        let mostProminentAssignment = mapping.assignments.first { $0.anchor.prominence == 1 }
        XCTAssertEqual(mostProminentAssignment?.dot.title, "dot0")
    }

    func testMoreDotsThanAnchorsFillsAllAnchorsAndPlacesRestInOverflow() {
        let template = ConstellationCatalog.lyra // 5 anchors
        let dots = (0..<8).map { makeDot("dot\($0)", daysFromEpoch: $0) }

        let mapping = ConstellationMapper.map(memberDots: dots, template: template)

        XCTAssertEqual(mapping.assignments.count, 5)
        XCTAssertTrue(mapping.unfilledAnchors.isEmpty)
        XCTAssertEqual(mapping.overflowDots.count, 3)
        XCTAssertFalse(mapping.isPartial)
        XCTAssertTrue(mapping.hasOverflow)

        // Overflow holds the chronologically-latest dots, nothing silently dropped.
        XCTAssertEqual(Set(mapping.overflowDots.map { $0.title }), ["dot5", "dot6", "dot7"])
        let allAssignedAndOverflow = Set(mapping.assignments.map { $0.dot.title }).union(mapping.overflowDots.map { $0.title })
        XCTAssertEqual(allAssignedAndOverflow.count, 8)
    }

    func testMappingIsDeterministicAcrossRepeatedCalls() {
        let template = ConstellationCatalog.ursaMajor
        let dots = (0..<4).map { makeDot("dot\($0)", daysFromEpoch: $0) }.shuffled()

        let first = ConstellationMapper.map(memberDots: dots, template: template)
        let second = ConstellationMapper.map(memberDots: dots, template: template)

        XCTAssertEqual(first.assignments.map { $0.anchor.id }, second.assignments.map { $0.anchor.id })
        XCTAssertEqual(first.assignments.map { $0.dot.title }, second.assignments.map { $0.dot.title })
    }

    func testAllFiveCatalogTemplatesHaveConnectedLinesReferencingRealAnchors() {
        for template in ConstellationCatalog.templates {
            XCTAssertFalse(template.anchors.isEmpty, "\(template.id) should have anchors")
            for line in template.lines {
                XCTAssertNotNil(template.anchor(withID: line.fromAnchorID), "\(template.id) line references missing anchor \(line.fromAnchorID)")
                XCTAssertNotNil(template.anchor(withID: line.toAnchorID), "\(template.id) line references missing anchor \(line.toAnchorID)")
            }
        }
    }
}
