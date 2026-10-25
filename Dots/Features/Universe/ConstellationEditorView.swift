import SwiftUI
import SwiftData

struct ConstellationEditorView: View {
    enum Mode {
        case create
        case edit(Constellation)
    }

    let mode: Mode

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var allDots: [Dot]

    @State private var title: String = ""
    @State private var selectedTemplateID: String = ConstellationCatalog.orion.id
    @State private var selectedDotIDs: Set<UUID> = []

    private var isEditing: Bool {
        if case .edit = mode { return true }
        return false
    }

    private var selectedTemplate: ConstellationTemplate {
        ConstellationCatalog.template(withID: selectedTemplateID) ?? ConstellationCatalog.orion
    }

    private var selectedDots: [Dot] {
        allDots.filter { selectedDotIDs.contains($0.id) }
    }

    private var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && selectedDotIDs.count >= 2
    }

    private var sortedAllDots: [Dot] {
        ChronologySort.sorted(allDots, direction: .newestFirst)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("별자리 이름") {
                    TextField("예: 나의 첫 도전들", text: $title)
                }

                Section("별자리 템플릿") {
                    templatePicker
                }

                if selectedDotIDs.count >= 1 {
                    Section("미리보기") {
                        ConstellationCanvasView(
                            mapping: ConstellationMapper.map(memberDots: selectedDots, template: selectedTemplate)
                        )
                        .frame(height: 220)
                        .background(DotsColor.backgroundNavy, in: RoundedRectangle(cornerRadius: DotsRadius.standard))
                        previewPolicyNote
                    }
                }

                Section("포함할 경험 선택 (2개 이상)") {
                    ForEach(sortedAllDots) { dot in
                        Button {
                            toggle(dot)
                        } label: {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(dot.title).font(.system(size: 14, weight: .medium))
                                    Text(dot.eventDate.formatted(date: .abbreviated, time: .omitted))
                                        .font(.system(size: 12))
                                        .foregroundStyle(DotsColor.mutedSlate)
                                }
                                Spacer()
                                if selectedDotIDs.contains(dot.id) {
                                    Image(systemName: "checkmark.circle.fill").foregroundStyle(DotsColor.periwinkle)
                                } else {
                                    Image(systemName: "circle").foregroundStyle(DotsColor.mutedSlate)
                                }
                            }
                        }
                        .tint(DotsColor.primaryText)
                    }
                }
            }
            .navigationTitle(isEditing ? "별자리 수정" : "별자리 만들기")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("저장") { save() }.disabled(!canSave)
                }
            }
            .onAppear(perform: loadExistingValuesIfNeeded)
        }
    }

    private var templatePicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DotsSpacing.sm) {
                ForEach(ConstellationCatalog.templates) { template in
                    Button {
                        selectedTemplateID = template.id
                    } label: {
                        VStack(spacing: 4) {
                            Text(template.koreanName).font(.system(size: 13, weight: .medium))
                            Text(template.westernName).font(.system(size: 11)).foregroundStyle(DotsColor.mutedSlate)
                        }
                        .padding(.horizontal, DotsSpacing.md)
                        .padding(.vertical, DotsSpacing.sm)
                        .background(
                            selectedTemplateID == template.id ? DotsColor.periwinkle.opacity(0.18) : Color.gray.opacity(0.08),
                            in: RoundedRectangle(cornerRadius: DotsRadius.standard)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    @ViewBuilder
    private var previewPolicyNote: some View {
        let mapping = ConstellationMapper.map(memberDots: selectedDots, template: selectedTemplate)
        if mapping.isPartial {
            Text("경험이 \(selectedDots.count)개라 별 \(mapping.unfilledAnchors.count)개는 아직 희미해요 — \"진행 중\" 상태로 표시돼요.")
                .font(.system(size: 12))
                .foregroundStyle(DotsColor.mutedSlate)
        } else if mapping.hasOverflow {
            Text("별 \(selectedTemplate.anchors.count)개를 모두 채우고, 나머지 \(mapping.overflowDots.count)개는 \"추가 경험\" 목록에 따로 표시돼요.")
                .font(.system(size: 12))
                .foregroundStyle(DotsColor.mutedSlate)
        }
    }

    private func toggle(_ dot: Dot) {
        if selectedDotIDs.contains(dot.id) {
            selectedDotIDs.remove(dot.id)
        } else {
            selectedDotIDs.insert(dot.id)
        }
    }

    private func loadExistingValuesIfNeeded() {
        guard case .edit(let constellation) = mode, title.isEmpty else { return }
        title = constellation.customTitle
        selectedTemplateID = constellation.templateID
        selectedDotIDs = Set(constellation.memberDotIDs)
    }

    private func save() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty, selectedDotIDs.count >= 2 else { return }

        let orderedMemberIDs = ChronologySort.sorted(selectedDots, direction: .oldestFirst).map { $0.id }

        switch mode {
        case .create:
            let constellation = Constellation(
                customTitle: trimmedTitle,
                templateID: selectedTemplateID,
                memberDotIDs: orderedMemberIDs
            )
            modelContext.insert(constellation)
        case .edit(let constellation):
            constellation.customTitle = trimmedTitle
            constellation.templateID = selectedTemplateID
            constellation.memberDotIDs = orderedMemberIDs
            constellation.updatedAt = .now
        }
        dismiss()
    }
}
