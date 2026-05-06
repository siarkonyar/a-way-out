//
//  TagAssignmentView.swift
//  A Way Out
//

import SwiftUI

struct TagAssignmentView: View {
    @ObservedObject var appState: AppState
    @StateObject private var nfcManager = NFCManager()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()
                tagStatusCard
                registerButton
                if let error = nfcManager.lastError {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                Spacer()
            }
            .padding(24)
            .navigationTitle("NFC Tag")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private var tagStatusCard: some View {
        VStack(spacing: 12) {
            if let uid = appState.assignedTagUID {
                Label("Tag Registered", systemImage: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                    .font(.headline)
                Text(uid)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle(.secondary)
            } else {
                Label("No Tag Assigned", systemImage: "tag.slash")
                    .foregroundStyle(.secondary)
                    .font(.headline)
                Text("Register your NFC tag to get started.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private var registerButton: some View {
        Button {
            nfcManager.startRegistration { uid in
                appState.assignTag(uid: uid)
            }
        } label: {
            Label(
                appState.assignedTagUID == nil ? "Register NFC Tag" : "Reassign NFC Tag",
                systemImage: "wave.3.right"
            )
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .disabled(nfcManager.isScanning)
    }
}

#Preview {
    TagAssignmentView(appState: AppState.shared)
}
