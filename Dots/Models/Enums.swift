import Foundation

enum DotCategory: String, Codable, CaseIterable, Identifiable {
    case life, career, both

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .life: return "일상"
        case .career: return "커리어"
        case .both: return "둘 다"
        }
    }

    var symbolName: String {
        switch self {
        case .life: return "leaf"
        case .career: return "briefcase"
        case .both: return "circle.grid.cross"
        }
    }
}

enum ConnectionKind: String, Codable, CaseIterable, Identifiable {
    case inspiredBy, learnedFrom, ledTo, builtUpon, unexpected, other

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .inspiredBy: return "영감을 줌"
        case .learnedFrom: return "배운 점"
        case .ledTo: return "이어짐"
        case .builtUpon: return "발전시킴"
        case .unexpected: return "예상치 못한 연결"
        case .other: return "기타"
        }
    }
}

enum StoryMode: String, Codable, CaseIterable, Identifiable {
    case personal, career

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .personal: return "개인 이야기"
        case .career: return "커리어 이야기"
        }
    }
}
