import Foundation

/// Pure, testable mapping between a set of member Dots and a constellation template's
/// anchor stars. Encodes the cardinality policy described in the PRD:
///
/// - N == template anchor count: every anchor is filled, no placeholders, no overflow.
/// - N < template anchor count: fill the N *most prominent* anchors (deterministic),
///   assigning dots in chronological order to anchors in prominence order (earliest dot
///   -> brightest star). Remaining anchors are returned as dim, unassigned placeholders
///   and the whole constellation is marked `isPartial` ("진행 중" / "In progress").
/// - N > template anchor count: fill every anchor (chronological order -> prominence
///   order) and return the chronologically-earliest overflow dots in a separate,
///   clearly-labeled "추가 경험" (Additional experiences) list. Nothing is silently
///   dropped or overlapped.
enum ConstellationMapper {

    struct AssignedAnchor: Identifiable {
        var id: String { anchor.id }
        let anchor: ConstellationStarAnchor
        let dot: Dot
    }

    struct MappingResult {
        let template: ConstellationTemplate
        let assignments: [AssignedAnchor]
        let unfilledAnchors: [ConstellationStarAnchor]
        let overflowDots: [Dot]
        var isPartial: Bool { !unfilledAnchors.isEmpty }
        var hasOverflow: Bool { !overflowDots.isEmpty }
    }

    static func map(memberDots: [Dot], template: ConstellationTemplate) -> MappingResult {
        let chronological = ChronologySort.sorted(memberDots, direction: .oldestFirst)
        let anchorsByProminence = template.anchorsByProminence
        let fillCount = min(chronological.count, anchorsByProminence.count)

        var assignments: [AssignedAnchor] = []
        for index in 0..<fillCount {
            assignments.append(AssignedAnchor(anchor: anchorsByProminence[index], dot: chronological[index]))
        }

        let unfilledAnchors = Array(anchorsByProminence.dropFirst(fillCount))
        let overflowDots = chronological.count > fillCount ? Array(chronological.dropFirst(fillCount)) : []

        return MappingResult(
            template: template,
            assignments: assignments,
            unfilledAnchors: unfilledAnchors,
            overflowDots: overflowDots
        )
    }
}
