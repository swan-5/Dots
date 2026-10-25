import Foundation

enum TimelineCategoryFilter: String, CaseIterable, Identifiable {
    case all, life, career, both

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all: return "전체"
        case .life: return "일상"
        case .career: return "커리어"
        case .both: return "둘 다"
        }
    }

    func matches(_ dot: Dot) -> Bool {
        switch self {
        case .all: return true
        case .life: return dot.category == .life
        case .career: return dot.category == .career
        case .both: return dot.category == .both
        }
    }
}
