import SwiftUI
import SwiftData

struct ConstellationDetailView: View {
    @Bindable var constellation: Constellation

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var allDots: [Dot]

    @State private var isPresentingEditor = false
    @State private var isPresentingStoryCreation = false
    @State private var isPresentingDeleteConfirmation = false

    private var template: ConstellationTemplate {
        ConstellationCatalog.template(withID: constellation.templateID) ?? ConstellationCatalog.orion
    }

    private var members: [Dot] {
        allDots.filter { constellation.memberDotIDs.contains($0.id) }
    }

    private var mapping: ConstellationMapper.MappingResult {
        ConstellationMapper.map(memberDots: members, template: template)
    }

    private var chronologicalMembers: [Dot] {
        ChronologySort.sorted(members, direction: .oldestFirst)
    }

    var body: some View {
        ZStack {
            DotsColor.backgroundNavy.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: DotsSpacing.lg) {
                    header

                    ConstellationCanvasView(mapping: mapping) { dot in
                        navigateToDot = dot
                    }
                    .frame(height: 280)
                    .background(Color.black.opacity(0.15), in: RoundedRectangle(cornerRadius: DotsRadius.standard))

                    statusNote

                    chronologicalList

                    actionButtons
                }
                .padding(DotsSpacing.md)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button("수정", systemImage: "pencil") { isPresentingEditor = true }
                    Button("삭제", systemImage: "trash", role: .destructive) { isPresentingDeleteConfirmation = true }
                } label: {
                    Image(systemName: "ellipsis.circle").foregroundStyle(.white)
                }
            }
        }
        .sheet(isPresented: $isPresentingEditor) {
            ConstellationEditorView(mode: .edit(constellation))
        }
        .sheet(isPresented: $isPresentingStoryCreation) {
            StoryEditorView(mode: .create(prefilledDotIDs: chronologicalMembers.map { $0.id }))
        }
        .alert("별자리를 삭제할까요?", isPresented: $isPresentingDeleteConfirmation) {
            Button("삭제", role: .destructive) {
                modelContext.delete(constellation)
                dismiss()
            }
            Button("취소", role: .cancel) {}
        } message: {
            Text("포함된 경험들은 삭제되지 않아요. 별자리 그룹만 사라져요.")
        }
        .navigationDestination(item: $navigateToDot) { dot in
            DotDetailView(dot: dot)
        }
        .preferredColorScheme(.dark)
    }

    @State private var navigateToDot: Dot?

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(constellation.customTitle)
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(.white)
            Text("\(template.koreanName) · \(template.westernName)")
                .font(.system(size: 13))
                .foregroundStyle(DotsColor.mutedSlate)
        }
    }

    @ViewBuilder
    private var statusNote: some View {
        if mapping.isPartial {
            Text("별 \(mapping.assignments.count)/\(template.anchors.count) · 진행 중인 별자리예요.")
                .font(.system(size: 12))
                .foregroundStyle(DotsColor.lavender)
        } else if mapping.hasOverflow {
            Text("별 \(template.anchors.count)개를 모두 채웠고, 추가 경험 \(mapping.overflowDots.count)개는 아래 목록에 함께 있어요.")
                .font(.system(size: 12))
                .foregroundStyle(DotsColor.lavender)
        }
    }

    private var chronologicalList: some View {
        VStack(alignment: .leading, spacing: DotsSpacing.sm) {
            Text("시간순 구성 경험")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.white)
            ForEach(Array(chronologicalMembers.enumerated()), id: \.element.id) { index, dot in
                Button {
                    navigateToDot = dot
                } label: {
                    HStack(alignment: .top, spacing: DotsSpacing.sm) {
                        Text("\(index + 1)")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(DotsColor.mutedSlate)
                            .frame(width: 18, alignment: .trailing)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(dot.title)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(.white)
                            Text(dot.eventDate.formatted(date: .abbreviated, time: .omitted))
                                .font(.system(size: 12))
                                .foregroundStyle(DotsColor.mutedSlate)
                        }
                        Spacer()
                    }
                }
                .buttonStyle(.plain)
                .accessibilityElement(children: .combine)
            }
        }
    }

    private var actionButtons: some View {
        Button {
            isPresentingStoryCreation = true
        } label: {
            Label("이 별자리로 이야기 만들기", systemImage: "book")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
        .tint(DotsColor.periwinkle)
        .foregroundStyle(.white)
    }
}
