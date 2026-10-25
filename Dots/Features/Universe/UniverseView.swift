import SwiftUI
import SwiftData

struct UniverseView: View {
    @Binding var preselectedSourceID: UUID?

    @Query private var allDots: [Dot]
    @Query private var allConnections: [Connection]
    @Query private var allConstellations: [Constellation]

    @State private var isPresentingConnectionPicker = false
    @State private var isPresentingConstellationEditor = false

    private var connectedDotIDs: Set<UUID> {
        var ids = Set<UUID>()
        for connection in allConnections {
            ids.insert(connection.sourceDotID)
            ids.insert(connection.targetDotID)
        }
        return ids
    }

    private var groupedDotIDs: Set<UUID> {
        Set(allConstellations.flatMap { $0.memberDotIDs })
    }

    private var unconnectedDots: [Dot] {
        let referenced = connectedDotIDs.union(groupedDotIDs)
        return ChronologySort.sorted(allDots.filter { !referenced.contains($0.id) }, direction: .newestFirst)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                DotsColor.backgroundNavy.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: DotsSpacing.lg) {
                        actionRow

                        myConstellationsSection

                        unconnectedSection
                    }
                    .padding(DotsSpacing.md)
                }
            }
            .navigationTitle("유니버스")
            .toolbarColorScheme(.dark, for: .navigationBar)
            .navigationDestination(for: Dot.self) { dot in
                DotDetailView(dot: dot)
            }
            .navigationDestination(for: Constellation.self) { constellation in
                ConstellationDetailView(constellation: constellation)
            }
            .sheet(isPresented: $isPresentingConnectionPicker, onDismiss: { preselectedSourceID = nil }) {
                ConnectionPickerView(preselectedSourceID: preselectedSourceID)
            }
            .sheet(isPresented: $isPresentingConstellationEditor) {
                ConstellationEditorView(mode: .create)
            }
            .onChange(of: preselectedSourceID) { _, newValue in
                if newValue != nil {
                    isPresentingConnectionPicker = true
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private var actionRow: some View {
        HStack(spacing: DotsSpacing.sm) {
            Button {
                isPresentingConnectionPicker = true
            } label: {
                Label("연결하기", systemImage: "link")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .tint(DotsColor.periwinkle)

            Button {
                isPresentingConstellationEditor = true
            } label: {
                Label("별자리 만들기", systemImage: "star")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(DotsColor.periwinkle)
        }
        .foregroundStyle(.white)
    }

    private var myConstellationsSection: some View {
        VStack(alignment: .leading, spacing: DotsSpacing.sm) {
            Text("내 별자리")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.white)

            if allConstellations.isEmpty {
                Text("아직 만든 별자리가 없어요. 경험을 2개 이상 골라 별자리를 만들어보세요.")
                    .font(.system(size: 13))
                    .foregroundStyle(DotsColor.mutedSlate)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: DotsSpacing.sm) {
                        ForEach(allConstellations) { constellation in
                            NavigationLink(value: constellation) {
                                ConstellationPreviewCard(constellation: constellation, allDots: allDots)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }

    private var unconnectedSection: some View {
        VStack(alignment: .leading, spacing: DotsSpacing.sm) {
            Text("연결되지 않은 경험")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.white)

            if unconnectedDots.isEmpty {
                Text(allDots.isEmpty ? "타임라인에서 경험을 먼저 기록해보세요." : "모든 경험이 연결되었거나 별자리에 속해 있어요.")
                    .font(.system(size: 13))
                    .foregroundStyle(DotsColor.mutedSlate)
            } else {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 90))], spacing: DotsSpacing.md) {
                    ForEach(unconnectedDots) { dot in
                        NavigationLink(value: dot) {
                            VStack(spacing: 6) {
                                ZStack {
                                    Circle().fill(DotsColor.lavender.opacity(0.3)).frame(width: 30, height: 30).blur(radius: 3)
                                    Circle().fill(Color.white).frame(width: 7, height: 7)
                                }
                                Text(dot.title)
                                    .font(.system(size: 11))
                                    .foregroundStyle(.white)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(width: 90)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

private struct ConstellationPreviewCard: View {
    let constellation: Constellation
    let allDots: [Dot]

    private var members: [Dot] {
        allDots.filter { constellation.memberDotIDs.contains($0.id) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let template = ConstellationCatalog.template(withID: constellation.templateID) {
                ConstellationCanvasView(mapping: ConstellationMapper.map(memberDots: members, template: template))
                    .frame(width: 140, height: 90)
            }
            Text(constellation.customTitle)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.white)
                .lineLimit(1)
            if let template = ConstellationCatalog.template(withID: constellation.templateID) {
                Text(template.koreanName)
                    .font(.system(size: 11))
                    .foregroundStyle(DotsColor.mutedSlate)
            }
        }
        .padding(DotsSpacing.sm)
        .frame(width: 156)
        .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: DotsRadius.standard))
    }
}
