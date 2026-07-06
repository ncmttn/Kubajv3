import SwiftUI

struct SettingsView: View {
    @Environment(AppPreferences.self) private var preferences
    @State private var reportFields: [String] = Array(repeating: "", count: ExportMetadata.maximumFieldCount)

    var body: some View {
        VStack(spacing: 0) {
            KubajHeader()

            ScrollView {
                VStack(spacing: 32) {
                    KubajSectionHeader(
                        title: L10n.Settings.reportHeaderTitle,
                        subtitle: L10n.Settings.reportHeaderSubtitle
                    )

                    reportForm

                    KubajSettingsCard(title: L10n.Settings.calculationSection) {
                        Picker(L10n.Settings.defaultFormula, selection: formulaBinding) {
                            ForEach(AppPreferences.settingsCalculationMethods, id: \.rawValue) { method in
                                Text(L10n.Formula.displayName(for: method))
                                    .tag(method)
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(KubajColor.primary)
                    }

                    KubajSettingsCard(title: L10n.Settings.appearanceSection) {
                        Picker(L10n.Settings.theme, selection: themeBinding) {
                            ForEach(AppTheme.allCases) { theme in
                                Text(L10n.Settings.themeName(for: theme))
                                    .tag(theme)
                            }
                        }
                        .pickerStyle(.segmented)
                    }

                    KubajSettingsCard(title: L10n.Settings.languageSection) {
                        Button {
                            openSystemSettings()
                        } label: {
                            HStack {
                                Label(L10n.Settings.openLanguageSettings, systemImage: "globe")
                                    .foregroundStyle(KubajColor.textPrimary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(KubajColor.textMuted)
                            }
                        }
                    }

                    infoCard

                    professionalCard

                    previewDraft

                    KubajSettingsCard(title: L10n.Settings.aboutSection) {
                        LabeledContent(L10n.Settings.versionLabel, value: appVersion)
                    }
                }
                .padding(.horizontal, KubajMetric.horizontalPadding)
                .padding(.top, 32)
                .padding(.bottom, 120)
            }
        }
        .background(KubajColor.background)
        .onAppear {
            loadReportFields()
        }
    }

    private var reportForm: some View {
        VStack(spacing: 24) {
            ForEach(ReportField.allCases) { field in
                KubajFormField(
                    label: L10n.Export.reportFieldLabel(field),
                    placeholder: L10n.Export.reportFieldPlaceholder(field),
                    text: binding(for: field),
                    keyboard: field == .contactPhone ? .phonePad : .default
                )
            }

            KubajRectPrimaryButton(
                title: L10n.Settings.saveReportHeader,
                systemImage: "square.and.arrow.down"
            ) {
                saveReportFields()
                HapticFeedback.medium()
            }
        }
        .padding(32)
        .background(KubajColor.surface, in: RoundedRectangle(cornerRadius: 32))
    }

    private var infoCard: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: "info.circle.fill")
                .font(.system(size: 28))
                .foregroundStyle(KubajColor.primary)

            VStack(alignment: .leading, spacing: 8) {
                Text(L10n.Settings.outputInfoTitle)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(KubajColor.textPrimary)

                Text(L10n.Settings.outputInfoBody)
                    .font(.system(size: 16))
                    .foregroundStyle(KubajColor.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(32)
        .background(KubajColor.surface, in: RoundedRectangle(cornerRadius: 24))
    }

    private var professionalCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Image(systemName: "doc.richtext.fill")
                .font(.system(size: 30))
                .foregroundStyle(.white)

            Text(L10n.Settings.professionalLookTitle)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.white)

            VStack(spacing: 8) {
                Capsule()
                    .fill(Color.white.opacity(0.4))
                    .frame(height: 8)
                Capsule()
                    .fill(Color.white.opacity(0.4))
                    .frame(width: 180, height: 8)
            }
            .padding(12)
            .background(Color.white.opacity(0.2), in: RoundedRectangle(cornerRadius: 12))
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(KubajColor.primaryEnd, in: RoundedRectangle(cornerRadius: 24))
    }

    private var previewDraft: some View {
        VStack(spacing: 24) {
            Text(L10n.Settings.previewDraftTitle)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(KubajColor.textMuted)
                .textCase(.uppercase)
                .tracking(1.4)

            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(KubajColor.inputBackground)
                        .frame(width: 48, height: 48)

                    VStack(alignment: .trailing, spacing: 4) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(KubajColor.inputBackground)
                            .frame(width: 128, height: 16)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(KubajColor.surface)
                            .frame(width: 96, height: 12)
                    }
                    Spacer()
                }

                ForEach(0..<3, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(KubajColor.surface)
                        .frame(height: 16)
                }

                RoundedRectangle(cornerRadius: 4)
                    .fill(KubajColor.surface)
                    .frame(width: 200, height: 16)
            }
            .padding(33)
            .background(Color.white, in: RoundedRectangle(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(KubajColor.borderSubtle, lineWidth: 1)
            }
            .shadow(color: .black.opacity(0.1), radius: 25, y: 12)
            .scaleEffect(0.95)
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

    private func binding(for field: ReportField) -> Binding<String> {
        Binding(
            get: { reportFields[field.rawValue] },
            set: { reportFields[field.rawValue] = $0 }
        )
    }

    private func loadReportFields() {
        reportFields = ReportField.allCases.map { ReportHeaderPreferences.value(for: $0) }
    }

    private func saveReportFields() {
        for field in ReportField.allCases {
            ReportHeaderPreferences.setValue(reportFields[field.rawValue], for: field)
        }
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
