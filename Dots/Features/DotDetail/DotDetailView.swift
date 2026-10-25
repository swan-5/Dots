import SwiftUI
import SwiftData
import UIKit

struct DotDetailView: View {
    @Bindable var dot: Dot

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query private var allConnections: [Connection]
    @Query private var allDots: [Dot]

    @State private var isPresentingEditor = false
    @State private var isPresentingDeleteConfirmation = false

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 M월 d일"
        return formatter
    }()

    private var relatedConnections: [(connection: Connection, otherDot: Dot)] {
        allConnections
            .filter { $0.sourceDotID == dot.id || $0.targetDotID == dot.id }
            .compactMap { connection in
                let otherID = connection.sourceDotID == dot.id ? connection.targetDotID : connection.sourceDotID
                guard let other = allDots.first(where: { $0.id == otherID }) else { return nil }
                return (connection, other)
            }
            .sorted { $0.connection.discoveredAt > $1.connection.discoveredAt }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DotsSpacing.lg) {
                header

                if let imageData = dot.imageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: DotsRadius.standard))
                }

                if !dot.bodyText.isEmpty {
                    Text(dot.bodyText)
                        .font(.system(size: 15))
                        .foregroundStyle(DotsColor.primaryText)
                }

                if !dot.tags.isEmpty {
                    tagRow
                }

                if !dot.locationText.isEmpty {
                    Label(dot.locationText, systemImage: "mappin.and.ellipse")
                        .font(.system(size: 13))
                        .foregroundStyle(DotsColor.mutedSlate)
                }

                if !dot.referenceURLString.isEmpty, let url = URL(string: dot.referenceURLString) {
                    Link(destination: url) {
                        Label(dot.referenceURLString, systemImage: "link")
                            .font(.system(size: 13))
                    }
                }

                Divider()

                connectedSection

                Button {
                    NotificationCenter.default.post(name: .dotsRequestConnectFromDetail, object: dot.id)
                } label: {
                    Label("다른 경험과 연결하기", systemImage: "link.badge.plus")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(DotsColor.periwinkle)
            }
            .padding(DotsSpacing.md)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button("수정", systemImage: "pencil") { isPresentingEditor = true }
                    Button("삭제", systemImage: "trash", role: .destructive) { isPresentingDeleteConfirmation = true }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $isPresentingEditor) {
            DotEditorView(mode: .edit(dot))
        }
        .alert("삭제하면 되돌릴 수 없어요", isPresented: $isPresentingDeleteConfirmation) {
            Button("삭제", role: .destructive) {
                DeletionService.deleteDot(dot, context: modelContext)
                dismiss()
            }
            Button("취소", role: .cancel) {}
        } message: {
            Text(deletionImpactMessage)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: DotsSpacing.sm) {
            Text(Self.dateFormatter.string(from: dot.eventDate))
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(DotsColor.mutedSlate)
            Text(dot.title)
                .font(.system(size: 26, weight: .semibold))
                .foregroundStyle(DotsColor.primaryText)
            DotCategoryBadge(category: dot.category)
        }
    }

    private var tagRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(dot.tags, id: \.self) { tag in
                    Text("#\(tag)")
                        .font(.system(size: 12))
                        .foregroundStyle(DotsColor.periwinkle)
                }
            }
        }
    }

    private var connectedSection: some View {
        VStack(alignment: .leading, spacing: DotsSpacing.sm) {
            Text("연결된 경험")
                .font(.system(size: 15, weight: .semibold))
            if relatedConnections.isEmpty {
                Text("아직 연결된 경험이 없어요.")
                    .font(.system(size: 13))
                    .foregroundStyle(DotsColor.mutedSlate)
            } else {
                ForEach(relatedConnections, id: \.connection.id) { pair in
                    NavigationLink(value: pair.otherDot) {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(pair.otherDot.title)
                                    .font(.system(size: 14, weight: .medium))
                                Text(pair.connection.kind.displayName)
                                    .font(.system(size: 12))
                                    .foregroundStyle(DotsColor.mutedSlate)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12))
                                .foregroundStyle(DotsColor.mutedSlate)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var deletionImpactMessage: String {
        let impact = DeletionService.impact(ofDeleting: dot, context: modelContext)
        if impact.isEmpty {
            return "연결된 기록이 없어요. 이 경험을 삭제할까요?"
        }
        var lines: [String] = []
        if impact.connectionCount > 0 { lines.append("연결 \(impact.connectionCount)개") }
        if !impact.constellationTitles.isEmpty { lines.append("별자리: \(impact.constellationTitles.joined(separator: ", "))") }
        if !impact.storyTitles.isEmpty { lines.append("이야기: \(impact.storyTitles.joined(separator: ", "))") }
        return "이 경험과 연결된 \(lines.joined(separator: " · "))에서도 함께 제거돼요."
    }
}
