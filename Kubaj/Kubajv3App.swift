import SwiftUI
import SwiftData

@main
struct Kubajv3App: App {
    @State private var preferences = AppPreferences.shared

    private static let modelSchema = Schema([
        Folder.self,
        LogRecord.self,
    ])

    var sharedModelContainer: ModelContainer = {
        createModelContainer()
    }()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(preferences)
                .environment(\.locale, Locale(identifier: preferences.appLanguage.localeIdentifier))
        }
        .modelContainer(sharedModelContainer)
    }

    private static func createModelContainer() -> ModelContainer {
        let configuration = ModelConfiguration(
            schema: modelSchema,
            isStoredInMemoryOnly: false
        )

        do {
            return try ModelContainer(
                for: modelSchema,
                configurations: [configuration]
            )
        } catch {
            removePersistentStore(at: configuration.url)

            do {
                return try ModelContainer(
                    for: modelSchema,
                    configurations: [configuration]
                )
            } catch {
                fatalError(String(describing: error))
            }
        }
    }

    private static func removePersistentStore(at url: URL) {
        let fileManager = FileManager.default
        let relatedURLs = [
            url,
            URL(fileURLWithPath: url.path + "-shm"),
            URL(fileURLWithPath: url.path + "-wal"),
        ]

        for storeURL in relatedURLs where fileManager.fileExists(atPath: storeURL.path) {
            try? fileManager.removeItem(at: storeURL)
        }
    }
}

private struct RootView: View {
    @Environment(AppPreferences.self) private var preferences
    @State private var isActive = false

    var body: some View {
        ZStack {
            if isActive {
                Group {
                    if preferences.hasCompletedOnboarding {
                        ContentView()
                    } else {
                        OnboardingView()
                    }
                }
                .id(preferences.appLanguage)
                .transition(.opacity)
            } else {
                SplashView()
                    .transition(.opacity)
            }
        }
        .task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            withAnimation(.easeInOut(duration: 0.45)) {
                isActive = true
            }
        }
    }
}
