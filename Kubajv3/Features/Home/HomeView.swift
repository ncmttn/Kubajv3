import SwiftUI

struct HomeView: View {
    @Bindable var viewModel: HomeViewModel
    var onViewFullHistory: () -> Void

    @Environment(\.modelContext) private var modelContext
    @Environment(AppPreferences.self) private var preferences

    var body: some View {
        VStack(spacing: 0) {
            homeHeader

            ScrollView {
                VStack(spacing: KubajMetric.sectionSpacing) {
                    inputSection
                    KubajPrimaryButton(
                        title: L10n.Home.calculate,
                        isEnabled: viewModel.canCalculate
                    ) {
                        viewModel.addEntryFromInput()
                        HapticFeedback.light()
                    }
                    KubajStatsCard(
                        totalVolume: DisplayFormatting.volume(viewModel.totalVolumeM3),
                        logsCount: "\(viewModel.totalLogsCount)",
                        averageDiameter: L10n.Home.diameterValue(viewModel.averageDiameterCm),
                        onReset: {
                            viewModel.clearAllEntries()
                            HapticFeedback.medium()
                        }
                    )
                    recentSection
                }
                .padding(.horizontal, KubajMetric.horizontalPadding)
                .padding(.top, KubajMetric.sectionSpacing)
                .padding(.bottom, 120)
            }
        }
        .background(KubajColor.background)
        .onAppear {
            viewModel.preferences = preferences
        }
        .sheet(isPresented: $viewModel.isFolderSelectionPresented) {
            FolderSelectionView { folder in
                viewModel.saveEntries(to: folder, modelContext: modelContext)
                HapticFeedback.heavy()
            }
        }
    }

    private var homeHeader: some View {
        HStack {
            HStack(spacing: 12) {
                Image(systemName: "tree.fill")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(KubajColor.primary)

                Text(L10n.App.name)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(KubajColor.textHeading)
                    .tracking(-1)
            }

            Spacer()

            Button {
                viewModel.isFolderSelectionPresented = true
            } label: {
                Image(systemName: "square.and.arrow.down")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(viewModel.canSave ? KubajColor.primary : KubajColor.textMuted)
                    .frame(width: 32, height: 32)
                    .background(KubajColor.inputBackground, in: Circle())
            }
            .disabled(!viewModel.canSave)
        }
        .padding(.horizontal, KubajMetric.horizontalPadding)
        .padding(.top, 16)
        .padding(.bottom, 17)
        .background(.ultraThinMaterial)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(KubajColor.borderSubtle)
                .frame(height: 1)
        }
    }

    private var inputSection: some View {
        HStack(alignment: .top, spacing: 12) {
            KubajInputField(
                title: L10n.Home.diameterCm,
                text: $viewModel.diameterInput,
                keyboard: .decimalPad,
                trailingActionTitle: L10n.Home.diameterIncrement,
                onTrailingAction: {
                    viewModel.incrementDiameter()
                    HapticFeedback.light()
                }
            )

            KubajInputField(
                title: L10n.Home.lengthM,
                text: $viewModel.lengthInput,
                keyboard: .decimalPad
            )

            KubajInputField(
                title: L10n.Home.quantity,
                text: $viewModel.quantityInput,
                keyboard: .numberPad
            )
        }
    }

    private var recentSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(L10n.Home.recentAdditions)
                    .font(KubajFont.sectionTitle())
                    .foregroundStyle(KubajColor.textHeading)

                Spacer()

                Text(L10n.Home.liveBadge)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(KubajColor.primary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(KubajColor.liveBadgeBackground, in: Capsule())
            }

            if viewModel.sortedEntries.isEmpty {
                Text(L10n.Home.emptyState)
                    .font(.subheadline)
                    .foregroundStyle(KubajColor.textMuted)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 32)
            } else {
                VStack(spacing: 0) {
                    tableHeader
                    ForEach(Array(viewModel.sortedEntries.enumerated()), id: \.element.id) { index, entry in
                        KubajDraftLogRow(
                            rowNumber: viewModel.sortedEntries.count - index,
                            entry: entry,
                            onIncrease: {
                                viewModel.increaseQuantity(id: entry.id)
                                HapticFeedback.light()
                            },
                            onDecrease: {
                                viewModel.decreaseQuantity(id: entry.id)
                                HapticFeedback.medium()
                            },
                            onDelete: {
                                viewModel.deleteEntry(id: entry.id)
                                HapticFeedback.heavy()
                            }
                        )
                        if index < viewModel.sortedEntries.count - 1 {
                            Divider()
                                .overlay(KubajColor.borderSubtle)
                        }
                    }
                }
                .background(KubajColor.surface, in: RoundedRectangle(cornerRadius: KubajMetric.cornerRadiusMedium))
            }

            Button(action: onViewFullHistory) {
                Text(L10n.Home.viewFullHistory)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(KubajColor.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
        }
    }

    private var tableHeader: some View {
        HStack(spacing: 0) {
            Text(L10n.Home.tableNo)
                .frame(width: 36, alignment: .leading)
            Text(L10n.Home.tableQty)
                .frame(width: 40, alignment: .leading)
            Text(L10n.Home.tableDim)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(L10n.Home.tableVol)
                .frame(width: 56, alignment: .trailing)
            Text(L10n.Home.tableActions)
                .frame(width: 88, alignment: .trailing)
        }
        .font(.system(size: 10, weight: .bold))
        .foregroundStyle(KubajColor.textSecondary)
        .textCase(.uppercase)
        .tracking(1)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(KubajColor.inputBackground.opacity(0.5))
    }
}

private struct KubajDraftLogRow: View {
    let rowNumber: Int
    let entry: DraftLogEntry
    let onIncrease: () -> Void
    let onDecrease: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            Text("\(rowNumber)")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(KubajColor.textPrimary)
                .frame(width: 36, alignment: .leading)

            Text("\(entry.quantity)")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(KubajColor.textPrimary)
                .frame(width: 40, alignment: .leading)

            VStack(alignment: .leading, spacing: 2) {
                Text(L10n.Home.dimFormat(
                    length: entry.lengthM,
                    diameter: entry.diameterCm
                ))
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(KubajColor.textPrimary)

                if entry.isHollow {
                    Text(L10n.Home.hollowBadge)
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.orange)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Text(DisplayFormatting.volume(entry.totalVolumeM3))
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(KubajColor.primary)
                .frame(width: 56, alignment: .trailing)

            HStack(spacing: 4) {
                rowActionButton(systemName: "plus", tint: KubajColor.primary, action: onIncrease)
                rowActionButton(systemName: "minus", tint: KubajColor.textSecondary, action: onDecrease)
                rowActionButton(
                    systemName: "trash",
                    tint: .red,
                    background: KubajColor.deleteActionBackground,
                    action: onDelete
                )
            }
            .frame(width: 88, alignment: .trailing)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
    }

    private func rowActionButton(
        systemName: String,
        tint: Color,
        background: Color = KubajColor.inputBackground,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(tint)
                .frame(width: 24, height: 24)
                .background(background, in: RoundedRectangle(cornerRadius: 6))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HomeView(viewModel: HomeViewModel(), onViewFullHistory: {})
        .environment(AppPreferences.shared)
        .modelContainer(for: [Folder.self, LogRecord.self], inMemory: true)
}
