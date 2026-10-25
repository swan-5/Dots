import SwiftUI
import SwiftData

/// S04 connection-creation workflow: source -> destination -> optional kind -> required reason -> save.
struct ConnectionPickerView: View {
    let preselectedSourceID: UUID?

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var allDots: [Dot]
    @Query private var allConnections: [Connection]

    @State private var sourceDot: Dot?
    @State private var destinationDot: Dot?
    @State private var kind: ConnectionKind = .other
    @State private var reason: String = ""
    @State private var didJustSave = false
    @State private var duplicateWarning: String?

    private enum Step { case source, destination, detail }
    @State private var step: Step = .source

    private var sortedDots: [Dot] {
        ChronologySort.sorted(allDots, direction: .newestFirst)
    }

    var body: some View {
        NavigationStack {
            Group {
                switch step {
                case .source: sourcePicker
                case .destination: destinationPicker
                case .detail: detailForm
                }
            }
            .navigationTitle("경험 연결하기")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") { dismiss() }
                }
            }
        }
        .onAppear {
            if let preselectedSourceID, let dot = allDots.first(where: { $0.id == preselectedSourceID }) {
                sourceDot = dot
                step = .destination
            }
        }
    }

    private var sourcePicker: some View {
        List {
            Section("먼저, 어떤 경험에서 시작할까요?") {
                ForEach(sortedDots) { dot in
                    Button {
                        sourceDot = dot
                        step = .destination
                    } label: {
                        dotRow(dot)
                    }
                }
            }
        }
    }

    private var destinationPicker: some View {
        List {
            if let sourceDot {
                Section {
                    dotRow(sourceDot).opacity(0.5)
                } header: {
                    Text("시작 경험")
                }
            }
            Section("어떤 경험과 연결할까요?") {
                ForEach(sortedDots.filter { $0.id != sourceDot?.id }) { dot in
                    Button {
                        destinationDot = dot
                        step = .detail
                    } label: {
                        dotRow(dot)
                    }
                }
            }
        }
    }

    private var detailForm: some View {
        Form {
            if let sourceDot, let destinationDot {
                Section("연결") {
                    HStack {
                        Text(sourceDot.title).lineLimit(1)
                        Image(systemName: "arrow.right")
                        Text(destinationDot.title).lineLimit(1)
                    }
                    .font(.system(size: 13))
                }
            }

            Section("관계 (선택)") {
                Picker("관계 유형", selection: $kind) {
                    ForEach(ConnectionKind.allCases) { kind in
                        Text(kind.displayName).tag(kind)
                    }
                }
            }

            Section("왜 연결되나요? (필수)") {
                TextField("이 연결이 의미있는 이유를 짧게 적어주세요", text: $reason, axis: .vertical)
                    .lineLimit(2...5)
            }

            if let duplicateWarning {
                Section {
                    Text(duplicateWarning)
                        .font(.system(size: 12))
                        .foregroundStyle(.orange)
                }
            }

            Section {
                Button("연결 저장하기") { save() }
                    .disabled(reason.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .overlay {
            if didJustSave {
                ConnectionSavedOverlay()
            }
        }
    }

    private func dotRow(_ dot: Dot) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text(dot.title).font(.system(size: 15, weight: .medium))
                Text(dot.eventDate.formatted(date: .abbreviated, time: .omitted))
                    .font(.system(size: 12))
                    .foregroundStyle(DotsColor.mutedSlate)
            }
            Spacer()
        }
    }

    private func save() {
        guard let sourceDot, let destinationDot else { return }
        let trimmedReason = reason.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedReason.isEmpty else { return }

        let candidate = Connection(
            sourceDotID: sourceDot.id,
            targetDotID: destinationDot.id,
            kind: kind,
            reason: trimmedReason
        )

        if allConnections.contains(where: { $0.isDuplicate(of: candidate) }) {
            duplicateWarning = "이미 같은 종류로 연결된 경험이에요. 그래도 다시 저장하지는 않을게요."
            return
        }

        modelContext.insert(candidate)
        didJustSave = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            dismiss()
        }
    }
}

private struct ConnectionSavedOverlay: View {
    @State private var animateIn = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(spacing: DotsSpacing.sm) {
            ZStack {
                Circle().fill(DotsColor.periwinkle.opacity(0.15)).frame(width: 64, height: 64)
                Image(systemName: "checkmark")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(DotsColor.periwinkle)
            }
            .scaleEffect(animateIn ? 1 : 0.6)
            .opacity(animateIn ? 1 : 0)
            Text("연결되었어요")
                .font(.system(size: 14, weight: .medium))
        }
        .padding(DotsSpacing.lg)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: DotsRadius.standard))
        .onAppear {
            withAnimation(.spring(response: reduceMotion ? 0 : 0.4, dampingFraction: 0.8)) {
                animateIn = true
            }
        }
    }
}
