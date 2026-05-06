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

    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            headerSection
            tagStatusIndicator
            assignTagButton
            Spacer()
        }
        .padding(24)
        .sheet(isPresented: $showingTagAssignment) {
            TagAssignmentView(appState: appState)
        }
    }

    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "wave.3.right.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(.tint)
            Text("A Way Out")
                .font(.largeTitle.bold())
        }
    }

    private var tagStatusIndicator: some View {
        Group {
            if appState.assignedTagUID != nil {
                Label("Tag Registered", systemImage: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                    .font(.headline)
            } else {
                Label("No Tag Assigned", systemImage: "tag.slash")
                    .foregroundStyle(.secondary)
                    .font(.headline)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private var assignTagButton: some View {
        Button {
            showingTagAssignment = true
        } label: {
            Label(
                appState.assignedTagUID == nil ? "Assign NFC Tag" : "Manage NFC Tag",
                systemImage: "tag"
            )
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
    }
}

#Preview {
    ContentView()
}
