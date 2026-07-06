import SwiftUI
import SwiftData

@main
struct Kubajv3App: App {
    @State private var preferences = AppPreferences.shared

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Folder.self,
            LogRecord.self,
        ])
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )

        do {
            return try ModelContainer(
                for: schema,
                configurations: [configuration]
            )
        } catch {
            fatalError(String(describing: error))
        }
    }()

    var body: some Scene {
        WindowGroup {
            Group {
                if preferences.hasCompletedOnboarding {
                    ContentView()
                } else {
                    OnboardingView()
                }
            }
            .environment(preferences)
        }
        .modelContainer(sharedModelContainer)
    }
}
