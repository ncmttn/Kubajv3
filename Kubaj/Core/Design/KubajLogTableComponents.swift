import SwiftUI

enum LengthBandIndices {
    /// Toggles band index (0/1) whenever consecutive rows have a different length.
    static func compute(for lengths: [Double]) -> [Int] {
        guard !lengths.isEmpty else { return [] }
        var bands: [Int] = []
        var band = 0
        var previousLength: Double?
        for length in lengths {
            if let previousLength, abs(length - previousLength) > 0.000_1 {
                band = 1 - band
            }
            bands.append(band)
            previousLength = length
        }
        return bands
    }
}

struct KubajLogTableHeader: View {
    var sortOrder: LogSortOrder?
    var onSortLength: (() -> Void)?
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(spacing: 0) {
            Text(L10n.Home.tableNo)
                .frame(width: 30, alignment: .leading)

            if let onSortLength, let sortOrder {
                Button(action: onSortLength) {
                    HStack(spacing: 3) {
                        Text(L10n.Home.tableLength)
                        Image(systemName: sortOrder == .ascending ? "chevron.up" : "chevron.down")
                            .font(.system(size: 9, weight: .bold))
                    }
                }
                .buttonStyle(.plain)
                .frame(width: 60, alignment: .leading)
            } else {
                Text(L10n.Home.tableLength)
                    .frame(width: 44, alignment: .leading)
            }

            Text(L10n.Home.tableQty)
                .frame(width: 38, alignment: .leading)

            Text(L10n.Home.tableDiameter)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(L10n.Home.tableVol)
                .frame(width: 64, alignment: .trailing)
            Text(L10n.Home.tableActions)
                .frame(width: 100, alignment: .trailing)
        }
        .font(.system(size: 11, weight: .bold))
        .foregroundStyle(KubajThemeColors.textSecondary(colorScheme))
        .textCase(.uppercase)
        .tracking(0.8)
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(KubajThemeColors.inputBackground(colorScheme).opacity(0.5))
    }
}

struct KubajLogTableRow: View {
    @Environment(\.colorScheme) private var colorScheme

    let rowNumber: Int
    let lengthM: Double
    let quantity: Int
    let diameterLabel: String
    let volumeM3: Double
    var lengthBandIndex: Int = 0
    let showsHollowBadge: Bool
    let showsLumberBadge: Bool
    let onIncrease: () -> Void
    let onDecrease: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            Text("\(rowNumber)")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(KubajThemeColors.textPrimary(colorScheme))
                .frame(width: 30, alignment: .leading)

            Text(DisplayFormatting.length(lengthM))
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(KubajThemeColors.textPrimary(colorScheme))
                .frame(width: 44, alignment: .leading)

            Text("\(quantity)")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(KubajThemeColors.textPrimary(colorScheme))
                .frame(width: 38, alignment: .leading)

            VStack(alignment: .leading, spacing: 3) {
                Text(diameterLabel)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(KubajThemeColors.textPrimary(colorScheme))

                if showsHollowBadge {
                    Text(L10n.Home.hollowBadge)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.orange)
                } else if showsLumberBadge {
                    Text(L10n.Home.lumberBadge)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.green)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Text(DisplayFormatting.volume(volumeM3))
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(KubajColor.primary)
                .frame(width: 64, alignment: .trailing)

            HStack(spacing: 6) {
                rowActionButton(systemName: "plus", tint: KubajColor.primary, action: onIncrease)
                rowActionButton(systemName: "minus", tint: KubajThemeColors.textSecondary(colorScheme), action: onDecrease)
                rowActionButton(
                    systemName: "trash",
                    tint: .red,
                    background: KubajColor.deleteActionBackground,
                    action: onDelete
                )
            }
            .frame(width: 100, alignment: .trailing)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(KubajThemeColors.lengthBandBackground(colorScheme, bandIndex: lengthBandIndex))
    }

    private func rowActionButton(
        systemName: String,
        tint: Color,
        background: Color? = nil,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(tint)
                .frame(width: 28, height: 28)
                .background(background ?? KubajThemeColors.inputBackground(colorScheme), in: RoundedRectangle(cornerRadius: 7))
        }
        .buttonStyle(.plain)
    }
}
