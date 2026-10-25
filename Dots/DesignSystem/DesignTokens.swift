import SwiftUI

/// Visual design tokens. Keep this the single source of truth for color/type/spacing
/// so screens stay restrained and consistent per the PRD's "beautiful but restrained" rule.
enum DotsColor {
    static let primaryNavy = Color(hex: "0F172A")
    static let backgroundNavy = Color(hex: "101827")
    static let periwinkle = Color(hex: "6366F1")
    static let lavender = Color(hex: "A78BFA")
    static let softBlush = Color(hex: "F9D1D1")
    static let offWhite = Color(hex: "F8F7FA")
    static let primaryText = Color(hex: "172034")
    static let mutedSlate = Color(hex: "8995AA")
    static let connector = Color(hex: "A78BFA").opacity(0.45)
}

enum DotsSpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
}

enum DotsRadius {
    static let standard: CGFloat = 14
}

enum DotsCategoryColor {
    static func color(for category: DotCategory) -> Color {
        switch category {
        case .life: return DotsColor.softBlush
        case .career: return DotsColor.periwinkle
        case .both: return DotsColor.lavender
        }
    }
}

extension Color {
    init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        let r = Double((rgb & 0xFF0000) >> 16) / 255.0
        let g = Double((rgb & 0x00FF00) >> 8) / 255.0
        let b = Double(rgb & 0x0000FF) / 255.0
        self = Color(red: r, green: g, blue: b)
    }
}
