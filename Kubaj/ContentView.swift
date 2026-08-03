import SwiftUI

struct ContentView: View {
    @Environment(AppPreferences.self) private var preferences
    @State private var selectedTab: AppTab = .home
    @State private var homeViewModel = HomeViewModel()
    @State private var groupingSelectedFolder: Folder?
    @State private var isKeyboardVisible = false

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
                .opacity(isKeyboardVisible ? 0 : 1)
                .offset(y: isKeyboardVisible ? 80 : 0)
                .allowsHitTesting(!isKeyboardVisible)
                .accessibilityHidden(isKeyboardVisible)
                .animation(.easeInOut(duration: 0.22), value: isKeyboardVisible)
        }
        .preferredColorScheme(preferences.appTheme.colorScheme)
        .environment(\.locale, Locale(identifier: preferences.appLanguage.localeIdentifier))
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
            isKeyboardVisible = true
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            isKeyboardVisible = false
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Folder.self, LogRecord.self], inMemory: true)
}
