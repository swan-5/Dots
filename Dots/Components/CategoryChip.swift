import SwiftUI

struct CategoryFilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .padding(.horizontal, DotsSpacing.md)
                .padding(.vertical, 6)
                .background(isSelected ? DotsColor.periwinkle : Color.gray.opacity(0.12), in: Capsule())
                .foregroundStyle(isSelected ? .white : DotsColor.primaryText)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}

struct DotCategoryBadge: View {
    let category: DotCategory

    var body: some View {
        Text(category.displayName)
            .font(.system(size: 11, weight: .semibold))
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(DotsCategoryColor.color(for: category).opacity(0.35), in: Capsule())
            .foregroundStyle(DotsColor.primaryText)
    }
}
