//
//  ContentView.swift
//  A Way Out
//
//  Created by Zafer Şiar Konyar on 05/05/2026.
//

import SwiftUI
import FamilyControls

struct ContentView: View {
    @StateObject private var appState = AppState.shared
    @StateObject private var nfcManager = NFCManager()
    @State private var showingTagAssignment = false
    @State private var nfcError: String? = nil
    @State private var showingNFCError = false

    private var blockedGroups: [AppGroup] {
        appState.appGroups.filter { appState.blockedGroupIDs.contains($0.id) }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                tagButton
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.horizontal, 24)
                    .padding(.top, 16)

                Spacer()

                if blockedGroups.isEmpty {
                    idleState
                } else {
                    blockedState
                }

                Spacer()

                NavigationLink {
                    AppGroupsView(appState: appState)
                } label: {
                    Text("Block Apps")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .sheet(isPresented: $showingTagAssignment) {
                TagAssignmentView(appState: appState)
            }
            .alert("Couldn't Unblock", isPresented: $showingNFCError) {
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
    }

    private var idleState: some View {
        VStack(spacing: 8) {
            Text("A Way Out")
                .font(.largeTitle.bold())
            Text("Use a physical NFC tag to block\ndistracting apps.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    private var blockedState: some View {
        VStack(spacing: 20) {
            Text("A Way Out")
                .font(.largeTitle.bold())

            VStack(spacing: 8) {
                ForEach(blockedGroups) { group in
                    HStack(spacing: 10) {
                        Image(systemName: "lock.fill")
                            .foregroundStyle(.red)
                            .font(.subheadline)
                        Text(group.name)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.primary)
                        Spacer()
                        let count = group.selection.applicationTokens.count
                        if count > 0 {
                            Text("\(count) app\(count == 1 ? "" : "s")")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 10))
                }
            }
            .padding(.horizontal, 24)

            Button {
                startUnblockScan()
            } label: {
                Group {
                    if nfcManager.isScanning {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Label("Tap tag to unblock", systemImage: "wave.3.right")
                            .font(.subheadline.weight(.medium))
                    }
                }
                .frame(height: 20)
            }
            .buttonStyle(.bordered)
            .controlSize(.regular)
            .disabled(nfcManager.isScanning)
        }
    }

    private func startUnblockScan() {
        guard appState.assignedTagUID != nil else {
            nfcError = "No NFC tag assigned. Tap the tag button above to assign one."
            showingNFCError = true
            return
        }
        nfcManager.startReading(
            alertMessage: "Hold your NFC tag near the top of your iPhone to unblock apps.",
            successMessage: "Apps unblocked!"
        ) { uid in
            guard uid == appState.assignedTagUID else {
                nfcError = "Wrong tag. Please tap the tag you assigned to this app."
                showingNFCError = true
                return
            }
            for group in blockedGroups {
                appState.deactivateBlocking(for: group.id)
            }
        }
    }

    private var tagButton: some View {
        Button {
            showingTagAssignment = true
        } label: {
            Label(
                appState.assignedTagUID == nil ? "Assign Tag" : "Tag Assigned",
                systemImage: appState.assignedTagUID == nil ? "tag" : "tag.fill"
            )
            .font(.subheadline)
        }
        .buttonStyle(.bordered)
        .controlSize(.small)
    }
}

#Preview {
    ContentView()
}
