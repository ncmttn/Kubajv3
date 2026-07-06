import SwiftUI

struct HomeView: View {
    @State private var viewModel = HomeViewModel()
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color.accentColor.opacity(0.25),
                        Color.blue.opacity(0.15),
                        Color.clear,
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 16) {
                    inputSection
                    actionButtons
                    entryList
                }
                .padding()
            }
            .navigationTitle(L10n.App.name)
            .sheet(isPresented: $viewModel.isHollowSheetPresented) {
                HollowCalculationView { outer, inner, length, quantity in
                    viewModel.addHollowEntry(
                        outerDiameterCm: outer,
                        innerDiameterCm: inner,
                        lengthM: length,
                        quantity: quantity
                    )
                    HapticFeedback.medium()
                }
            }
            .sheet(isPresented: $viewModel.isFolderSelectionPresented) {
                FolderSelectionView { folder in
                    viewModel.saveEntries(to: folder, modelContext: modelContext)
                    HapticFeedback.heavy()
                }
            }
        }
    }

    private var inputSection: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                inputField(
                    title: L10n.Home.diameterCm,
                    text: $viewModel.diameterInput,
                    keyboard: .decimalPad
                )
                inputField(
                    title: L10n.Home.lengthM,
                    text: $viewModel.lengthInput,
                    keyboard: .decimalPad
                )
                inputField(
                    title: L10n.Home.quantity,
                    text: $viewModel.quantityInput,
                    keyboard: .numberPad
                )
            }

            Button {
                viewModel.addEntryFromInput()
                HapticFeedback.light()
            } label: {
                Text(L10n.Home.addEntry)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .glassCard(material: .regularMaterial)
    }

    private var actionButtons: some View {
        HStack(spacing: 12) {
            Button {
                viewModel.isHollowSheetPresented = true
            } label: {
                Text(L10n.Home.calculateHollow)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
            }
            .buttonStyle(.bordered)
            .glassCard()

            Button {
                viewModel.isFolderSelectionPresented = true
            } label: {
                Text(L10n.Home.save)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
            }
            .buttonStyle(.borderedProminent)
            .disabled(!viewModel.canSave)
        }
    }

    private var entryList: some View {
        Group {
            if viewModel.sortedEntries.isEmpty {
                ContentUnavailableView {
                    Label(L10n.Home.emptyState, systemImage: "tree")
                }
                .glassCard()
            } else {
                List {
                    ForEach(viewModel.sortedEntries) { entry in
                        DraftLogEntryRow(entry: entry)
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    viewModel.deleteEntry(id: entry.id)
                                    HapticFeedback.heavy()
                                } label: {
                                    Text(L10n.Home.swipeDelete)
                                }

                                Button {
                                    viewModel.decreaseQuantity(id: entry.id)
                                    HapticFeedback.medium()
                                } label: {
                                    Text(L10n.Home.swipeDecrease)
                                }
                                .tint(.yellow)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button {
                                    viewModel.increaseQuantity(id: entry.id)
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
        .frame(maxHeight: .infinity)
    }

    private func inputField(
        title: String,
        text: Binding<String>,
        keyboard: UIKeyboardType
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            TextField(title, text: text)
                .keyboardType(keyboard)
                .textFieldStyle(.roundedBorder)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct DraftLogEntryRow: View {
    let entry: DraftLogEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(L10n.Home.dimensions(
                    diameter: entry.diameterCm,
                    length: entry.lengthM
                ))
                .font(.headline)

                Spacer()

                if entry.isHollow {
                    Text(L10n.Home.hollowBadge)
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.orange.opacity(0.2), in: Capsule())
                }
            }

            Text(L10n.Home.rowSummary(
                quantity: entry.quantity,
                volume: entry.totalVolumeM3
            ))
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        .padding()
        .glassCard()
    }
}

#Preview {
    HomeView()
        .modelContainer(for: [Folder.self, LogRecord.self], inMemory: true)
}
