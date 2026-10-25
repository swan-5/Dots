import SwiftUI
import SwiftData

struct StoryDetailView: View {
    @Bindable var story: Story

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var allDots: [Dot]

    @State private var isPresentingEditor = false
    @State private var isPresentingDeleteConfirmation = false
    @State private var navigateToDot: Dot?

    private var orderedDots: [Dot] {
        story.orderedDotIDs.compactMap { id in allDots.first { $0.id == id } }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DotsSpacing.lg) {
                Text(story.title)
                    .font(.system(size: 24, weight: .semibold))
                Text(story.mode.displayName)
                    .font(.system(size: 12, weight: .medium))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(DotsColor.lavender.opacity(0.25), in: Capsule())

                if !story.bodyText.isEmpty {
                    Text(story.bodyText)
                        .font(.system(size: 15))
                }

                Divider()

                Text("포함된 경험")
                    .font(.system(size: 15, weight: .semibold))
                ForEach(Array(orderedDots.enumerated()), id: \.element.id) { index, dot in
                    Button { navigateToDot = dot } label: {
                        HStack(alignment: .top, spacing: DotsSpacing.sm) {
                            Text("\(index + 1)").font(.system(size: 12, weight: .semibold)).foregroundStyle(DotsColor.mutedSlate)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(dot.title).font(.system(size: 14, weight: .medium)).foregroundStyle(DotsColor.primaryText)
                                Text(dot.eventDate.formatted(date: .abbreviated, time: .omitted))
                                    .font(.system(size: 12))
                                    .foregroundStyle(DotsColor.mutedSlate)
                            }
                            Spacer()
                        }
                    }
                    .buttonStyle(.plain)
                }

                ShareLink(item: shareText) {
                    Label("텍스트로 공유", systemImage: "square.and.arrow.up")
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
            StoryEditorView(mode: .edit(story))
        }
        .alert("이야기를 삭제할까요?", isPresented: $isPresentingDeleteConfirmation) {
            Button("삭제", role: .destructive) {
                modelContext.delete(story)
                dismiss()
            }
            Button("취소", role: .cancel) {}
        } message: {
            Text("포함된 경험들은 삭제되지 않아요.")
        }
        .navigationDestination(item: $navigateToDot) { dot in
            DotDetailView(dot: dot)
        }
    }

    private var shareText: String {
        var lines = [story.title, ""]
        if !story.bodyText.isEmpty { lines.append(story.bodyText); lines.append("") }
        for (index, dot) in orderedDots.enumerated() {
            lines.append("\(index + 1). \(dot.title) (\(dot.eventDate.formatted(date: .abbreviated, time: .omitted)))")
        }
        return lines.joined(separator: "\n")
    }
}
