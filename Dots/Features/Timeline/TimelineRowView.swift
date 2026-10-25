import SwiftUI

struct TimelineRowView: View {
    let dot: Dot

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter
    }()

    var body: some View {
        HStack(alignment: .top, spacing: DotsSpacing.md) {
            VStack {
                Circle()
                    .fill(DotsCategoryColor.color(for: dot.category))
                    .frame(width: 10, height: 10)
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 2)
            }
            .frame(width: 10)

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: DotsSpacing.sm) {
                    Text(Self.dateFormatter.string(from: dot.eventDate))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(DotsColor.mutedSlate)
                    DotCategoryBadge(category: dot.category)
                }
                Text(dot.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(DotsColor.primaryText)
                if !dot.bodyText.isEmpty {
                    Text(dot.bodyText)
                        .font(.system(size: 14))
                        .foregroundStyle(DotsColor.mutedSlate)
                        .lineLimit(1)
                }
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, DotsSpacing.sm)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
    }
}
