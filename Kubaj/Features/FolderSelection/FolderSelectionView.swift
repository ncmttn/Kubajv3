import SwiftUI
import SwiftData

struct FolderSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Folder.name) private var folders: [Folder]

    @State private var selectedFolder: Folder?
    @State private var newFolderName = ""
    @State private var isCreatingFolder = false
    @State private var parentForNewFolder: Folder?

    let onSave: (Folder) -> Void

    private var rootFolders: [Folder] {
        folders.filter { $0.parentFolder == nil }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color.green.opacity(0.15),
                        Color.accentColor.opacity(0.1),
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 16) {
                    if rootFolders.isEmpty {
                        ContentUnavailableView {
                            Label(L10n.FolderSelection.noFolders, systemImage: "folder")
                        }
                        .glassCard()
                    } else {
                        List {
                            ForEach(rootFolders) { folder in
                                FolderTreeRow(
                                    folder: folder,
                                    selectedFolder: $selectedFolder,
                                    onCreateSubfolder: { parent in
                                        parentForNewFolder = parent
                                        isCreatingFolder = true
                                    }
                                )
                            }
                        }
                        .listStyle(.insetGrouped)
                        .scrollContentBackground(.hidden)
                    }

                    createFolderSection

                    Button {
                        guard let selectedFolder else {
                            return
                        }
                        onSave(selectedFolder)
                        dismiss()
                    } label: {
                        Text(L10n.FolderSelection.confirmSave)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(selectedFolder == nil)
                    .padding(.horizontal)
                }
            }
            .navigationTitle(L10n.FolderSelection.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.Common.cancel) {
                        dismiss()
                    }
                }
            }
            .alert(L10n.FolderSelection.createFolder, isPresented: $isCreatingFolder) {
                TextField(L10n.FolderSelection.namePlaceholder, text: $newFolderName)
                Button(L10n.Common.cancel, role: .cancel) {
                    newFolderName = ""
                    parentForNewFolder = nil
                }
                Button(L10n.FolderSelection.create) {
                    createFolder()
                }
            }
        }
    }

    private var createFolderSection: some View {
        HStack(spacing: 12) {
            Button {
                parentForNewFolder = nil
                isCreatingFolder = true
            } label: {
                Label(L10n.FolderSelection.createFolder, systemImage: "folder.badge.plus")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
            }
            .buttonStyle(.bordered)
            .glassCard()
        }
        .padding(.horizontal)
    }

    private func createFolder() {
        let trimmed = newFolderName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return
        }

        let folder = Folder(name: trimmed, parentFolder: parentForNewFolder)
        modelContext.insert(folder)
        try? modelContext.save()
        selectedFolder = folder
        newFolderName = ""
        parentForNewFolder = nil
        HapticFeedback.light()
    }
}

private struct FolderTreeRow: View {
    let folder: Folder
    @Binding var selectedFolder: Folder?
    let onCreateSubfolder: (Folder) -> Void

    var body: some View {
        DisclosureGroup {
            if folder.subFolders.isEmpty {
                Text(L10n.FolderSelection.noSubfolders)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(sortedSubfolders) { subfolder in
                    FolderTreeRow(
                        folder: subfolder,
                        selectedFolder: $selectedFolder,
                        onCreateSubfolder: onCreateSubfolder
                    )
                }
            }

            Button {
                onCreateSubfolder(folder)
            } label: {
                Label(L10n.FolderSelection.createSubfolder, systemImage: "folder.badge.plus")
            }
            .font(.caption)
        } label: {
            Button {
                selectedFolder = folder
                HapticFeedback.light()
            } label: {
                HStack {
                    Image(systemName: selectedFolder?.persistentModelID == folder.persistentModelID
                        ? "folder.fill"
                        : "folder")
                    Text(folder.name)
                        .fontWeight(
                            selectedFolder?.persistentModelID == folder.persistentModelID
                                ? .semibold
                                : .regular
                        )
                    Spacer()
                    if selectedFolder?.persistentModelID == folder.persistentModelID {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    }
                }
            }
            .buttonStyle(.plain)
        }
    }

    private var sortedSubfolders: [Folder] {
        folder.subFolders.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }
}

#Preview {
    FolderSelectionView { _ in }
        .modelContainer(for: [Folder.self, LogRecord.self], inMemory: true)
}
