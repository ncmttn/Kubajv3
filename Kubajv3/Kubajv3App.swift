import SwiftUI
import SwiftData

@main
struct Kubajv3App: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Bolme.self,
            Istif.self,
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
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
