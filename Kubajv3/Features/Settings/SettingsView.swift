import SwiftUI

struct SettingsView: View {
    @Environment(AppPreferences.self) private var preferences

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                KubajHeader()

                Form {
                    Section(L10n.Settings.calculationSection) {
                        Picker(L10n.Settings.defaultFormula, selection: formulaBinding) {
                            ForEach(AppPreferences.settingsCalculationMethods, id: \.rawValue) { method in
                                Text(L10n.Formula.displayName(for: method))
                                    .tag(method)
                            }
                        }
                    }

                    Section(L10n.Settings.appearanceSection) {
                        Picker(L10n.Settings.theme, selection: themeBinding) {
                            ForEach(AppTheme.allCases) { theme in
                                Text(L10n.Settings.themeName(for: theme))
                                    .tag(theme)
                            }
                        }
                        .pickerStyle(.segmented)
                    }

                    Section(L10n.Settings.languageSection) {
                        Button {
                            openSystemSettings()
                        } label: {
                            Label(L10n.Settings.openLanguageSettings, systemImage: "globe")
                        }
                    }

                    Section(L10n.Settings.aboutSection) {
                        LabeledContent(L10n.Settings.versionLabel, value: appVersion)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .background(KubajColor.background)
        }
    }

    private var formulaBinding: Binding<CalculationMethod> {
        Binding(
            get: { preferences.defaultCalculationMethod },
            set: { preferences.defaultCalculationMethod = $0 }
        )
    }

    private var themeBinding: Binding<AppTheme> {
        Binding(
            get: { preferences.appTheme },
            set: { preferences.appTheme = $0 }
        )
    }

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
        return "\(version) (\(build))"
    }

    private func openSystemSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        UIApplication.shared.open(url)
    }
}

#Preview {
    SettingsView()
        .environment(AppPreferences.shared)
}
