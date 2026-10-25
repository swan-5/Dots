import SwiftUI
import SwiftData

struct StoryListView: View {
    @Query(sort: \Story.updatedAt, order: .reverse) private var stories: [Story]
    @State private var isPresentingNewStory = false

    var body: some View {
        NavigationStack {
            Group {
                if stories.isEmpty {
                    emptyState
                } else {
                    List {
                        ForEach(stories) { story in
                            NavigationLink(value: story) {
                                StoryCardRow(story: story)
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("내 이야기")
            .navigationDestination(for: Story.self) { story in
                StoryDetailView(story: story)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isPresentingNewStory = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $isPresentingNewStory) {
                StoryEditorView(mode: .create(prefilledDotIDs: []))
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: DotsSpacing.md) {
            Image(systemName: "book.closed")
                .font(.system(size: 36))
                .foregroundStyle(DotsColor.mutedSlate)
            Text("아직 만든 이야기가 없어요")
                .font(.system(size: 17, weight: .semibold))
            Text("기록한 경험들을 골라 나만의 이야기로 엮어보세요.")
                .font(.system(size: 14))
                .foregroundStyle(DotsColor.mutedSlate)
                .multilineTextAlignment(.center)
            Button("새 이야기 만들기") { isPresentingNewStory = true }
                .buttonStyle(.borderedProminent)
                .tint(DotsColor.periwinkle)
        }
        .padding(DotsSpacing.lg)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct StoryCardRow: View {
    let story: Story

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(story.title).font(.system(size: 16, weight: .semibold))
                Spacer()
                Text(story.mode.displayName)
                    .font(.system(size: 11, weight: .medium))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(DotsColor.lavender.opacity(0.25), in: Capsule())
            }
            Text("경험 \(story.orderedDotIDs.count)개")
                .font(.system(size: 13))
                .foregroundStyle(DotsColor.mutedSlate)
        }
        .padding(.vertical, DotsSpacing.xs)
    }
}
