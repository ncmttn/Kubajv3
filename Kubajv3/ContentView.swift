import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label(L10n.Tab.home, systemImage: "tree")
                }

            GroupingView()
                .tabItem {
                    Label(L10n.Tab.grouping, systemImage: "square.stack.3d.up")
                }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Folder.self, LogRecord.self], inMemory: true)
}
