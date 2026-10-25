import Foundation
import SwiftData

@Model
final class Connection {
    @Attribute(.unique) var id: UUID
    var sourceDotID: UUID
    var targetDotID: UUID
    var kindRaw: String
    var reason: String
    var discoveredAt: Date

    var kind: ConnectionKind {
        get { ConnectionKind(rawValue: kindRaw) ?? .other }
        set { kindRaw = newValue.rawValue }
    }

    init(
        sourceDotID: UUID,
        targetDotID: UUID,
        kind: ConnectionKind,
        reason: String,
        discoveredAt: Date = .now
    ) {
        self.id = UUID()
        self.sourceDotID = sourceDotID
        self.targetDotID = targetDotID
        self.kindRaw = kind.rawValue
        self.reason = reason
        self.discoveredAt = discoveredAt
    }

    /// Two connections are duplicates if they share the same unordered pair of dots and the same kind.
    func isDuplicate(of other: Connection) -> Bool {
        let samePair = (sourceDotID == other.sourceDotID && targetDotID == other.targetDotID)
            || (sourceDotID == other.targetDotID && targetDotID == other.sourceDotID)
        return samePair && kindRaw == other.kindRaw
    }
}
