import SwiftUI
import SwiftData

struct GroupingView: View {
    @State private var viewModel = GroupingViewModel()
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Folder.name) private var folders: [Folder]

    private var rootFolders: [Folder] {
        folders.filter { $0.parentFolder == nil }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color.green.opacity(0.2),
                        Color.accentColor.opacity(0.1),
                        Color.clear,
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 16) {
                    folderPicker
                    sortAndExportBar
                    groupList
                }
                .padding()
            }
            .navigationTitle(L10n.Grouping.title)
            .onChange(of: viewModel.selectedFolder?.persistentModelID) { _, _ in
                viewModel.refreshRecords()
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
                .font(.caption)
                .foregroundStyle(.secondary)

            Picker(L10n.Grouping.selectFolder, selection: $viewModel.selectedFolder) {
                Text(L10n.Grouping.noFolderSelected)
                    .tag(Optional<Folder>.none)
                ForEach(folderOptions, id: \.folder.persistentModelID) { option in
                    Text(option.path).tag(Optional(option.folder))
                }
            }
            .pickerStyle(.menu)
        }
        .padding()
        .glassCard(material: .regularMaterial)
    }

    private var sortAndExportBar: some View {
        HStack(spacing: 12) {
            Button {
                viewModel.toggleSortOrder()
                HapticFeedback.light()
            } label: {
                Label(
                    viewModel.sortOrder == .ascending
                        ? L10n.Grouping.sortAscending
                        : L10n.Grouping.sortDescending,
                    systemImage: "arrow.up.arrow.down"
                )
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
            }
            .buttonStyle(.bordered)
            .glassCard()

            Button {
                viewModel.beginExport(.pdf)
            } label: {
                Text(L10n.Grouping.exportPDF)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
            }
            .buttonStyle(.borderedProminent)
            .disabled(!viewModel.canExport)

            Button {
                viewModel.beginExport(.csv)
            } label: {
                Text(L10n.Grouping.exportCSV)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
            }
            .buttonStyle(.bordered)
            .disabled(!viewModel.canExport)
            .glassCard()
        }
    }

    @ViewBuilder
    private var groupList: some View {
        if viewModel.selectedFolder == nil {
            ContentUnavailableView {
                Label(L10n.Grouping.selectFolderPrompt, systemImage: "folder")
            }
            .glassCard()
            .frame(maxHeight: .infinity)
        } else if viewModel.groups.isEmpty {
            ContentUnavailableView {
                Label(L10n.Grouping.emptyState, systemImage: "square.stack.3d.up.slash")
            }
            .glassCard()
            .frame(maxHeight: .infinity)
        } else {
            List {
                ForEach(viewModel.groups) { group in
                    GroupRow(group: group)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .swipeActions(edge: .leading, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                viewModel.deleteGroup(group, modelContext: modelContext)
                                HapticFeedback.heavy()
                            } label: {
                                Text(L10n.Home.swipeDelete)
                            }

                            Button {
                                viewModel.decreaseQuantity(for: group, modelContext: modelContext)
                                HapticFeedback.medium()
                            } label: {
                                Text(L10n.Home.swipeDecrease)
                            }
                            .tint(.yellow)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button {
                                viewModel.increaseQuantity(for: group, modelContext: modelContext)
                                HapticFeedback.light()
                            } label: {
                                Text(L10n.Home.swipeIncrease)
                            }
                            .tint(.green)
                        }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        }
    }
}

private struct GroupRow: View {
    let group: LogGroup

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(L10n.Home.dimensions(diameter: group.diameterCm, length: group.lengthM))
                .font(.headline)
            Text(L10n.Grouping.rowSummary(
                quantity: group.totalQuantity,
                volume: group.totalVolumeM3,
                recordCount: group.records.count
            ))
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        .padding()
        .glassCard()
    }
}

#Preview {
    GroupingView()
        .modelContainer(for: [Folder.self, LogRecord.self], inMemory: true)
}
