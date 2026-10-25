import Foundation
import SwiftData

/// JSON export/import for local backup. Local-first app, so this is the only way data
/// moves between devices for MVP — there is no automatic sync.
enum BackupCodec {

    struct Payload: Codable {
        var version: Int = 1
        var exportedAt: Date = .now
        var dots: [DotDTO]
        var connections: [ConnectionDTO]
        var constellations: [ConstellationDTO]
        var stories: [StoryDTO]
    }

    struct DotDTO: Codable {
        var id: UUID
        var title: String
        var eventDate: Date
        var createdAt: Date
        var updatedAt: Date
        var category: String
        var bodyText: String
        var tags: [String]
        var locationText: String
        var referenceURLString: String
    }

    struct ConnectionDTO: Codable {
        var id: UUID
        var sourceDotID: UUID
        var targetDotID: UUID
        var kind: String
        var reason: String
        var discoveredAt: Date
    }

    struct ConstellationDTO: Codable {
        var id: UUID
        var customTitle: String
        var templateID: String
        var createdAt: Date
        var updatedAt: Date
        var memberDotIDs: [UUID]
    }

    struct StoryDTO: Codable {
        var id: UUID
        var title: String
        var mode: String
        var bodyText: String
        var orderedDotIDs: [UUID]
        var createdAt: Date
        var updatedAt: Date
    }

    struct ImportSummary {
        var insertedDots = 0
        var insertedConnections = 0
        var insertedConstellations = 0
        var insertedStories = 0
        var skippedExistingIDs = 0
    }

    static func exportData(context: ModelContext) throws -> Data {
        let dots = (try? context.fetch(FetchDescriptor<Dot>())) ?? []
        let connections = (try? context.fetch(FetchDescriptor<Connection>())) ?? []
        let constellations = (try? context.fetch(FetchDescriptor<Constellation>())) ?? []
        let stories = (try? context.fetch(FetchDescriptor<Story>())) ?? []

        let payload = Payload(
            dots: dots.map {
                DotDTO(id: $0.id, title: $0.title, eventDate: $0.eventDate, createdAt: $0.createdAt, updatedAt: $0.updatedAt, category: $0.categoryRaw, bodyText: $0.bodyText, tags: $0.tags, locationText: $0.locationText, referenceURLString: $0.referenceURLString)
            },
            connections: connections.map {
                ConnectionDTO(id: $0.id, sourceDotID: $0.sourceDotID, targetDotID: $0.targetDotID, kind: $0.kindRaw, reason: $0.reason, discoveredAt: $0.discoveredAt)
            },
            constellations: constellations.map {
                ConstellationDTO(id: $0.id, customTitle: $0.customTitle, templateID: $0.templateID, createdAt: $0.createdAt, updatedAt: $0.updatedAt, memberDotIDs: $0.memberDotIDs)
            },
            stories: stories.map {
                StoryDTO(id: $0.id, title: $0.title, mode: $0.modeRaw, bodyText: $0.bodyText, orderedDotIDs: $0.orderedDotIDs, createdAt: $0.createdAt, updatedAt: $0.updatedAt)
            }
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try encoder.encode(payload)
    }

    /// Imports a backup, skipping any record whose id already exists locally (conflict
    /// strategy: existing local data always wins; nothing is overwritten).
    static func importData(_ data: Data, context: ModelContext) throws -> ImportSummary {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let payload = try decoder.decode(Payload.self, from: data)

        var summary = ImportSummary()

        let existingDotIDs = Set(((try? context.fetch(FetchDescriptor<Dot>())) ?? []).map { $0.id })
        for dto in payload.dots {
            if existingDotIDs.contains(dto.id) { summary.skippedExistingIDs += 1; continue }
            let dot = Dot(
                title: dto.title,
                eventDate: dto.eventDate,
                category: DotCategory(rawValue: dto.category) ?? .life,
                bodyText: dto.bodyText,
                tags: dto.tags,
                locationText: dto.locationText,
                referenceURLString: dto.referenceURLString
            )
            dot.id = dto.id
            dot.createdAt = dto.createdAt
            dot.updatedAt = dto.updatedAt
            context.insert(dot)
            summary.insertedDots += 1
        }

        let existingConnectionIDs = Set(((try? context.fetch(FetchDescriptor<Connection>())) ?? []).map { $0.id })
        for dto in payload.connections {
            if existingConnectionIDs.contains(dto.id) { summary.skippedExistingIDs += 1; continue }
            let connection = Connection(
                sourceDotID: dto.sourceDotID,
                targetDotID: dto.targetDotID,
                kind: ConnectionKind(rawValue: dto.kind) ?? .other,
                reason: dto.reason,
                discoveredAt: dto.discoveredAt
            )
            connection.id = dto.id
            context.insert(connection)
            summary.insertedConnections += 1
        }

        let existingConstellationIDs = Set(((try? context.fetch(FetchDescriptor<Constellation>())) ?? []).map { $0.id })
        for dto in payload.constellations {
            if existingConstellationIDs.contains(dto.id) { summary.skippedExistingIDs += 1; continue }
            let constellation = Constellation(customTitle: dto.customTitle, templateID: dto.templateID, memberDotIDs: dto.memberDotIDs)
            constellation.id = dto.id
            constellation.createdAt = dto.createdAt
            constellation.updatedAt = dto.updatedAt
            context.insert(constellation)
            summary.insertedConstellations += 1
        }

        let existingStoryIDs = Set(((try? context.fetch(FetchDescriptor<Story>())) ?? []).map { $0.id })
        for dto in payload.stories {
            if existingStoryIDs.contains(dto.id) { summary.skippedExistingIDs += 1; continue }
            let story = Story(title: dto.title, mode: StoryMode(rawValue: dto.mode) ?? .personal, bodyText: dto.bodyText, orderedDotIDs: dto.orderedDotIDs)
            story.id = dto.id
            story.createdAt = dto.createdAt
            story.updatedAt = dto.updatedAt
            context.insert(story)
            summary.insertedStories += 1
        }

        return summary
    }
}
