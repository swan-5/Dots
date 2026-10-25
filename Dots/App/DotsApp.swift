import SwiftUI
import SwiftData

@main
struct DotsApp: App {
    let container: ModelContainer

    @AppStorage("dots.hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("dots.appearance") private var appearanceRaw = AppAppearance.system.rawValue

    init() {
        let schema = Schema([
            Dot.self,
            Connection.self,
            Constellation.self,
            Story.self,
            Reflection.self
        ])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            container = try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if hasCompletedOnboarding {
                    RootTabView()
                } else {
                    OnboardingView(onFinish: { hasCompletedOnboarding = true })
                }
            }
            .preferredColorScheme(AppAppearance(rawValue: appearanceRaw)?.colorScheme)
        }
        .modelContainer(container)
    }
}

enum AppAppearance: String, CaseIterable, Identifiable {
    case system, dark, light

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .system: return "시스템"
        case .dark: return "다크"
        case .light: return "라이트"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .dark: return .dark
        case .light: return .light
        }
    }
}
