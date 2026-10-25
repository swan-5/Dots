import Foundation
import SwiftData

@Model
final class Story {
    @Attribute(.unique) var id: UUID
    var title: String
    var modeRaw: String
    var bodyText: String
    var orderedDotIDs: [UUID]
    var createdAt: Date
    var updatedAt: Date

    var mode: StoryMode {
        get { StoryMode(rawValue: modeRaw) ?? .personal }
        set { modeRaw = newValue.rawValue }
    }

    init(
        title: String,
        mode: StoryMode,
        bodyText: String = "",
        orderedDotIDs: [UUID] = []
    ) {
        self.id = UUID()
        self.title = title
        self.modeRaw = mode.rawValue
        self.bodyText = bodyText
        self.orderedDotIDs = orderedDotIDs
        self.createdAt = .now
        self.updatedAt = .now
    }
}
