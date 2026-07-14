import SwiftUI

struct ContentView: View {
    @Environment(AppPreferences.self) private var preferences
    @State private var selectedTab: AppTab = .home
    @State private var homeViewModel = HomeViewModel()
    @State private var groupingSelectedFolder: Folder?

    var body: some View {
        ZStack(alignment: .bottom) {
            KubajThemeColors.background(preferences.appTheme.resolvedColorScheme)
                .ignoresSafeArea()

            Group {
                switch selectedTab {
                case .home:
                    HomeView(viewModel: homeViewModel) {
                        groupingSelectedFolder = nil
                        selectedTab = .groups
                    }
                case .groups:
                    GroupingView(
                        homeViewModel: homeViewModel,
                        selectedFolder: $groupingSelectedFolder
                    )
                case .folders:
                    FoldersView { folder in
                        groupingSelectedFolder = folder
                        selectedTab = .groups
                    }
                case .settings:
                    SettingsView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            KubajTabBar(selection: $selectedTab)
                .padding(.horizontal, 8)
                .padding(.bottom, 0)
        }
        .preferredColorScheme(preferences.appTheme.colorScheme)
        .environment(\.locale, Locale(identifier: preferences.appLanguage.localeIdentifier))
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Folder.self, LogRecord.self], inMemory: true)
}
