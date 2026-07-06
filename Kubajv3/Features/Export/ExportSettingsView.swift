import SwiftUI

struct ExportSettingsView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var fieldValues: [String]
    let exportKind: ExportKind
    let onExport: (ExportMetadata) -> Void

    init(exportKind: ExportKind, onExport: @escaping (ExportMetadata) -> Void) {
        self.exportKind = exportKind
        self.onExport = onExport
        let stored = ReportField.allCases.map { ReportHeaderPreferences.value(for: $0) }
        _fieldValues = State(initialValue: stored)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    KubajSectionHeader(
                        title: L10n.Export.settingsTitle,
                        subtitle: L10n.Settings.reportHeaderSubtitle
                    )

                    VStack(spacing: 24) {
                        ForEach(ReportField.allCases) { field in
                            KubajFormField(
                                label: L10n.Export.reportFieldLabel(field),
                                placeholder: L10n.Export.reportFieldPlaceholder(field),
                                text: binding(for: field),
                                keyboard: field == .contactPhone ? .phonePad : .default
                            )
                        }
                    }
                    .padding(32)
                    .background(KubajColor.surface, in: RoundedRectangle(cornerRadius: 32))

                    KubajRectPrimaryButton(
                        title: confirmTitle,
                        systemImage: exportKind == .pdf ? "doc.richtext" : "tablecells"
                    ) {
                        saveAndExport()
                    }
                }
                .padding(.horizontal, KubajMetric.horizontalPadding)
                .padding(.vertical, 24)
            }
            .background(KubajColor.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.Common.cancel) {
                        dismiss()
                    }
                }
            }
        }
    }

    private var confirmTitle: String {
        switch exportKind {
        case .pdf:
            L10n.Export.confirmPDF
        case .csv:
            L10n.Export.confirmCSV
        }
    }

    private func binding(for field: ReportField) -> Binding<String> {
        Binding(
            get: { fieldValues[field.rawValue] },
            set: { fieldValues[field.rawValue] = $0 }
        )
    }

    private func saveAndExport() {
        for field in ReportField.allCases {
            ReportHeaderPreferences.setValue(fieldValues[field.rawValue], for: field)
        }
        onExport(ExportMetadata(fields: fieldValues))
        dismiss()
    }
}

#Preview {
    ExportSettingsView(exportKind: .pdf) { _ in }
}
