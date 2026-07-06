import SwiftUI

struct ContentView: View {
    @State private var preferences = AppPreferences.shared
    @State private var selectedTab: AppTab = .home
    @State private var homeViewModel = HomeViewModel()

    var body: some View {
        ZStack(alignment: .bottom) {
            KubajColor.background
                .ignoresSafeArea()

            Group {
                switch selectedTab {
                case .home:
                    HomeView(viewModel: homeViewModel) {
                        selectedTab = .groups
                    }
                case .groups:
                    GroupingView()
                case .hollow:
                    HollowCalculationView(isEmbedded: true) { outer, inner, length, quantity in
                        homeViewModel.addHollowEntry(
                            outerDiameterCm: outer,
                            innerDiameterCm: inner,
                            lengthM: length,
                            quantity: quantity
                        )
                        HapticFeedback.medium()
                        selectedTab = .home
                    }
                case .settings:
                    SettingsView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            KubajTabBar(selection: $selectedTab)
                .padding(.horizontal, 8)
                .padding(.bottom, 8)
        }
        .environment(preferences)
        .preferredColorScheme(preferences.appTheme.colorScheme)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Folder.self, LogRecord.self], inMemory: true)
}
