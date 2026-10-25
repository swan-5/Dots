import Foundation
import SwiftData

/// Centralizes "what else references this Dot" so deletion never leaves dangling
/// UUID references behind in Connections, Constellation membership, or Story membership.
enum DeletionService {

    struct ImpactSummary {
        let connectionCount: Int
        let constellationTitles: [String]
        let storyTitles: [String]

        var isEmpty: Bool { connectionCount == 0 && constellationTitles.isEmpty && storyTitles.isEmpty }
    }

    static func impact(ofDeleting dot: Dot, context: ModelContext) -> ImpactSummary {
        let dotID = dot.id
        let connections = (try? context.fetch(FetchDescriptor<Connection>())) ?? []
        let affectedConnections = connections.filter { $0.sourceDotID == dotID || $0.targetDotID == dotID }

        let constellations = (try? context.fetch(FetchDescriptor<Constellation>())) ?? []
        let affectedConstellations = constellations.filter { $0.memberDotIDs.contains(dotID) }

        let stories = (try? context.fetch(FetchDescriptor<Story>())) ?? []
        let affectedStories = stories.filter { $0.orderedDotIDs.contains(dotID) }

        return ImpactSummary(
            connectionCount: affectedConnections.count,
            constellationTitles: affectedConstellations.map { $0.customTitle },
            storyTitles: affectedStories.map { $0.title }
        )
    }

    /// Deletes the dot and scrubs every dangling reference to it.
    static func deleteDot(_ dot: Dot, context: ModelContext) {
        let dotID = dot.id

        let connections = (try? context.fetch(FetchDescriptor<Connection>())) ?? []
        for connection in connections where connection.sourceDotID == dotID || connection.targetDotID == dotID {
            context.delete(connection)
        }

        let constellations = (try? context.fetch(FetchDescriptor<Constellation>())) ?? []
        for constellation in constellations where constellation.memberDotIDs.contains(dotID) {
            constellation.memberDotIDs.removeAll { $0 == dotID }
            constellation.updatedAt = .now
        }

        let stories = (try? context.fetch(FetchDescriptor<Story>())) ?? []
        for story in stories where story.orderedDotIDs.contains(dotID) {
            story.orderedDotIDs.removeAll { $0 == dotID }
            story.updatedAt = .now
        }

        let reflections = (try? context.fetch(FetchDescriptor<Reflection>())) ?? []
        for reflection in reflections where reflection.dotID == dotID {
            context.delete(reflection)
        }

        context.delete(dot)
    }
}
