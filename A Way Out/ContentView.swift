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
        VStack(spacing: 16) {
            Text("A Way Out")
                .font(.largeTitle.bold())
            Button(appState.assignedTagUID == nil ? "Tap to assign a tag" : "Assign a new tag") {
                showingTagAssignment = true
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .sheet(isPresented: $showingTagAssignment) {
            TagAssignmentView(appState: appState)
        }
    }
}

#Preview {
    ContentView()
}
