import Foundation
import SwiftData

/// Future-ready model (not exposed in MVP UI per PRD S03): lets a Dot be revisited later
/// with a dated reflection alongside the original entry, without changing the original.
@Model
final class Reflection {
    @Attribute(.unique) var id: UUID
    var dotID: UUID
    var text: String
    var reflectedAt: Date

    init(dotID: UUID, text: String, reflectedAt: Date = .now) {
        self.id = UUID()
        self.dotID = dotID
        self.text = text
        self.reflectedAt = reflectedAt
    }
}
