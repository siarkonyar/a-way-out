//
//  AppGroupsView.swift
//  A Way Out
//

import SwiftUI
import FamilyControls

struct AppGroupsView: View {
    @ObservedObject var appState: AppState
    @StateObject private var nfcManager = NFCManager()

    @State private var showingGroupCreation = false
    @State private var editingGroup: AppGroup? = nil
    @State private var selectedGroupID: UUID? = nil
    @State private var nfcError: String? = nil
    @State private var showingNFCError = false

    private var selectedGroup: AppGroup? {
        guard let id = selectedGroupID else { return nil }
        return appState.appGroups.first(where: { $0.id == id })
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: 12) {
                    if appState.appGroups.isEmpty {
                        emptyState
                    } else {
                        ForEach(appState.appGroups) { group in
                            GroupCard(
                                group: group,
                                isSelected: selectedGroupID == group.id,
                                isBlocked: appState.blockedGroupIDs.contains(group.id)
                            ) {
                                selectedGroupID = selectedGroupID == group.id ? nil : group.id
                            }
                            .contextMenu {
                                Button { editingGroup = group } label: {
                                    Label("Edit", systemImage: "pencil")
                                }
                                Button(role: .destructive) {
                                    appState.deleteGroup(id: group.id)
                                    if selectedGroupID == group.id { selectedGroupID = nil }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }

                    Button {
                        showingGroupCreation = true
                    } label: {
                        Label("New Group", systemImage: "plus")
                            .font(.subheadline.weight(.medium))
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.regular)
                    .padding(.top, appState.appGroups.isEmpty ? 0 : 4)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .padding(.bottom, selectedGroup != nil ? 80 : 0)
            }

            if let group = selectedGroup {
                blockButton(for: group)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 16)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.spring(duration: 0.3), value: selectedGroupID)
        .navigationTitle("Block Apps")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showingGroupCreation) {
            AppGroupCreationView(appState: appState)
        }
        .sheet(item: $editingGroup) { group in
            AppGroupCreationView(appState: appState, editingGroup: group)
        }
        .alert("Couldn't Complete", isPresented: $showingNFCError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(nfcError ?? "")
        }
        .onChange(of: nfcManager.lastError) { _, error in
            guard let error else { return }
            nfcError = error
            showingNFCError = true
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "square.3.layers.3d.slash")
                .font(.system(size: 52))
                .foregroundStyle(.secondary)
            Text("No App Groups")
                .font(.title2.bold())
            Text("Create a group to start blocking\ndistracting apps.")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }

    private func blockButton(for group: AppGroup) -> some View {
        let isBlocked = appState.blockedGroupIDs.contains(group.id)
        return Button {
            startNFCScan(groupID: group.id, blocking: !isBlocked)
        } label: {
            Group {
                if nfcManager.isScanning {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text(isBlocked ? "Unblock \"\(group.name)\"" : "Block \"\(group.name)\"")
                        .font(.headline)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 24)
        }
        .buttonStyle(.borderedProminent)
        .tint(isBlocked ? .orange : .red)
        .controlSize(.large)
        .disabled(nfcManager.isScanning)
    }

    private func startNFCScan(groupID: UUID, blocking: Bool) {
        guard appState.assignedTagUID != nil else {
            nfcError = "No NFC tag assigned. Go back and assign a tag first."
            showingNFCError = true
            return
        }
        let successMsg = blocking ? "Apps blocked!" : "Apps unblocked!"
        nfcManager.startReading(
            alertMessage: "Hold your NFC tag near the top of your iPhone.",
            successMessage: successMsg
        ) { uid in
            guard uid == appState.assignedTagUID else {
                nfcError = "Wrong tag. Please tap the tag you assigned to this app."
                showingNFCError = true
                return
            }
            if blocking {
                appState.activateBlocking(for: groupID)
            } else {
                appState.deactivateBlocking(for: groupID)
            }
            selectedGroupID = nil
        }
    }
}

struct GroupCard: View {
    let group: AppGroup
    let isSelected: Bool
    let isBlocked: Bool
    let onTap: () -> Void

    private var appCount: Int { group.selection.applicationTokens.count }
    private var categoryCount: Int { group.selection.categoryTokens.count }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(group.name)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if isBlocked {
                    Image(systemName: "lock.fill")
                        .foregroundStyle(.red)
                        .font(.subheadline)
                } else if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.accentColor)
                        .font(.title3)
                } else {
                    Image(systemName: "circle")
                        .foregroundStyle(.tertiary)
                        .font(.title3)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .background(cardBackground, in: RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }

    private var cardBackground: some ShapeStyle {
        if isSelected {
            return AnyShapeStyle(Color.accentColor.opacity(0.08))
        }
        return AnyShapeStyle(Material.regular)
    }

    private var subtitle: String {
        if appCount == 0 && categoryCount == 0 { return "No apps selected" }
        var parts: [String] = []
        if appCount > 0 { parts.append("\(appCount) app\(appCount == 1 ? "" : "s")") }
        if categoryCount > 0 { parts.append("\(categoryCount) categor\(categoryCount == 1 ? "y" : "ies")") }
        return parts.joined(separator: ", ")
    }
}
