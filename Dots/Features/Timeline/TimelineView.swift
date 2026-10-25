import SwiftUI
import SwiftData

struct TimelineView: View {
    @Query private var allDots: [Dot]
    @Environment(\.modelContext) private var modelContext

    @State private var searchText = ""
    @State private var categoryFilter: TimelineCategoryFilter = .all
    @State private var sortDirection: ChronologySort.Direction = .newestFirst
    @State private var isPresentingNewDot = false

    private var filteredDots: [Dot] {
        allDots.filter { dot in
            categoryFilter.matches(dot)
                && (searchText.isEmpty
                    || dot.title.localizedCaseInsensitiveContains(searchText)
                    || dot.bodyText.localizedCaseInsensitiveContains(searchText)
                    || dot.tags.contains { $0.localizedCaseInsensitiveContains(searchText) })
        }
    }

    private var sortedDots: [Dot] {
        ChronologySort.sorted(filteredDots, direction: sortDirection)
    }

    private var monthGroups: [ChronologySort.MonthGroup] {
        ChronologySort.groupedByMonth(sortedDots)
    }

    var body: some View {
        NavigationStack {
            Group {
                if allDots.isEmpty {
                    emptyState
                } else {
                    List {
                        ForEach(monthGroups) { group in
                            Section(header: Text(sectionTitle(for: group))) {
                                ForEach(group.dots) { dot in
                                    NavigationLink(value: dot) {
                                        TimelineRowView(dot: dot)
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                    .searchable(text: $searchText, prompt: "제목, 내용, 태그 검색")
                }
            }
            .navigationTitle("타임라인")
            .navigationDestination(for: Dot.self) { dot in
                DotDetailView(dot: dot)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        sortDirection = sortDirection == .newestFirst ? .oldestFirst : .newestFirst
                    } label: {
                        Label(
                            sortDirection == .newestFirst ? "최신순" : "오래된순",
                            systemImage: sortDirection == .newestFirst ? "arrow.down" : "arrow.up"
                        )
                    }
                }
            }
            .safeAreaInset(edge: .top, spacing: 0) {
                if !allDots.isEmpty {
                    categoryChipRow
                }
            }
            .floatingAddButton { isPresentingNewDot = true }
            .sheet(isPresented: $isPresentingNewDot) {
                DotEditorView(mode: .create)
            }
        }
    }

    private var categoryChipRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DotsSpacing.sm) {
                ForEach(TimelineCategoryFilter.allCases) { filter in
                    CategoryFilterChip(
                        title: filter.title,
                        isSelected: categoryFilter == filter,
                        action: { categoryFilter = filter }
                    )
                }
            }
            .padding(.horizontal, DotsSpacing.md)
            .padding(.vertical, DotsSpacing.sm)
        }
        .background(.bar)
    }

    private var emptyState: some View {
        VStack(spacing: DotsSpacing.md) {
            Image(systemName: "sparkle")
                .font(.system(size: 36))
                .foregroundStyle(DotsColor.mutedSlate)
            Text("아직 기록된 경험이 없어요")
                .font(.system(size: 17, weight: .semibold))
            Text("작은 경험 하나부터 적어보세요.\n나중에 서로 연결해 별자리로 만들 수 있어요.")
                .font(.system(size: 14))
                .foregroundStyle(DotsColor.mutedSlate)
                .multilineTextAlignment(.center)
            Button("첫 경험 기록하기") { isPresentingNewDot = true }
                .buttonStyle(.borderedProminent)
                .tint(DotsColor.periwinkle)
        }
        .padding(DotsSpacing.lg)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func sectionTitle(for group: ChronologySort.MonthGroup) -> String {
        "\(group.year)년 \(group.month)월"
    }
}
