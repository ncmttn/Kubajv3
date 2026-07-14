import SwiftUI
import StoreKit
import UIKit

struct SettingsView: View {
    @Environment(AppPreferences.self) private var preferences
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.requestReview) private var requestReview

    var body: some View {
        @Bindable var preferences = preferences

        VStack(spacing: 0) {
            KubajHeader()

            ScrollView {
                VStack(spacing: 24) {
                    generalSettingsSection
                    enginePreferencesSection
                    languageSection
                    supportSection
                    footerInfo
                }
                .padding(.horizontal, KubajMetric.horizontalPadding)
                .padding(.top, 24)
                .padding(.bottom, 120)
            }
        }
        .background(KubajThemeColors.background(colorScheme))
    }

    private var generalSettingsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            KubajSettingsSectionLabel(title: L10n.Settings.generalSection)

            VStack(spacing: 0) {
                KubajSettingsToggleRow(
                    title: L10n.Settings.highVolumeAlerts,
                    systemImage: "bell.fill",
                    iconColor: Color(red: 0.95, green: 0.55, blue: 0.2),
                    isOn: highVolumeAlertsBinding
                )

                settingsDivider

                KubajSettingsToggleRow(
                    title: L10n.Settings.darkMode,
                    systemImage: "moon.fill",
                    iconColor: Color(red: 0.45, green: 0.35, blue: 0.85),
                    isOn: darkModeBinding
                )

                settingsDivider

                KubajSettingsToggleRow(
                    title: L10n.Settings.hapticFeedback,
                    systemImage: "iphone.radiowaves.left.and.right",
                    iconColor: Color(red: 0.95, green: 0.55, blue: 0.2),
                    isOn: hapticBinding
                )
            }
            .background(KubajThemeColors.card(colorScheme), in: RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(colorScheme == .dark ? 0.2 : 0.04), radius: 4, y: 2)
        }
    }

    private var enginePreferencesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            KubajSettingsSectionLabel(title: L10n.Settings.enginePreferencesSection)

            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 12) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(KubajColor.primary.opacity(0.12))
                        .frame(width: 40, height: 40)
                        .overlay {
                            Image(systemName: "function")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(KubajColor.primary)
                        }

                    Text(L10n.Settings.calculationMethod)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(KubajThemeColors.textPrimary(colorScheme))
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)

                HStack(spacing: 12) {
                    KubajFormulaOptionButton(
                        title: L10n.Formula.smalian,
                        subtitle: L10n.Settings.formulaSmalianSubtitle,
                        isSelected: preferences.defaultCalculationMethod == .smalian
                    ) {
                        preferences.defaultCalculationMethod = .smalian
                        HapticFeedback.light()
                    }

                    KubajFormulaOptionButton(
                        title: L10n.Formula.huber,
                        subtitle: L10n.Settings.formulaHuberSubtitle,
                        isSelected: preferences.defaultCalculationMethod == .huber
                    ) {
                        preferences.defaultCalculationMethod = .huber
                        HapticFeedback.light()
                    }
                }
                .padding(.horizontal, 16)

                HStack(spacing: 12) {
                    KubajFormulaOptionButton(
                        title: L10n.Formula.newton,
                        subtitle: L10n.Settings.formulaNewtonSubtitle,
                        isSelected: preferences.defaultCalculationMethod == .newton
                    ) {
                        preferences.defaultCalculationMethod = .newton
                        HapticFeedback.light()
                    }

                    KubajFormulaOptionButton(
                        title: L10n.Formula.ulker,
                        subtitle: L10n.Settings.formulaUlkerSubtitle,
                        isSelected: preferences.defaultCalculationMethod == .ulker
                    ) {
                        preferences.defaultCalculationMethod = .ulker
                        HapticFeedback.light()
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
            .background(KubajThemeColors.card(colorScheme), in: RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(colorScheme == .dark ? 0.2 : 0.04), radius: 4, y: 2)
        }
    }

    private var supportSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            KubajSettingsSectionLabel(title: L10n.Settings.supportSection)

            VStack(spacing: 0) {
                KubajSettingsLinkRow(
                    title: L10n.Settings.rateUsTitle,
                    subtitle: L10n.Settings.rateUsSubtitle,
                    systemImage: "star.fill",
                    iconColor: Color(red: 0.95, green: 0.75, blue: 0.2)
                ) {
                    requestAppReview()
                }

                settingsDivider

                KubajSettingsLinkRow(
                    title: L10n.Settings.contactTitle,
                    subtitle: L10n.Settings.contactSubtitle,
                    systemImage: "envelope.fill",
                    iconColor: KubajColor.primary
                ) {
                    openContactEmail()
                }
            }
            .background(KubajThemeColors.card(colorScheme), in: RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(colorScheme == .dark ? 0.2 : 0.04), radius: 4, y: 2)
        }
    }

    private var languageSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            KubajSettingsSectionLabel(title: L10n.Settings.languageSection)

            VStack(spacing: 0) {
                Menu {
                    ForEach(AppLanguage.allCases) { language in
                        Button {
                            preferences.appLanguage = language
                            HapticFeedback.light()
                        } label: {
                            if preferences.appLanguage == language {
                                Label(language.displayName, systemImage: "checkmark")
                            } else {
                                Text(language.displayName)
                            }
                        }
                    }
                } label: {
                    HStack(spacing: 12) {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(KubajColor.primary.opacity(0.12))
                            .frame(width: 40, height: 40)
                            .overlay {
                                Image(systemName: "globe")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(KubajColor.primary)
                            }

                        VStack(alignment: .leading, spacing: 2) {
                            Text(L10n.Settings.languagePickerTitle)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(KubajThemeColors.textPrimary(colorScheme))
                            Text(preferences.appLanguage.displayName)
                                .font(.system(size: 13))
                                .foregroundStyle(KubajThemeColors.textSecondary(colorScheme))
                        }

                        Spacer()

                        Image(systemName: "chevron.down")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(KubajThemeColors.textMuted(colorScheme))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
            }
            .background(KubajThemeColors.card(colorScheme), in: RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(colorScheme == .dark ? 0.2 : 0.04), radius: 4, y: 2)
        }
    }

    private var footerInfo: some View {
        VStack(spacing: 4) {
            Text(L10n.Settings.footerVersion(appVersion))
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(KubajThemeColors.textMuted(colorScheme))
                .textCase(.uppercase)
                .tracking(1)

            Text(L10n.Settings.footerCompany)
                .font(.system(size: 12))
                .foregroundStyle(KubajThemeColors.textMuted(colorScheme).opacity(0.8))
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
    }

    private var settingsDivider: some View {
        Rectangle()
            .fill(KubajThemeColors.borderSubtle(colorScheme))
            .frame(height: 1)
            .padding(.horizontal, 16)
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    private var highVolumeAlertsBinding: Binding<Bool> {
        Binding(
            get: { preferences.isHighVolumeAlertsEnabled },
            set: { preferences.isHighVolumeAlertsEnabled = $0 }
        )
    }

    private var darkModeBinding: Binding<Bool> {
        Binding(
            get: { preferences.appTheme == .dark },
            set: { preferences.appTheme = $0 ? .dark : .light }
        )
    }

    private var hapticBinding: Binding<Bool> {
        Binding(
            get: { preferences.isHapticEnabled },
            set: { preferences.isHapticEnabled = $0 }
        )
    }

    private func requestAppReview() {
        requestReview()
        HapticFeedback.light()
    }

    private func openContactEmail() {
        let subject = L10n.Settings.contactEmailSubject
        let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        guard let url = URL(string: "mailto:\(KubajAppLinks.contactEmail)?subject=\(encodedSubject)") else {
            return
        }
        UIApplication.shared.open(url)
        HapticFeedback.light()
    }
}

#Preview {
    SettingsView()
        .environment(AppPreferences.shared)
}
