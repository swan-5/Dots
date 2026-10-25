import Foundation

/// A single named star within a constellation template.
/// `prominence` is a 1-based rank (1 = most prominent/brightest), used to deterministically
/// decide which anchors are used first when a Dot group is smaller than the full template.
struct ConstellationStarAnchor: Identifiable, Codable, Hashable {
    let id: String
    let starName: String
    /// Normalized position in 0...1 space, top-left origin, matching SwiftUI canvas coordinates.
    let x: Double
    let y: Double
    let prominence: Int
}

/// A line segment between two anchors, drawn in the reference asterism.
struct ConstellationLine: Codable, Hashable {
    let fromAnchorID: String
    let toAnchorID: String
}

/// A bundled, curated real constellation template.
struct ConstellationTemplate: Identifiable, Codable, Hashable {
    let id: String
    let westernName: String
    let koreanName: String
    let anchors: [ConstellationStarAnchor]
    let lines: [ConstellationLine]
    let attribution: String

    /// Anchors ordered by prominence (brightest first) — the deterministic fill order.
    var anchorsByProminence: [ConstellationStarAnchor] {
        anchors.sorted { $0.prominence < $1.prominence }
    }

    func anchor(withID id: String) -> ConstellationStarAnchor? {
        anchors.first { $0.id == id }
    }
}
