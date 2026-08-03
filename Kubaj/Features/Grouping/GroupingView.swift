import SwiftUI
import SwiftData

struct GroupingView: View {
    @Bindable var homeViewModel: HomeViewModel
    @Binding var selectedFolder: Folder?

    @State private var viewModel = GroupingViewModel()
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    @Query(sort: \Folder.name) private var folders: [Folder]
    @State private var groupToDelete: LogGroup?
    @State private var showDeleteFileConfirmation = false
    @State private var showExportNamePrompt = false
    @State private var pendingExportKind: ExportKind?
    @State private var exportNameInput = ""

    private var rootFolders: [Folder] {
        folders.filter { $0.parentFolder == nil }
    }

    var body: some View {
        VStack(spacing: 0) {
            groupingHeader

            ScrollView {
                VStack(spacing: 24) {
                    folderPicker

                    if hasContent {
                        summaryCards
                        groupsTable
                    } else {
                        emptyState
                    }
                }
                .padding(.horizontal, KubajMetric.horizontalPadding)
                .padding(.top, 24)
                .padding(.bottom, 120)
            }
        }
        .background(KubajThemeColors.background(colorScheme))
        .onAppear {
            viewModel.selectedFolder = selectedFolder
            syncRecords()
        }
        .onChange(of: selectedFolder?.persistentModelID) { _, _ in
            viewModel.selectedFolder = selectedFolder
            syncRecords()
        }
        .onChange(of: homeViewModel.draftEntries.count) { _, _ in
            syncRecords()
        }
        .sheet(isPresented: $viewModel.isExportSettingsPresented, onDismiss: {
            viewModel.dismissExportCancellation()
        }) {
            if let kind = viewModel.pendingExportKind {
                ExportSettingsView(exportKind: kind) { metadata in
                    viewModel.completeExport(metadata: metadata)
                }
            }
        }
        .sheet(isPresented: $viewModel.isShareSheetPresented, onDismiss: {
            viewModel.shareURL = nil
        }) {
            if let shareURL = viewModel.shareURL {
                ShareSheet(items: [shareURL])
            }
        }
        .confirmationDialog(
            L10n.Home.confirmDeleteTitle,
            isPresented: Binding(
                get: { groupToDelete != nil },
                set: { if !$0 { groupToDelete = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button(L10n.Home.confirmDeleteAction, role: .destructive) {
                if let group = groupToDelete {
                    performDelete(for: group)
                }
                groupToDelete = nil
            }
            Button(L10n.Common.cancel, role: .cancel) {
                groupToDelete = nil
            }
        } message: {
            Text(L10n.Home.confirmDeleteMessage)
        }
        .confirmationDialog(
            L10n.Grouping.confirmDeleteFileTitle,
            isPresented: $showDeleteFileConfirmation,
            titleVisibility: .visible
        ) {
            Button(L10n.Grouping.deleteFile, role: .destructive) {
                performDeleteFile()
            }
            Button(L10n.Common.cancel, role: .cancel) {}
        } message: {
            Text(L10n.Grouping.confirmDeleteFileMessage)
        }
        .alert(L10n.Home.saveFileTitle, isPresented: $showExportNamePrompt) {
            TextField(L10n.Home.saveFilePlaceholder, text: $exportNameInput)
            Button(L10n.Common.cancel, role: .cancel) {
                pendingExportKind = nil
                exportNameInput = ""
            }
            Button(L10n.Home.saveFileConfirm) {
                confirmExportName()
            }
        } message: {
            Text(L10n.Home.saveFileMessage)
        }
    }

    private var hasContent: Bool {
        selectedFolder != nil || !homeViewModel.draftEntries.isEmpty
    }

    private var groupingHeader: some View {
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

            HStack(spacing: 8) {
                KubajHeaderActionButton(
                    systemImage: "doc.richtext.fill",
                    tint: Color(red: 0.9, green: 0.25, blue: 0.25),
                    isEnabled: viewModel.canExport
                ) {
                    requestExport(.pdf)
                }

                KubajHeaderActionButton(
                    systemImage: "tablecells.fill",
                    tint: Color(red: 0.15, green: 0.65, blue: 0.35),
                    isEnabled: viewModel.canExport
                ) {
                    requestExport(.xlsx)
                }

                KubajHeaderActionButton(
                    systemImage: "trash.fill",
                    isDestructive: true,
                    isEnabled: selectedFolder != nil
                ) {
                    showDeleteFileConfirmation = true
                }
            }
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

    private var summaryCards: some View {
        HStack(spacing: 16) {
            KubajStatTile(
                title: L10n.Grouping.totalVolume,
                value: L10n.Grouping.volumeValue(viewModel.totalVolumeM3),
                valueColor: KubajColor.primary
            )
            KubajStatTile(
                title: L10n.Grouping.logCount,
                value: "\(viewModel.totalLogsCount)"
            )
        }
    }

    private var folderOptions: [(folder: Folder, path: String)] {
        FolderRecordCollector.folderOptions(from: rootFolders)
    }

    private var groupsTable: some View {
        VStack(spacing: 0) {
            KubajLogTableHeader(
                sortOrder: viewModel.sortOrder,
                onSortLength: {
                    viewModel.toggleSortOrder()
                    HapticFeedback.light()
                }
            )

            if viewModel.groups.isEmpty {
                Text(L10n.Grouping.emptyState)
                    .font(.subheadline)
                    .foregroundStyle(KubajThemeColors.textMuted(colorScheme))
                    .padding(.vertical, 32)
            } else {
                let groups = viewModel.groups
                let lengthBands = LengthBandIndices.compute(for: groups.map(\.lengthM))
                ForEach(Array(groups.enumerated()), id: \.element.id) { index, group in
                    KubajLogTableRow(
                        rowNumber: index + 1,
                        lengthM: group.lengthM,
                        quantity: group.totalQuantity,
                        diameterLabel: LogEntryDisplay.diameterLabel(for: group),
                        volumeM3: group.totalVolumeM3,
                        lengthBandIndex: lengthBands[index],
                        showsHollowBadge: LogEntryDisplay.isHollow(group),
                        showsLumberBadge: LogEntryDisplay.isLumber(group),
                        onIncrease: { handleIncrease(for: group) },
                        onDecrease: { handleDecrease(for: group) },
                        onDelete: { groupToDelete = group }
                    )
                    if index < groups.count - 1 {
                        Divider()
                            .overlay(KubajThemeColors.borderSubtle(colorScheme))
                    }
                }
            }
        }
        .background(KubajThemeColors.surface(colorScheme), in: RoundedRectangle(cornerRadius: KubajMetric.cornerRadiusMedium))
    }

    private var folderPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(L10n.Grouping.selectFolder)
                .font(KubajFont.labelCaps())
                .foregroundStyle(KubajThemeColors.textSecondary(colorScheme))
                .textCase(.uppercase)
                .tracking(1)

            Menu {
                Button(L10n.Grouping.draftSession) {
                    selectedFolder = nil
                    viewModel.selectedFolder = nil
                    syncRecords()
                }
                ForEach(folderOptions, id: \.folder.persistentModelID) { option in
                    Button(option.path) {
                        selectedFolder = option.folder
                        viewModel.selectedFolder = option.folder
                        viewModel.refreshRecords()
                    }
                }
            } label: {
                HStack {
                    Text(selectedFolderTitle)
                        .font(KubajFont.inputValue())
                        .foregroundStyle(KubajThemeColors.textPrimary(colorScheme))
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(KubajThemeColors.textMuted(colorScheme))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(KubajThemeColors.inputBackground(colorScheme), in: RoundedRectangle(cornerRadius: KubajMetric.cornerRadiusMedium))
            }
        }
    }

    private var selectedFolderTitle: String {
        if selectedFolder == nil {
            return L10n.Grouping.draftSession
        }
        if let folder = selectedFolder {
            return folderOptions.first(where: { $0.folder.persistentModelID == folder.persistentModelID })?.path ?? folder.name
        }
        return L10n.Grouping.noFolderSelected
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "square.stack.3d.up.slash")
                .font(.system(size: 40))
                .foregroundStyle(KubajThemeColors.textMuted(colorScheme))
            Text(viewModel.selectedFolder == nil ? L10n.Grouping.draftEmptyState : L10n.Grouping.selectFolderPrompt)
                .font(.subheadline)
                .foregroundStyle(KubajThemeColors.textMuted(colorScheme))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 48)
    }

    private func syncRecords() {
        if viewModel.selectedFolder == nil {
            viewModel.records = homeViewModel.draftEntries.map { entry in
                LogRecord(
                    diameterCm: entry.diameterCm,
                    lengthM: entry.lengthM,
                    quantity: entry.quantity,
                    volumeM3: entry.volumeM3,
                    calculationMethod: entry.calculationMethod,
                    isHollow: entry.isHollow,
                    isLumber: entry.isLumber,
                    topDiameterCm: entry.topDiameterCm,
                    midDiameterCm: entry.midDiameterCm,
                    buttDiameterCm: entry.buttDiameterCm,
                    lumberThicknessCm: entry.lumberThicknessCm,
                    createdAt: entry.createdAt
                )
            }
        } else {
            viewModel.refreshRecords()
        }
    }

    private func handleIncrease(for group: LogGroup) {
        if viewModel.selectedFolder == nil {
            if let entry = matchingDraftEntry(for: group) {
                homeViewModel.increaseQuantity(id: entry.id)
                syncRecords()
            }
        } else {
            viewModel.increaseQuantity(for: group, modelContext: modelContext)
        }
        HapticFeedback.light()
    }

    private func handleDecrease(for group: LogGroup) {
        if viewModel.selectedFolder == nil {
            if let entry = matchingDraftEntry(for: group) {
                homeViewModel.decreaseQuantity(id: entry.id)
                syncRecords()
            }
        } else {
            viewModel.decreaseQuantity(for: group, modelContext: modelContext)
        }
        HapticFeedback.medium()
    }

    private func performDelete(for group: LogGroup) {
        if viewModel.selectedFolder == nil {
            homeViewModel.deleteEntries(diameterCm: group.diameterCm, lengthM: group.lengthM)
            syncRecords()
        } else {
            viewModel.deleteGroup(group, modelContext: modelContext)
        }
        HapticFeedback.heavy()
    }

    private func performDeleteFile() {
        guard let folder = selectedFolder else { return }
        viewModel.deleteFolder(folder, modelContext: modelContext)
        selectedFolder = nil
        HapticFeedback.heavy()
    }

    private func requestExport(_ kind: ExportKind) {
        if let folder = selectedFolder {
            viewModel.exportFileName = folder.name
            viewModel.beginExport(kind)
        } else {
            pendingExportKind = kind
            exportNameInput = ""
            showExportNamePrompt = true
        }
    }

    private func confirmExportName() {
        guard let kind = pendingExportKind else { return }
        viewModel.exportFileName = exportNameInput
        pendingExportKind = nil
        exportNameInput = ""
        viewModel.beginExport(kind)
    }

    private func matchingDraftEntry(for group: LogGroup) -> DraftLogEntry? {
        homeViewModel.draftEntries
            .filter { $0.diameterCm == group.diameterCm && $0.lengthM == group.lengthM }
            .max(by: { $0.createdAt < $1.createdAt })
    }
}

#Preview {
    GroupingView(homeViewModel: HomeViewModel(), selectedFolder: .constant(nil))
        .modelContainer(for: [Folder.self, LogRecord.self], inMemory: true)
}
