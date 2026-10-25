import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct ProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("dots.appearance") private var appearanceRaw = AppAppearance.system.rawValue

    @State private var exportFileURL: URL?
    @State private var isPresentingImporter = false
    @State private var importResultMessage: String?
    @State private var isPresentingDeleteAllConfirmation = false
    @State private var isPresentingAbout = false

    var body: some View {
        NavigationStack {
            Form {
                Section("모양") {
                    Picker("테마", selection: $appearanceRaw) {
                        ForEach(AppAppearance.allCases) { appearance in
                            Text(appearance.displayName).tag(appearance.rawValue)
                        }
                    }
                }

                Section {
                    Button {
                        prepareExport()
                    } label: {
                        Label("데이터 내보내기 (JSON)", systemImage: "square.and.arrow.up")
                    }
                    if let exportFileURL {
                        ShareLink(item: exportFileURL) {
                            Label("내보낸 파일 공유", systemImage: "square.and.arrow.up.on.square")
                        }
                    }
                    Button {
                        isPresentingImporter = true
                    } label: {
                        Label("데이터 가져오기 (JSON)", systemImage: "square.and.arrow.down")
                    }
                } header: {
                    Text("백업")
                } footer: {
                    Text("Dots는 기기에만 데이터를 저장해요. 다른 기기로 옮기거나 백업하려면 내보내기/가져오기를 사용하세요. 자동으로 동기화되지 않아요.")
                }

                Section("개인정보") {
                    Button("모든 데이터 삭제", role: .destructive) {
                        isPresentingDeleteAllConfirmation = true
                    }
                }

                Section {
                    Button("Dots 소개") { isPresentingAbout = true }
                }
            }
            .navigationTitle("프로필")
            .fileImporter(isPresented: $isPresentingImporter, allowedContentTypes: [.json]) { result in
                handleImport(result)
            }
            .alert("가져오기 결과", isPresented: .constant(importResultMessage != nil), actions: {
                Button("확인") { importResultMessage = nil }
            }, message: {
                Text(importResultMessage ?? "")
            })
            .alert("정말 모든 데이터를 삭제할까요?", isPresented: $isPresentingDeleteAllConfirmation) {
                Button("삭제", role: .destructive) { deleteAllData() }
                Button("취소", role: .cancel) {}
            } message: {
                Text("기록된 모든 경험, 연결, 별자리, 이야기가 기기에서 영구히 삭제돼요. 되돌릴 수 없어요.")
            }
            .sheet(isPresented: $isPresentingAbout) {
                AboutView()
            }
        }
    }

    private func prepareExport() {
        guard let data = try? BackupCodec.exportData(context: modelContext) else { return }
        let filename = "dots-backup-\(Int(Date().timeIntervalSince1970)).json"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        try? data.write(to: url)
        exportFileURL = url
    }

    private func handleImport(_ result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            guard let data = try? Data(contentsOf: url) else {
                importResultMessage = "파일을 읽을 수 없어요."
                return
            }
            do {
                let summary = try BackupCodec.importData(data, context: modelContext)
                importResultMessage = "경험 \(summary.insertedDots)개, 연결 \(summary.insertedConnections)개, 별자리 \(summary.insertedConstellations)개, 이야기 \(summary.insertedStories)개를 가져왔어요. (이미 있던 \(summary.skippedExistingIDs)개는 건너뜀)"
            } catch {
                importResultMessage = "가져오기에 실패했어요: 파일 형식을 확인해주세요."
            }
        case .failure:
            importResultMessage = "파일을 선택하지 못했어요."
        }
    }

    private func deleteAllData() {
        for dot in (try? modelContext.fetch(FetchDescriptor<Dot>())) ?? [] { modelContext.delete(dot) }
        for connection in (try? modelContext.fetch(FetchDescriptor<Connection>())) ?? [] { modelContext.delete(connection) }
        for constellation in (try? modelContext.fetch(FetchDescriptor<Constellation>())) ?? [] { modelContext.delete(constellation) }
        for story in (try? modelContext.fetch(FetchDescriptor<Story>())) ?? [] { modelContext.delete(story) }
        for reflection in (try? modelContext.fetch(FetchDescriptor<Reflection>())) ?? [] { modelContext.delete(reflection) }
    }
}

private struct AboutView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DotsSpacing.md) {
                    Text("Dots에 대하여")
                        .font(.system(size: 22, weight: .semibold))
                    Text("삶과 커리어의 경험들은 각자 하나의 점이에요. 그 점들을 시간순으로 기록하고, 시간이 지나 돌아봤을 때 서로 어떻게 연결되는지 발견해보세요. 연결은 자동으로 만들어지지 않아요 — 의미를 찾는 건 언제나 당신의 몫이에요.")
                        .font(.system(size: 14))

                    Text("별자리 데이터 출처")
                        .font(.system(size: 16, weight: .semibold))
                        .padding(.top, DotsSpacing.sm)
                    ForEach(ConstellationCatalog.templates) { template in
                        Text("• \(template.koreanName) (\(template.westernName)): \(template.attribution)")
                            .font(.system(size: 12))
                            .foregroundStyle(DotsColor.mutedSlate)
                    }
                }
                .padding(DotsSpacing.md)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("닫기") { dismiss() }
                }
            }
        }
    }
}
