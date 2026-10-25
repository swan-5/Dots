import Foundation
import SwiftData

@Model
final class Dot {
    @Attribute(.unique) var id: UUID
    var title: String
    var eventDate: Date
    var createdAt: Date
    var updatedAt: Date
    var categoryRaw: String
    var bodyText: String
    var tags: [String]
    var locationText: String
    var referenceURLString: String
    @Attribute(.externalStorage) var imageData: Data?

    var category: DotCategory {
        get { DotCategory(rawValue: categoryRaw) ?? .life }
        set { categoryRaw = newValue.rawValue }
    }

    init(
        title: String,
        eventDate: Date,
        category: DotCategory = .life,
        bodyText: String = "",
        tags: [String] = [],
        locationText: String = "",
        referenceURLString: String = "",
        imageData: Data? = nil
    ) {
        self.id = UUID()
        self.title = title
        self.eventDate = eventDate
        self.createdAt = .now
        self.updatedAt = .now
        self.categoryRaw = category.rawValue
        self.bodyText = bodyText
        self.tags = tags
        self.locationText = locationText
        self.referenceURLString = referenceURLString
        self.imageData = imageData
    }
}
