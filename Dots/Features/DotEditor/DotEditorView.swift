import SwiftUI
import SwiftData
import PhotosUI
import UIKit

struct DotEditorView: View {
    enum Mode {
        case create
        case edit(Dot)
    }

    let mode: Mode

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var title: String = ""
    @State private var eventDate: Date = .now
    @State private var category: DotCategory = .life
    @State private var bodyText: String = ""
    @State private var tagsText: String = ""
    @State private var locationText: String = ""
    @State private var referenceURLString: String = ""
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var imageData: Data?

    @State private var isPresentingDeleteConfirmation = false

    private var isEditing: Bool {
        if case .edit = mode { return true }
        return false
    }

    private var navigationTitle: String {
        isEditing ? "경험 수정" : "새 경험 기록"
    }

    private var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                basicInfoSection
                categorySection
                descriptionSection
                additionalInfoSection
                if isEditing {
                    deleteSection
                }
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("저장") { save() }
                        .disabled(!canSave)
                }
            }
            .onAppear(perform: loadExistingValuesIfNeeded)
            .onChange(of: selectedPhotoItem) { _, newItem in
                Task {
                    if let newItem, let data = try? await newItem.loadTransferable(type: Data.self) {
                        imageData = data
                    }
                }
            }
            .alert("삭제하면 되돌릴 수 없어요", isPresented: $isPresentingDeleteConfirmation) {
                Button("삭제", role: .destructive) { deleteAndDismiss() }
                Button("취소", role: .cancel) {}
            } message: {
                if case .edit(let dot) = mode {
                    let impact = DeletionService.impact(ofDeleting: dot, context: modelContext)
                    if impact.isEmpty {
                        Text("연결된 기록이 없어요. 이 경험을 삭제할까요?")
                    } else {
                        Text(deletionImpactMessage(impact))
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var basicInfoSection: some View {
        Section {
            TextField("제목 (예: 첫 인턴십 시작)", text: $title)
            DatePicker("날짜", selection: $eventDate, displayedComponents: .date)
        }
    }

    @ViewBuilder
    private var categorySection: some View {
        Section("분류") {
            Picker("카테고리", selection: $category) {
                ForEach(DotCategory.allCases) { cat in
                    Text(cat.displayName).tag(cat)
                }
            }
            .pickerStyle(.segmented)
        }
    }

    @ViewBuilder
    private var descriptionSection: some View {
        Section("설명") {
            TextField("무슨 일이 있었나요? (선택)", text: $bodyText, axis: .vertical)
                .lineLimit(3...8)
            TextField("태그 (쉼표로 구분, 선택)", text: $tagsText)
        }
    }

    @ViewBuilder
    private var additionalInfoSection: some View {
        Section("추가 정보 (선택)") {
            TextField("장소", text: $locationText)
            TextField("관련 링크 (URL)", text: $referenceURLString)
                .keyboardType(.URL)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)

            PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                Label(imageData == nil ? "사진 추가" : "사진 변경", systemImage: "photo")
            }
            if let currentImageData = imageData, let uiImage = UIImage(data: currentImageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 160)
                    .clipShape(RoundedRectangle(cornerRadius: DotsRadius.standard))
                Button("사진 삭제", role: .destructive) { imageData = nil }
            }
        }
    }

    @ViewBuilder
    private var deleteSection: some View {
        Section {
            Button("이 경험 삭제", role: .destructive) {
                isPresentingDeleteConfirmation = true
            }
        }
    }

    private func deletionImpactMessage(_ impact: DeletionService.ImpactSummary) -> String {
        var lines: [String] = []
        if impact.connectionCount > 0 {
            lines.append("연결 \(impact.connectionCount)개")
        }
        if !impact.constellationTitles.isEmpty {
            lines.append("별자리: \(impact.constellationTitles.joined(separator: ", "))")
        }
        if !impact.storyTitles.isEmpty {
            lines.append("이야기: \(impact.storyTitles.joined(separator: ", "))")
        }
        return "이 경험과 연결된 \(lines.joined(separator: " · "))에서도 함께 제거돼요."
    }

    private func loadExistingValuesIfNeeded() {
        guard case .edit(let dot) = mode, title.isEmpty else { return }
        title = dot.title
        eventDate = dot.eventDate
        category = dot.category
        bodyText = dot.bodyText
        tagsText = dot.tags.joined(separator: ", ")
        locationText = dot.locationText
        referenceURLString = dot.referenceURLString
        imageData = dot.imageData
    }

    private func parsedTags() -> [String] {
        tagsText
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    private func save() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }

        switch mode {
        case .create:
            let dot = Dot(
                title: trimmedTitle,
                eventDate: eventDate,
                category: category,
                bodyText: bodyText,
                tags: parsedTags(),
                locationText: locationText,
                referenceURLString: referenceURLString,
                imageData: imageData
            )
            modelContext.insert(dot)
        case .edit(let dot):
            dot.title = trimmedTitle
            dot.eventDate = eventDate
            dot.category = category
            dot.bodyText = bodyText
            dot.tags = parsedTags()
            dot.locationText = locationText
            dot.referenceURLString = referenceURLString
            dot.imageData = imageData
            dot.updatedAt = .now
        }
        dismiss()
    }

    private func deleteAndDismiss() {
        guard case .edit(let dot) = mode else { return }
        DeletionService.deleteDot(dot, context: modelContext)
        dismiss()
    }
}
