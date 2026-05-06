//
//  ContentView.swift
//  A Way Out
//
//  Created by Zafer Şiar Konyar on 05/05/2026.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var appState = AppState.shared
    @State private var showingTagAssignment = false

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
                    blockedGroupsList
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

    private var blockedGroupsList: some View {
        VStack(spacing: 16) {
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
