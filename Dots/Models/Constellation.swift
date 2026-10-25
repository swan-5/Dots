import Foundation
import SwiftData

@Model
final class Constellation {
    @Attribute(.unique) var id: UUID
    var customTitle: String
    var templateID: String
    var createdAt: Date
    var updatedAt: Date
    /// Ordered membership; order here is selection order, NOT chronology.
    var memberDotIDs: [UUID]
    /// Explicit anchor assignment version so mapping doesn't silently reshuffle as members change.
    var mappingVersion: Int

    init(
        customTitle: String,
        templateID: String,
        memberDotIDs: [UUID]
    ) {
        self.id = UUID()
        self.customTitle = customTitle
        self.templateID = templateID
        self.createdAt = .now
        self.updatedAt = .now
        self.memberDotIDs = memberDotIDs
        self.mappingVersion = 1
    }
}
