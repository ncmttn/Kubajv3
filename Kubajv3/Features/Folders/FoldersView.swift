import SwiftUI
import SwiftData

struct FoldersView: View {
    @Query(sort: \Folder.name) private var folders: [Folder]
    @Environment(\.colorScheme) private var colorScheme

    var onFolderSelected: (Folder) -> Void

    private var rootFolders: [Folder] {
        folders.filter { $0.parentFolder == nil }
    }

    private var selectableFolders: [(folder: Folder, path: String)] {
        FolderRecordCollector.folderOptions(from: rootFolders)
    }

    var body: some View {
        VStack(spacing: 0) {
            KubajHeader()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    KubajSectionHeader(
                        title: L10n.Folders.title,
                        subtitle: L10n.Folders.subtitle
                    )

                    if selectableFolders.isEmpty {
                        emptyState
                    } else {
                        VStack(spacing: 8) {
                            ForEach(selectableFolders, id: \.folder.persistentModelID) { option in
                                FolderBrowseRow(
                                    folder: option.folder,
                                    path: option.path,
                                    onSelect: onFolderSelected
                                )
                            }
                        }
                    }
                }
                .padding(.horizontal, KubajMetric.horizontalPadding)
                .padding(.top, 32)
                .padding(.bottom, 120)
            }
        }
        .background(KubajThemeColors.background(colorScheme))
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "folder")
                .font(.system(size: 40))
                .foregroundStyle(KubajThemeColors.textMuted(colorScheme))
            Text(L10n.Folders.emptyState)
                .font(.subheadline)
                .foregroundStyle(KubajThemeColors.textMuted(colorScheme))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 48)
    }
}

private struct FolderBrowseRow: View {
    @Environment(\.colorScheme) private var colorScheme

    let folder: Folder
    let path: String
    let onSelect: (Folder) -> Void

    private var recordCount: Int {
        folder.records.count
    }

    var body: some View {
        Button {
            onSelect(folder)
            HapticFeedback.light()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "folder.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(KubajColor.primary)

                VStack(alignment: .leading, spacing: 2) {
                    Text(path)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(KubajThemeColors.textPrimary(colorScheme))
                        .multilineTextAlignment(.leading)
                    Text(L10n.Folders.recordCount(recordCount))
                        .font(.system(size: 12))
                        .foregroundStyle(KubajThemeColors.textSecondary(colorScheme))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(KubajThemeColors.textMuted(colorScheme))
            }
            .padding(16)
            .background(KubajThemeColors.card(colorScheme), in: RoundedRectangle(cornerRadius: KubajMetric.cornerRadiusMedium))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    FoldersView { _ in }
        .modelContainer(for: [Folder.self, LogRecord.self], inMemory: true)
}
