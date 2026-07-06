import SwiftUI
import SwiftData

struct GroupingView: View {
    @Bindable var homeViewModel: HomeViewModel

    @State private var viewModel = GroupingViewModel()
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Folder.name) private var folders: [Folder]

    private var rootFolders: [Folder] {
        folders.filter { $0.parentFolder == nil }
    }

    var body: some View {
        VStack(spacing: 0) {
            KubajHeader()

            ScrollView {
                VStack(spacing: 40) {
                    KubajSectionHeader(
                        overline: L10n.Grouping.overline,
                        title: L10n.Grouping.title,
                        subtitle: L10n.Grouping.subtitle
                    )

                    folderPicker

                    if hasContent {
                        statsGrid
                        groupsTable
                        exportCard
                    } else {
                        emptyState
                    }
                }
                .padding(.horizontal, KubajMetric.horizontalPadding)
                .padding(.top, 32)
                .padding(.bottom, 120)
            }
        }
        .background(KubajColor.background)
        .onAppear {
            syncRecords()
        }
        .onChange(of: viewModel.selectedFolder?.persistentModelID) { _, _ in
            viewModel.refreshRecords()
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
    }

    private var hasContent: Bool {
        viewModel.selectedFolder != nil || !homeViewModel.draftEntries.isEmpty
    }

    private var folderOptions: [(folder: Folder, path: String)] {
        rootFolders.flatMap { folderPathEntries(from: $0, prefix: "") }
    }

    private func folderPathEntries(from folder: Folder, prefix: String) -> [(Folder, String)] {
        let path = prefix.isEmpty ? folder.name : "\(prefix) / \(folder.name)"
        var entries: [(Folder, String)] = [(folder, path)]
        let sortedSubfolders = folder.subFolders.sorted {
            $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
        }
        for subfolder in sortedSubfolders {
            entries.append(contentsOf: folderPathEntries(from: subfolder, prefix: path))
        }
        return entries
    }

    private var folderPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(L10n.Grouping.selectFolder)
                .font(KubajFont.labelCaps())
                .foregroundStyle(KubajColor.textSecondary)
                .textCase(.uppercase)
                .tracking(1)

            Menu {
                Button(L10n.Grouping.draftSession) {
                    viewModel.selectedFolder = nil
                    syncRecords()
                }
                ForEach(folderOptions, id: \.folder.persistentModelID) { option in
                    Button(option.path) {
                        viewModel.selectedFolder = option.folder
                        viewModel.refreshRecords()
                    }
                }
            } label: {
                HStack {
                    Text(selectedFolderTitle)
                        .font(KubajFont.inputValue())
                        .foregroundStyle(KubajColor.textPrimary)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(KubajColor.textMuted)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(KubajColor.inputBackground, in: RoundedRectangle(cornerRadius: KubajMetric.cornerRadiusMedium))
            }
        }
    }

    private var selectedFolderTitle: String {
        if viewModel.selectedFolder == nil {
            return L10n.Grouping.draftSession
        }
        if let folder = viewModel.selectedFolder {
            return folderOptions.first(where: { $0.folder.persistentModelID == folder.persistentModelID })?.path ?? folder.name
        }
        return L10n.Grouping.noFolderSelected
    }

    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            KubajStatTile(
                title: L10n.Grouping.totalVolume,
                value: L10n.Grouping.volumeValue(viewModel.totalVolumeM3),
                valueColor: KubajColor.primary
            )
            KubajStatTile(
                title: L10n.Grouping.activeBatches,
                value: "\(viewModel.activeBatchCount)"
            )
            KubajStatTile(
                title: L10n.Grouping.avgDiameter,
                value: L10n.Home.diameterValue(viewModel.averageDiameterCm)
            )
            KubajStatTile(
                title: L10n.Grouping.logCount,
                value: "\(viewModel.totalLogsCount)"
            )
        }
    }

    private var groupsTable: some View {
        VStack(spacing: 0) {
            tableHeader

            if viewModel.diameterSections.isEmpty {
                Text(L10n.Grouping.emptyState)
                    .font(.subheadline)
                    .foregroundStyle(KubajColor.textMuted)
                    .padding(.vertical, 32)
            } else {
                ForEach(viewModel.diameterSections) { section in
                    diameterSectionView(section)
                }
            }
        }
        .padding(.bottom, 24)
        .background(KubajColor.surface, in: RoundedRectangle(cornerRadius: 32))
    }

    private var tableHeader: some View {
        HStack {
            sortableHeader(L10n.Grouping.columnDiameter, togglesDiameter: true)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(L10n.Grouping.columnLength)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(L10n.Grouping.columnQuantity)
                .frame(maxWidth: .infinity, alignment: .trailing)
            Text(L10n.Grouping.columnVolume)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .font(.system(size: 10, weight: .bold))
        .foregroundStyle(KubajColor.textSecondary)
        .textCase(.uppercase)
        .tracking(1)
        .padding(.horizontal, 32)
        .padding(.vertical, 20)
    }

    private func sortableHeader(_ title: String, togglesDiameter: Bool) -> some View {
        Button {
            if togglesDiameter {
                viewModel.toggleSortOrder()
                HapticFeedback.light()
            }
        } label: {
            HStack(spacing: 4) {
                Text(title)
                Image(systemName: viewModel.sortOrder == .ascending ? "chevron.up" : "chevron.down")
                    .font(.system(size: 8, weight: .bold))
            }
        }
        .buttonStyle(.plain)
    }

    private func diameterSectionView(_ section: DiameterSection) -> some View {
        VStack(spacing: 4) {
                    ForEach(section.groups) { group in
                        GroupRow(
                            group: group,
                            onIncrease: {
                                handleIncrease(for: group)
                            },
                            onDecrease: {
                                handleDecrease(for: group)
                            },
                            onDelete: {
                                handleDelete(for: group)
                            }
                        )
                    }

            sectionSummary(section)
        }
        .padding(.top, section.id == viewModel.diameterSections.first?.id ? 0 : 32)
    }

    private func sectionSummary(_ section: DiameterSection) -> some View {
        HStack {
            Text(L10n.Grouping.sectionSummary(diameter: section.diameterCm))
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(KubajColor.textMuted)
                .textCase(.uppercase)

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(L10n.Grouping.summaryLogs)
                    .font(.system(size: 9, weight: .regular))
                    .foregroundStyle(KubajColor.textSecondary)
                    .textCase(.uppercase)
                Text("\(section.totalLogs)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(KubajColor.textPrimary)
            }

            VStack(alignment: .trailing, spacing: 2) {
                Text(L10n.Grouping.summaryVolume)
                    .font(.system(size: 9, weight: .regular))
                    .foregroundStyle(KubajColor.textSecondary)
                    .textCase(.uppercase)
                Text(L10n.Grouping.volumeValue(section.totalVolumeM3))
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(KubajColor.textPrimary)
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(KubajColor.borderSubtle)
                .frame(height: 1)
        }
    }

    private var exportCard: some View {
        Button {
            viewModel.beginExport(.csv)
        } label: {
            ZStack(alignment: .bottomLeading) {
                RoundedRectangle(cornerRadius: 32)
                    .fill(
                        LinearGradient(
                            colors: [KubajColor.primary.opacity(0.9), KubajColor.primary.opacity(0.4)],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .frame(height: 200)
                    .overlay {
                        Image(systemName: "tree.fill")
                            .font(.system(size: 80))
                            .foregroundStyle(.white.opacity(0.15))
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                            .padding(24)
                    }

                VStack(alignment: .leading, spacing: 8) {
                    Text(L10n.Grouping.exportCardTitle)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.white)
                    Text(L10n.Grouping.exportCardSubtitle)
                        .font(.system(size: 14))
                        .foregroundStyle(.white.opacity(0.8))
                        .multilineTextAlignment(.leading)
                }
                .padding(32)
            }
        }
        .buttonStyle(.plain)
        .disabled(!viewModel.canExport)
        .opacity(viewModel.canExport ? 1 : 0.5)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "square.stack.3d.up.slash")
                .font(.system(size: 40))
                .foregroundStyle(KubajColor.textMuted)
            Text(viewModel.selectedFolder == nil ? L10n.Grouping.draftEmptyState : L10n.Grouping.selectFolderPrompt)
                .font(.subheadline)
                .foregroundStyle(KubajColor.textMuted)
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

    private func handleDelete(for group: LogGroup) {
        if viewModel.selectedFolder == nil {
            homeViewModel.draftEntries.removeAll {
                $0.diameterCm == group.diameterCm && $0.lengthM == group.lengthM
            }
            syncRecords()
        } else {
            viewModel.deleteGroup(group, modelContext: modelContext)
        }
        HapticFeedback.heavy()
    }

    private func matchingDraftEntry(for group: LogGroup) -> DraftLogEntry? {
        homeViewModel.draftEntries
            .filter { $0.diameterCm == group.diameterCm && $0.lengthM == group.lengthM }
            .max(by: { $0.createdAt < $1.createdAt })
    }
}

private struct GroupRow: View {
    let group: LogGroup
    let onIncrease: () -> Void
    let onDecrease: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack {
            Text(L10n.Home.diameterValue(group.diameterCm))
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(KubajColor.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(L10n.Grouping.lengthValue(group.lengthM))
                .font(.system(size: 16))
                .foregroundStyle(KubajColor.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("\(group.totalQuantity)")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(KubajColor.textPrimary)
                .frame(maxWidth: .infinity, alignment: .trailing)

            Text(DisplayFormatting.volume(group.totalVolumeM3))
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(KubajColor.primary)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(24)
        .background(Color.white, in: RoundedRectangle(cornerRadius: KubajMetric.cornerRadiusMedium))
        .padding(.horizontal, 16)
        .contextMenu {
            Button(L10n.Home.swipeIncrease, action: onIncrease)
            Button(L10n.Home.swipeDecrease, action: onDecrease)
            Button(L10n.Home.swipeDelete, role: .destructive, action: onDelete)
        }
    }
}

#Preview {
    GroupingView(homeViewModel: HomeViewModel())
        .modelContainer(for: [Folder.self, LogRecord.self], inMemory: true)
}
