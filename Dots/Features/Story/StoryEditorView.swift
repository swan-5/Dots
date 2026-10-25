import SwiftUI
import SwiftData

struct StoryEditorView: View {
    enum Mode {
        case create(prefilledDotIDs: [UUID])
        case edit(Story)
    }

    let mode: Mode

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var allDots: [Dot]

    @State private var title: String = ""
    @State private var storyMode: StoryMode = .personal
    @State private var bodyText: String = ""
    @State private var orderedDotIDs: [UUID] = []
    @State private var isPickingDots = false

    private var isEditing: Bool {
        if case .edit = mode { return true }
        return false
    }

    private var orderedDots: [Dot] {
        orderedDotIDs.compactMap { id in allDots.first { $0.id == id } }
    }

    private var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !orderedDotIDs.isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("이야기 제목") {
                    TextField("예: 대학 생활 돌아보기", text: $title)
                    Picker("종류", selection: $storyMode) {
                        ForEach(StoryMode.allCases) { mode in
                            Text(mode.displayName).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section {
                    TextField("이야기를 적어보세요", text: $bodyText, axis: .vertical)
                        .lineLimit(6...12)
                } header: {
                    Text("내용")
                } footer: {
                    if storyMode == .career {
                        Text("커리어 이야기는 보여주는 방식일 뿐, 원본 기록은 바뀌지 않아요.")
                    }
                }

                Section("포함된 경험 (\(orderedDotIDs.count)개)") {
                    ForEach(orderedDots) { dot in
                        Text(dot.title)
                    }
                    .onMove(perform: move)
                    .onDelete(perform: remove)
                    Button("경험 추가/변경") { isPickingDots = true }
                }
            }
            .navigationTitle(isEditing ? "이야기 수정" : "새 이야기")
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
            .sheet(isPresented: $isPickingDots) {
                StoryDotPickerView(selectedDotIDs: $orderedDotIDs, allDots: allDots)
            }
        }
    }

    private func move(from source: IndexSet, to destination: Int) {
        orderedDotIDs.move(fromOffsets: source, toOffset: destination)
    }

    private func remove(at offsets: IndexSet) {
        orderedDotIDs.remove(atOffsets: offsets)
    }

    private func loadExistingValuesIfNeeded() {
        switch mode {
        case .create(let prefilledDotIDs):
            if orderedDotIDs.isEmpty { orderedDotIDs = prefilledDotIDs }
        case .edit(let story):
            guard title.isEmpty else { return }
            title = story.title
            storyMode = story.mode
            bodyText = story.bodyText
            orderedDotIDs = story.orderedDotIDs
        }
    }

    private func save() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty, !orderedDotIDs.isEmpty else { return }

        switch mode {
        case .create:
            let story = Story(title: trimmedTitle, mode: storyMode, bodyText: bodyText, orderedDotIDs: orderedDotIDs)
            modelContext.insert(story)
        case .edit(let story):
            story.title = trimmedTitle
            story.mode = storyMode
            story.bodyText = bodyText
            story.orderedDotIDs = orderedDotIDs
            story.updatedAt = .now
        }
        dismiss()
    }
}

private struct StoryDotPickerView: View {
    @Binding var selectedDotIDs: [UUID]
    let allDots: [Dot]
    @Environment(\.dismiss) private var dismiss

    private var sortedDots: [Dot] {
        ChronologySort.sorted(allDots, direction: .newestFirst)
    }

    var body: some View {
        NavigationStack {
            List(sortedDots) { dot in
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
            .navigationTitle("경험 선택")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("완료") { dismiss() }
                }
            }
        }
    }

    private func toggle(_ dot: Dot) {
        if let index = selectedDotIDs.firstIndex(of: dot.id) {
            selectedDotIDs.remove(at: index)
        } else {
            selectedDotIDs.append(dot.id)
        }
    }
}
