import SwiftUI

struct HomeView: View {
    @Bindable var viewModel: HomeViewModel
    var onViewFullHistory: () -> Void

    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    @Environment(AppPreferences.self) private var preferences

    @State private var isHollowPresented = false
    @State private var showClearConfirm = false
    @State private var entryToDelete: UUID?

    var body: some View {
        VStack(spacing: 0) {
            homeHeader

            ScrollView {
                VStack(spacing: KubajMetric.sectionSpacing) {
                    inputSection
                    calculateActions
                    KubajStatsCard(
                        totalVolume: DisplayFormatting.volume(viewModel.totalVolumeM3),
                        logsCount: "\(viewModel.totalLogsCount)",
                        averageDiameter: L10n.Home.diameterValue(viewModel.averageDiameterCm),
                        onReset: {
                            showClearConfirm = true
                        }
                    )
                    recentSection
                }
                .padding(.horizontal, KubajMetric.horizontalPadding)
                .padding(.top, KubajMetric.sectionSpacing)
                .padding(.bottom, 120)
            }
        }
        .background(KubajThemeColors.background(colorScheme))
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button(L10n.Home.keyboardNext) {
                    advanceFocus()
                }
                .fontWeight(.semibold)
            }
        }
        .onAppear {
            viewModel.preferences = preferences
        }
        .onChange(of: preferences.defaultCalculationMethod) { _, _ in
            viewModel.focusedInputField = viewModel.primaryDiameterField
        }
        .onChange(of: isHollowPresented) { _, presented in
            if presented {
                viewModel.focusedInputField = nil
            }
        }
        .onChange(of: viewModel.isFolderSelectionPresented) { _, presented in
            if presented {
                viewModel.focusedInputField = nil
            }
        }
        .sheet(isPresented: $viewModel.isFolderSelectionPresented) {
            FolderSelectionView { folder in
                viewModel.saveEntries(to: folder, modelContext: modelContext)
                HapticFeedback.heavy()
            }
        }
        .sheet(isPresented: $isHollowPresented) {
            HollowCalculationView(
                onAdd: { outer, inner, length, quantity in
                    viewModel.addHollowEntry(
                        outerDiameterCm: outer,
                        innerDiameterCm: inner,
                        lengthM: length,
                        quantity: quantity
                    )
                    HapticFeedback.medium()
                },
                onAddDiameter: { diameter, length, quantity in
                    viewModel.addEquivalentEntry(
                        diameterCm: diameter,
                        lengthM: length,
                        quantity: quantity
                    )
                    HapticFeedback.medium()
                }
            )
        }
        .confirmationDialog(
            L10n.Home.confirmClearTitle,
            isPresented: $showClearConfirm,
            titleVisibility: .visible
        ) {
            Button(L10n.Home.confirmClearAction, role: .destructive) {
                viewModel.clearAllEntries()
                HapticFeedback.medium()
            }
            Button(L10n.Common.cancel, role: .cancel) {}
        } message: {
            Text(L10n.Home.confirmClearMessage)
        }
        .confirmationDialog(
            L10n.Home.confirmDeleteTitle,
            isPresented: Binding(
                get: { entryToDelete != nil },
                set: { if !$0 { entryToDelete = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button(L10n.Home.confirmDeleteAction, role: .destructive) {
                if let id = entryToDelete {
                    viewModel.deleteEntry(id: id)
                    HapticFeedback.heavy()
                }
                entryToDelete = nil
            }
            Button(L10n.Common.cancel, role: .cancel) {
                entryToDelete = nil
            }
        } message: {
            Text(L10n.Home.confirmDeleteMessage)
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
                    .foregroundStyle(KubajThemeColors.textHeading(colorScheme))
                    .tracking(-1)
            }

            Spacer()

            Button {
                viewModel.isFolderSelectionPresented = true
            } label: {
                Image(systemName: "square.and.arrow.down")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(viewModel.canSave ? KubajColor.primary : KubajThemeColors.textMuted(colorScheme))
                    .frame(width: 32, height: 32)
                    .background(KubajThemeColors.inputBackground(colorScheme), in: Circle())
            }
            .disabled(!viewModel.canSave)
        }
        .padding(.horizontal, KubajMetric.horizontalPadding)
        .padding(.top, 16)
        .padding(.bottom, 17)
        .background(.ultraThinMaterial)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(KubajThemeColors.borderSubtle(colorScheme))
                .frame(height: 1)
        }
    }

    private var inputSection: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            ForEach(viewModel.inputFieldsForCurrentFormula, id: \.self) { field in
                inputField(for: field)
            }
        }
    }

    @ViewBuilder
    private func inputField(for field: HomeInputField) -> some View {
        switch field {
        case .diameter:
            KubajInputField(
                title: L10n.Home.diameterCm,
                text: $viewModel.diameterInput,
                keyboard: .decimalPad,
                trailingActionTitle: L10n.Home.diameterIncrement,
                onTrailingAction: {
                    viewModel.incrementDiameter()
                    HapticFeedback.light()
                },
                isFocused: viewModel.focusedInputField == .diameter,
                selectAllOnFocus: true,
                returnKeyType: viewModel.nextField(after: .diameter) == nil ? .done : .next,
                onBeginEditing: {
                    viewModel.focusedInputField = .diameter
                    viewModel.shouldSelectAllOnDiameterFocus = false
                },
                onSubmit: { advanceFrom(.diameter) }
            )
        case .topDiameter:
            KubajInputField(
                title: L10n.Home.topDiameterCm,
                text: $viewModel.topDiameterInput,
                isFocused: viewModel.focusedInputField == .topDiameter,
                selectAllOnFocus: true,
                returnKeyType: viewModel.nextField(after: .topDiameter) == nil ? .done : .next,
                onBeginEditing: {
                    viewModel.focusedInputField = .topDiameter
                    viewModel.shouldSelectAllOnDiameterFocus = false
                },
                onSubmit: { advanceFrom(.topDiameter) }
            )
        case .buttDiameter:
            KubajInputField(
                title: L10n.Home.buttDiameterCm,
                text: $viewModel.buttDiameterInput,
                isFocused: viewModel.focusedInputField == .buttDiameter,
                selectAllOnFocus: true,
                returnKeyType: viewModel.nextField(after: .buttDiameter) == nil ? .done : .next,
                onBeginEditing: {
                    viewModel.focusedInputField = .buttDiameter
                },
                onSubmit: { advanceFrom(.buttDiameter) }
            )
        case .midDiameter:
            KubajInputField(
                title: L10n.Home.midDiameterCm,
                text: $viewModel.midDiameterInput,
                isFocused: viewModel.focusedInputField == .midDiameter,
                selectAllOnFocus: true,
                returnKeyType: viewModel.nextField(after: .midDiameter) == nil ? .done : .next,
                onBeginEditing: {
                    viewModel.focusedInputField = .midDiameter
                },
                onSubmit: { advanceFrom(.midDiameter) }
            )
        case .width:
            KubajInputField(
                title: L10n.Lumber.widthCm,
                text: $viewModel.widthInput,
                isFocused: viewModel.focusedInputField == .width,
                selectAllOnFocus: true,
                returnKeyType: viewModel.nextField(after: .width) == nil ? .done : .next,
                onBeginEditing: {
                    viewModel.focusedInputField = .width
                    viewModel.shouldSelectAllOnDiameterFocus = false
                },
                onSubmit: { advanceFrom(.width) }
            )
        case .thickness:
            KubajInputField(
                title: L10n.Lumber.thicknessCm,
                text: $viewModel.thicknessInput,
                isFocused: viewModel.focusedInputField == .thickness,
                selectAllOnFocus: true,
                returnKeyType: viewModel.nextField(after: .thickness) == nil ? .done : .next,
                onBeginEditing: {
                    viewModel.focusedInputField = .thickness
                },
                onSubmit: { advanceFrom(.thickness) }
            )
        case .length:
            KubajInputField(
                title: L10n.Home.lengthM,
                text: $viewModel.lengthInput,
                isFocused: viewModel.focusedInputField == .length,
                selectAllOnFocus: true,
                returnKeyType: viewModel.nextField(after: .length) == nil ? .done : .next,
                onBeginEditing: {
                    viewModel.focusedInputField = .length
                },
                onSubmit: { advanceFrom(.length) }
            )
        case .quantity:
            KubajInputField(
                title: L10n.Home.quantity,
                text: $viewModel.quantityInput,
                keyboard: .numberPad,
                isFocused: viewModel.focusedInputField == .quantity,
                selectAllOnFocus: true,
                returnKeyType: .done,
                onBeginEditing: {
                    viewModel.focusedInputField = .quantity
                },
                onSubmit: {
                    viewModel.focusedInputField = nil
                }
            )
        }
    }

    private var calculateActions: some View {
        HStack(spacing: 12) {
            KubajOutlineCapsuleButton(
                title: L10n.Home.calculateHollow,
                systemImage: "circle.dotted"
            ) {
                isHollowPresented = true
            }

            KubajPrimaryButton(
                title: L10n.Home.calculate,
                isEnabled: viewModel.canCalculate
            ) {
                viewModel.addEntryFromInput()
                HapticFeedback.light()
            }
        }
    }

    private var recentSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(L10n.Home.recentAdditions)
                    .font(KubajFont.sectionTitle())
                    .foregroundStyle(KubajThemeColors.textHeading(colorScheme))

                Spacer()
            }

            if viewModel.sortedEntries.isEmpty {
                Text(L10n.Home.emptyState)
                    .font(.subheadline)
                    .foregroundStyle(KubajThemeColors.textMuted(colorScheme))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 32)
            } else {
                VStack(spacing: 0) {
                    KubajLogTableHeader()
                    ForEach(Array(viewModel.sortedEntries.enumerated()), id: \.element.id) { index, entry in
                        KubajLogTableRow(
                            rowNumber: viewModel.sortedEntries.count - index,
                            lengthM: entry.lengthM,
                            quantity: entry.quantity,
                            diameterLabel: LogEntryDisplay.diameterLabel(for: entry),
                            volumeM3: entry.totalVolumeM3,
                            showsHollowBadge: LogEntryDisplay.isHollow(entry),
                            showsLumberBadge: LogEntryDisplay.isLumber(entry),
                            onIncrease: {
                                viewModel.increaseQuantity(id: entry.id)
                                HapticFeedback.light()
                            },
                            onDecrease: {
                                viewModel.decreaseQuantity(id: entry.id)
                                HapticFeedback.medium()
                            },
                            onDelete: {
                                entryToDelete = entry.id
                            }
                        )
                        if index < viewModel.sortedEntries.count - 1 {
                            Divider()
                                .overlay(KubajThemeColors.borderSubtle(colorScheme))
                        }
                    }
                }
                .background(KubajThemeColors.surface(colorScheme), in: RoundedRectangle(cornerRadius: KubajMetric.cornerRadiusMedium))
            }

            Button(action: onViewFullHistory) {
                Text(L10n.Home.openGrouping)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(KubajColor.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
        }
    }

    private func advanceFocus() {
        guard let current = viewModel.focusedInputField else {
            viewModel.focusedInputField = viewModel.inputFieldsForCurrentFormula.first
            return
        }
        advanceFrom(current)
    }

    private func advanceFrom(_ field: HomeInputField) {
        if let next = viewModel.nextField(after: field) {
            viewModel.focusedInputField = next
        } else {
            viewModel.focusedInputField = nil
        }
    }
}

#Preview {
    HomeView(viewModel: HomeViewModel(), onViewFullHistory: {})
        .environment(AppPreferences.shared)
        .modelContainer(for: [Folder.self, LogRecord.self], inMemory: true)
}
