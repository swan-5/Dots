import SwiftUI

enum AppTab: String, CaseIterable, Identifiable {
    case timeline, universe, story, profile

    var id: String { rawValue }

    var title: String {
        switch self {
        case .timeline: return "타임라인"
        case .universe: return "유니버스"
        case .story: return "내 이야기"
        case .profile: return "프로필"
        }
    }

    var symbolName: String {
        switch self {
        case .timeline: return "list.bullet.rectangle"
        case .universe: return "sparkles"
        case .story: return "book.closed"
        case .profile: return "person.crop.circle"
        }
    }
}

struct RootTabView: View {
    @State private var selectedTab: AppTab = .timeline
    /// Preselected dot id, used when navigating Dot Detail -> "Connect another Dot" -> Universe.
    @State private var pendingConnectionSourceID: UUID?

    var body: some View {
        TabView(selection: $selectedTab) {
            TimelineView()
                .tabItem { Label(AppTab.timeline.title, systemImage: AppTab.timeline.symbolName) }
                .tag(AppTab.timeline)

            UniverseView(preselectedSourceID: $pendingConnectionSourceID)
                .tabItem { Label(AppTab.universe.title, systemImage: AppTab.universe.symbolName) }
                .tag(AppTab.universe)

            StoryListView()
                .tabItem { Label(AppTab.story.title, systemImage: AppTab.story.symbolName) }
                .tag(AppTab.story)

            ProfileView()
                .tabItem { Label(AppTab.profile.title, systemImage: AppTab.profile.symbolName) }
                .tag(AppTab.profile)
        }
        .tint(DotsColor.periwinkle)
        .onReceive(NotificationCenter.default.publisher(for: .dotsRequestConnectFromDetail)) { notification in
            if let id = notification.object as? UUID {
                pendingConnectionSourceID = id
                selectedTab = .universe
            }
        }
    }
}

extension Notification.Name {
    /// Posted by Dot Detail's "Connect another Dot" action; object is the source Dot's id.
    static let dotsRequestConnectFromDetail = Notification.Name("dotsRequestConnectFromDetail")
}
