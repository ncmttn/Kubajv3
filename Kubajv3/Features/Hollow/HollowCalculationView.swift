import SwiftUI

struct HollowCalculationView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    @State private var outerDiameterInput = ""
    @State private var innerDiameterInput = ""
    @State private var lengthInput = ""
    @State private var quantityInput = "1"
    @State private var previewResult: HollowCalculationResult?

    let onAdd: (Double, Double, Double, Int) -> Void
    var onAddDiameter: (Int, Double, Int) -> Void = { _, _, _ in }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: KubajMetric.sectionSpacing) {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        KubajInputField(title: L10n.Hollow.outerDiameter, text: $outerDiameterInput)
                        KubajInputField(title: L10n.Hollow.innerDiameter, text: $innerDiameterInput)
                        KubajInputField(title: L10n.Hollow.length, text: $lengthInput)
                        KubajInputField(title: L10n.Hollow.quantity, text: $quantityInput, keyboard: .numberPad)
                    }

                    if let previewResult {
                        resultCard(previewResult)
                    }

                    KubajPrimaryButton(
                        title: L10n.Hollow.addToList,
                        isEnabled: canSubmit
                    ) {
                        submit()
                    }

                    if let previewResult, let values = parsedValues {
                        alternativeButtons(
                            equivalent: previewResult.equivalentSolidDiameterCm,
                            length: values.2,
                            quantity: values.3
                        )
                    }
                }
                .padding(.horizontal, KubajMetric.horizontalPadding)
                .padding(.top, KubajMetric.sectionSpacing)
                .padding(.bottom, 32)
            }
            .background(KubajThemeColors.background(colorScheme))
            .navigationTitle(L10n.Hollow.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.Common.cancel) {
                        dismiss()
                    }
                }
            }
        }
        .onChange(of: outerDiameterInput) { _, _ in updatePreview() }
        .onChange(of: innerDiameterInput) { _, _ in updatePreview() }
        .onChange(of: lengthInput) { _, _ in updatePreview() }
    }

    private var canSubmit: Bool {
        parsedValues != nil
    }

    private var parsedValues: (Double, Double, Double, Int)? {
        guard
            let outer = parseDouble(outerDiameterInput),
            let inner = parseDouble(innerDiameterInput),
            let length = parseDouble(lengthInput),
            let quantity = parseInt(quantityInput),
            outer > inner,
            inner > 0,
            length > 0,
            quantity > 0
        else {
            return nil
        }
        return (outer, inner, length, quantity)
    }

    private func resultCard(_ result: HollowCalculationResult) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(L10n.Hollow.equivalentDiameter(result.equivalentSolidDiameterCm))
                .font(.headline)
                .foregroundStyle(KubajThemeColors.textPrimary(colorScheme))
            Text(L10n.Hollow.netVolume(result.netVolumeM3))
                .font(.subheadline)
                .foregroundStyle(KubajThemeColors.textSecondary(colorScheme))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(KubajMetric.horizontalPadding)
        .background(KubajThemeColors.surface(colorScheme), in: RoundedRectangle(cornerRadius: KubajMetric.cornerRadiusLarge))
    }

    @ViewBuilder
    private func alternativeButtons(equivalent: Int, length: Double, quantity: Int) -> some View {
        VStack(spacing: 10) {
            Text(L10n.Hollow.alternativeTitle)
                .font(KubajFont.labelCaps())
                .foregroundStyle(KubajThemeColors.textSecondary(colorScheme))
                .textCase(.uppercase)
                .tracking(1)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 12) {
                if equivalent - 1 > 0 {
                    KubajOutlineCapsuleButton(
                        title: L10n.Hollow.addDiameter(equivalent - 1),
                        systemImage: "minus"
                    ) {
                        onAddDiameter(equivalent - 1, length, quantity)
                        dismiss()
                    }
                }

                KubajOutlineCapsuleButton(
                    title: L10n.Hollow.addDiameter(equivalent + 1),
                    systemImage: "plus"
                ) {
                    onAddDiameter(equivalent + 1, length, quantity)
                    dismiss()
                }
            }
        }
    }

    private func updatePreview() {
        guard let values = parsedValues else {
            previewResult = nil
            return
        }
        previewResult = ForestryCalculator.hollow(
            outerDiameterCm: values.0,
            innerDiameterCm: values.1,
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
    HollowCalculationView { _, _, _, _ in }
}
