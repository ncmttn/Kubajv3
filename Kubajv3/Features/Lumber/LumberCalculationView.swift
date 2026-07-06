import SwiftUI

struct LumberCalculationView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    @State private var widthInput = ""
    @State private var thicknessInput = ""
    @State private var lengthInput = ""
    @State private var quantityInput = "1"
    @State private var previewVolume: Double?

    let onAdd: (Double, Double, Double, Int) -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: KubajMetric.sectionSpacing) {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        KubajInputField(title: L10n.Lumber.widthCm, text: $widthInput)
                        KubajInputField(title: L10n.Lumber.thicknessCm, text: $thicknessInput)
                        KubajInputField(title: L10n.Lumber.lengthM, text: $lengthInput)
                        KubajInputField(title: L10n.Lumber.quantity, text: $quantityInput, keyboard: .numberPad)
                    }

                    if let previewVolume {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(L10n.Lumber.previewVolume(DisplayFormatting.volume(previewVolume)))
                                .font(.headline)
                                .foregroundStyle(KubajThemeColors.textPrimary(colorScheme))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(KubajMetric.horizontalPadding)
                        .background(KubajThemeColors.surface(colorScheme), in: RoundedRectangle(cornerRadius: KubajMetric.cornerRadiusLarge))
                    }

                    KubajPrimaryButton(title: L10n.Lumber.addToList, isEnabled: canSubmit) {
                        submit()
                    }
                }
                .padding(.horizontal, KubajMetric.horizontalPadding)
                .padding(.top, KubajMetric.sectionSpacing)
                .padding(.bottom, 32)
            }
            .background(KubajThemeColors.background(colorScheme))
            .navigationTitle(L10n.Lumber.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.Common.cancel) {
                        dismiss()
                    }
                }
            }
        }
        .onChange(of: widthInput) { _, _ in updatePreview() }
        .onChange(of: thicknessInput) { _, _ in updatePreview() }
        .onChange(of: lengthInput) { _, _ in updatePreview() }
    }

    private var canSubmit: Bool {
        parsedValues != nil
    }

    private var parsedValues: (Double, Double, Double, Int)? {
        guard
            let width = parseDouble(widthInput),
            let thickness = parseDouble(thicknessInput),
            let length = parseDouble(lengthInput),
            let quantity = parseInt(quantityInput),
            width > 0,
            thickness > 0,
            length > 0,
            quantity > 0
        else {
            return nil
        }
        return (width, thickness, length, quantity)
    }

    private func updatePreview() {
        guard let values = parsedValues else {
            previewVolume = nil
            return
        }
        previewVolume = ForestryCalculator.lumber(
            widthCm: values.0,
            thicknessCm: values.1,
            lengthM: values.2
        )
    }

    private func submit() {
        guard let values = parsedValues else {
            return
        }
        onAdd(values.0, values.1, values.2, values.3)
        dismiss()
    }

    private func parseDouble(_ text: String) -> Double? {
        let normalized = text
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: ",", with: ".")
        return Double(normalized)
    }

    private func parseInt(_ text: String) -> Int? {
        Int(text.trimmingCharacters(in: .whitespacesAndNewlines))
    }
}

#Preview {
    LumberCalculationView { _, _, _, _ in }
}
