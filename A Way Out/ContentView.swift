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
    @State private var showingTagAssignment = false
    @State private var showingGroupCreation = false
    @State private var editingGroup: AppGroup? = nil

    var body: some View {
        VStack(spacing: 0) {
            header
            groupsContent
            newGroupButton
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .sheet(isPresented: $showingTagAssignment) {
            TagAssignmentView(appState: appState)
        }
        .sheet(isPresented: $showingGroupCreation) {
            AppGroupCreationView(appState: appState)
        }
        .sheet(item: $editingGroup) { group in
            AppGroupCreationView(appState: appState, editingGroup: group)
        }
    }

    private var header: some View {
        HStack(alignment: .center) {
            Text("A Way Out")
                .font(.largeTitle.bold())
            Spacer()
            Button {
                showingTagAssignment = true
            } label: {
                Image(systemName: appState.assignedTagUID == nil ? "tag" : "tag.fill")
                    .font(.title2)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
        .padding(.bottom, 12)
    }

    @ViewBuilder
    private var groupsContent: some View {
        if appState.appGroups.isEmpty {
            emptyState
        } else {
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(appState.appGroups) { group in
                        GroupCard(group: group) {
                            editingGroup = group
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 8)
            }
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(32)
    }

    private var newGroupButton: some View {
        Button {
            showingGroupCreation = true
        } label: {
            Label("New Group", systemImage: "plus")
                .font(.headline)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
    }
}

struct GroupCard: View {
    let group: AppGroup
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
                Image(systemName: "chevron.right")
                    .foregroundStyle(.tertiary)
                    .font(.subheadline)
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
    }

    private var subtitle: String {
        if appCount == 0 && categoryCount == 0 { return "No apps selected" }
        var parts: [String] = []
        if appCount > 0 { parts.append("\(appCount) app\(appCount == 1 ? "" : "s")") }
        if categoryCount > 0 { parts.append("\(categoryCount) categor\(categoryCount == 1 ? "y" : "ies")") }
        return parts.joined(separator: ", ")
    }
}

#Preview {
    ContentView()
}
