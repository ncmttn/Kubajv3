import SwiftUI

struct ContentView: View {
    @State private var preferences = AppPreferences.shared

    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label(L10n.Tab.home, systemImage: "tree")
                }

            GroupingView()
                .tabItem {
                    Label(L10n.Tab.records, systemImage: "folder")
                }

            SettingsView()
                .tabItem {
                    Label(L10n.Tab.settings, systemImage: "gearshape")
                }
        }
        .environment(preferences)
        .preferredColorScheme(preferences.appTheme.colorScheme)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Folder.self, LogRecord.self], inMemory: true)
}
