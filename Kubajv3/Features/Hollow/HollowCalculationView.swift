import SwiftUI

struct HollowCalculationView: View {
    var isEmbedded: Bool = false
    @Environment(\.dismiss) private var dismiss

    @State private var outerDiameterInput = ""
    @State private var innerDiameterInput = ""
    @State private var lengthInput = ""
    @State private var quantityInput = "1"
    @State private var previewResult: HollowCalculationResult?

    let onAdd: (Double, Double, Double, Int) -> Void

    var body: some View {
        Group {
            if isEmbedded {
                embeddedBody
            } else {
                NavigationStack {
                    embeddedBody
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
            }
        }
    }

    private var embeddedBody: some View {
        VStack(spacing: 0) {
            if isEmbedded {
                KubajHeader()
            }

            ScrollView {
                VStack(spacing: KubajMetric.sectionSpacing) {
                    if isEmbedded {
                        Text(L10n.Hollow.title)
                            .font(KubajFont.sectionTitle())
                            .foregroundStyle(KubajColor.textHeading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    KubajInputField(
                        title: L10n.Hollow.outerDiameter,
                        text: $outerDiameterInput
                    )
                    KubajInputField(
                        title: L10n.Hollow.innerDiameter,
                        text: $innerDiameterInput
                    )
                    KubajInputField(
                        title: L10n.Hollow.length,
                        text: $lengthInput
                    )
                    KubajInputField(
                        title: L10n.Hollow.quantity,
                        text: $quantityInput,
                        keyboard: .numberPad
                    )

                    if let previewResult {
                        resultCard(previewResult)
                    }

                    KubajPrimaryButton(
                        title: L10n.Hollow.addToList,
                        isEnabled: canSubmit
                    ) {
                        submit()
                    }
                }
                .padding(.horizontal, KubajMetric.horizontalPadding)
                .padding(.top, KubajMetric.sectionSpacing)
                .padding(.bottom, 120)
            }
        }
        .background(KubajColor.background)
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
                .foregroundStyle(KubajColor.textPrimary)
            Text(L10n.Hollow.netVolume(result.netVolumeM3))
                .font(.subheadline)
                .foregroundStyle(KubajColor.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(KubajMetric.horizontalPadding)
        .background(KubajColor.surface, in: RoundedRectangle(cornerRadius: KubajMetric.cornerRadiusLarge))
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
        if !isEmbedded {
            dismiss()
        } else {
            outerDiameterInput = ""
            innerDiameterInput = ""
            lengthInput = ""
            quantityInput = "1"
            previewResult = nil
        }
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
