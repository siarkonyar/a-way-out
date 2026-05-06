//
//  AppGroupCreationView.swift
//  A Way Out
//

import SwiftUI
import FamilyControls

struct AppGroupCreationView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var appState: AppState
    var editingGroup: AppGroup? = nil

    @State private var groupName = ""
    @State private var selection = FamilyActivitySelection()
    @State private var isPickerPresented = false
    @State private var authorizationError: String? = nil

    private var appCount: Int { selection.applicationTokens.count }
    private var categoryCount: Int { selection.categoryTokens.count }

    var body: some View {
        NavigationStack {
            Form {
                Section("Group Name") {
                    TextField("e.g. Social Media", text: $groupName)
                }
                Section("Apps") {
                    Button {
                        Task { await requestAuthorizationAndShowPicker() }
                    } label: {
                        HStack {
                            Text("Select Apps")
                            Spacer()
                            Text(selectionSummary)
                                .foregroundStyle(.secondary)
                                .font(.subheadline)
                        }
                    }
                    .foregroundStyle(.primary)
                    if let error = authorizationError {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }
            }
            .familyActivityPicker(isPresented: $isPickerPresented, selection: $selection)
            .navigationTitle(editingGroup == nil ? "New Group" : "Edit Group")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveGroup()
                        dismiss()
                    }
                    .disabled(groupName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear {
                if let group = editingGroup {
                    groupName = group.name
                    selection = group.selection
                }
            }
        }
    }

    private func requestAuthorizationAndShowPicker() async {
        do {
            try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
            authorizationError = nil
            isPickerPresented = true
        } catch {
            authorizationError = "Screen Time access is required to select apps."
        }
    }

    private var selectionSummary: String {
        if appCount == 0 && categoryCount == 0 { return "None" }
        var parts: [String] = []
        if appCount > 0 { parts.append("\(appCount) app\(appCount == 1 ? "" : "s")") }
        if categoryCount > 0 { parts.append("\(categoryCount) categor\(categoryCount == 1 ? "y" : "ies")") }
        return parts.joined(separator: ", ")
    }

    private func saveGroup() {
        let name = groupName.trimmingCharacters(in: .whitespaces)
        if let group = editingGroup {
            appState.updateGroup(AppGroup(id: group.id, name: name, selection: selection))
        } else {
            appState.addGroup(AppGroup(name: name, selection: selection))
        }
    }
}
