import XCTest
import SwiftData
@testable import Dots

final class DeletionIntegrityTests: XCTestCase {

    private func makeInMemoryContext() throws -> ModelContext {
        let schema = Schema([Dot.self, Connection.self, Constellation.self, Story.self, Reflection.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [configuration])
        return ModelContext(container)
    }

    func testDeletingDotRemovesItsConnections() throws {
        let context = try makeInMemoryContext()
        let a = Dot(title: "a", eventDate: .now)
        let b = Dot(title: "b", eventDate: .now)
        context.insert(a)
        context.insert(b)
        let connection = Connection(sourceDotID: a.id, targetDotID: b.id, kind: .ledTo, reason: "test")
        context.insert(connection)

        DeletionService.deleteDot(a, context: context)

        let remainingConnections = try context.fetch(FetchDescriptor<Connection>())
        XCTAssertTrue(remainingConnections.isEmpty, "Connection referencing a deleted Dot must not dangle")

        let remainingDots = try context.fetch(FetchDescriptor<Dot>())
        XCTAssertEqual(remainingDots.map { $0.title }, ["b"])
    }

    func testDeletingDotRemovesItFromConstellationMembershipWithoutDeletingConstellation() throws {
        let context = try makeInMemoryContext()
        let a = Dot(title: "a", eventDate: .now)
        let b = Dot(title: "b", eventDate: .now)
        context.insert(a)
        context.insert(b)
        let constellation = Constellation(customTitle: "Group", templateID: "orion", memberDotIDs: [a.id, b.id])
        context.insert(constellation)

        DeletionService.deleteDot(a, context: context)

        let constellations = try context.fetch(FetchDescriptor<Constellation>())
        XCTAssertEqual(constellations.count, 1, "Deleting a member Dot must not delete the Constellation itself")
        XCTAssertEqual(constellations.first?.memberDotIDs, [b.id])
    }

    func testDeletingDotRemovesItFromStoryMembership() throws {
        let context = try makeInMemoryContext()
        let a = Dot(title: "a", eventDate: .now)
        let b = Dot(title: "b", eventDate: .now)
        context.insert(a)
        context.insert(b)
        let story = Story(title: "Story", mode: .personal, orderedDotIDs: [a.id, b.id])
        context.insert(story)

        DeletionService.deleteDot(a, context: context)

        let stories = try context.fetch(FetchDescriptor<Story>())
        XCTAssertEqual(stories.first?.orderedDotIDs, [b.id])
    }

    func testNoSelfLinkDuplicateDetection() {
        let a = UUID()
        let b = UUID()
        let original = Connection(sourceDotID: a, targetDotID: b, kind: .learnedFrom, reason: "r1")
        let sameDirection = Connection(sourceDotID: a, targetDotID: b, kind: .learnedFrom, reason: "r2")
        let reversedDirection = Connection(sourceDotID: b, targetDotID: a, kind: .learnedFrom, reason: "r3")
        let differentKind = Connection(sourceDotID: a, targetDotID: b, kind: .unexpected, reason: "r4")

        XCTAssertTrue(original.isDuplicate(of: sameDirection))
        XCTAssertTrue(original.isDuplicate(of: reversedDirection))
        XCTAssertFalse(original.isDuplicate(of: differentKind))
    }

    func testImpactSummaryReportsAllAffectedRecords() throws {
        let context = try makeInMemoryContext()
        let a = Dot(title: "a", eventDate: .now)
        let b = Dot(title: "b", eventDate: .now)
        context.insert(a)
        context.insert(b)
        context.insert(Connection(sourceDotID: a.id, targetDotID: b.id, kind: .other, reason: "r"))
        context.insert(Constellation(customTitle: "Group", templateID: "orion", memberDotIDs: [a.id, b.id]))
        context.insert(Story(title: "Story", mode: .personal, orderedDotIDs: [a.id]))

        let impact = DeletionService.impact(ofDeleting: a, context: context)

        XCTAssertEqual(impact.connectionCount, 1)
        XCTAssertEqual(impact.constellationTitles, ["Group"])
        XCTAssertEqual(impact.storyTitles, ["Story"])
        XCTAssertFalse(impact.isEmpty)
    }
}
