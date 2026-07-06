import SwiftUI

struct HollowCalculationView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var outerDiameterInput = ""
    @State private var innerDiameterInput = ""
    @State private var lengthInput = ""
    @State private var quantityInput = "1"
    @State private var previewResult: HollowCalculationResult?

    let onAdd: (Double, Double, Double, Int) -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color.orange.opacity(0.2),
                        Color.accentColor.opacity(0.1),
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        field(L10n.Hollow.outerDiameter, text: $outerDiameterInput)
                        field(L10n.Hollow.innerDiameter, text: $innerDiameterInput)
                        field(L10n.Hollow.length, text: $lengthInput)
                        field(L10n.Hollow.quantity, text: $quantityInput)

                        if let previewResult {
                            resultCard(previewResult)
                        }

                        Button {
                            submit()
                        } label: {
                            Text(L10n.Hollow.addToList)
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(!canSubmit)
                    }
                    .padding()
                }
            }
            .navigationTitle(L10n.Hollow.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.Common.cancel) {
                        dismiss()
                    }
                }
            }
            .onChange(of: outerDiameterInput) { _, _ in updatePreview() }
            .onChange(of: innerDiameterInput) { _, _ in updatePreview() }
            .onChange(of: lengthInput) { _, _ in updatePreview() }
        }
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

    private func field(_ title: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            TextField(title, text: text)
                .keyboardType(.decimalPad)
                .textFieldStyle(.roundedBorder)
        }
        .padding()
        .glassCard()
    }

    private func resultCard(_ result: HollowCalculationResult) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(L10n.Hollow.equivalentDiameter(result.equivalentSolidDiameterCm))
                .font(.headline)
            Text(L10n.Hollow.netVolume(result.netVolumeM3))
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .glassCard(material: .regularMaterial)
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
