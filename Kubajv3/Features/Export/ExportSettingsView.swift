import SwiftUI

struct ExportSettingsView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var fieldValues: [String]
    let exportKind: ExportKind
    let onExport: (ExportMetadata) -> Void

    init(exportKind: ExportKind, onExport: @escaping (ExportMetadata) -> Void) {
        self.exportKind = exportKind
        self.onExport = onExport
        _fieldValues = State(initialValue: Array(repeating: "", count: ExportMetadata.maximumFieldCount))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.clear
                    .background(.ultraThinMaterial)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(0..<ExportMetadata.maximumFieldCount, id: \.self) { index in
                            fieldCard(index: index)
                        }

                        Button {
                            onExport(ExportMetadata(fields: fieldValues))
                            dismiss()
                        } label: {
                            Text(confirmTitle)
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                }
            }
            .navigationTitle(L10n.Export.settingsTitle)
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

    private func fieldCard(index: Int) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(L10n.Export.optionalFieldLabel(index: index))
                .font(.caption)
                .foregroundStyle(.secondary)
            TextField(L10n.Export.optionalFieldPlaceholder(index: index), text: $fieldValues[index])
                .textFieldStyle(.roundedBorder)
        }
        .padding()
        .glassCard(material: .ultraThinMaterial)
    }
}

#Preview {
    ExportSettingsView(exportKind: .pdf) { _ in }
}
