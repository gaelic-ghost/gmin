//
//  ThreadContentView.swift
//  gmin
//
//  Created by Codex on 5/5/26.
//

/*
 The Content Pane is the center column of the NavigationSplitView
 */

import SwiftASB
import SwiftUI

struct ThreadContentView: View {
    @Bindable var model: GminCodexModel
    @State private var composerText = ""

    var body: some View {
        Group {
            if let message = model.startupErrorMessage {
                ThreadRuntimeErrorView(message: message)
                    .navigationTitle("Runtime")
            } else if model.isStarting {
                ContentUnavailableView(
                    "Starting Codex",
                    systemImage: "bolt.horizontal",
                    description: Text("SwiftASB is launching the local app-server, checking Codex CLI compatibility, and initializing the session."),
                )
                .navigationTitle("Runtime")
            } else if let thread = model.selectedThread {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        ThreadHeaderView(thread: thread)
                        ThreadRuntimeSummaryView(model: model)
                        SelectedThreadRuntimeView(model: model)
                        ActiveTurnSurfaceView(model: model)
                        RecentTurnsSurfaceView(model: model)
                        ThreadComposerView(model: model, text: $composerText)
                    }
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .padding(28)
                }
                .navigationTitle(thread.displayTitle)
                .navigationSubtitle(thread.projectInfo.displayName)
                .task(id: thread.id) {
                    await model.attachSelectedThreadIfNeeded()
                }
            } else {
                ContentUnavailableView(
                    "Select a Thread",
                    systemImage: "sidebar.left",
                    description: Text(model.isStarted ? "Choose a stored Codex thread from the sidebar or create a new one." : "The local Codex runtime has not started yet."),
                )
                .navigationTitle("Thread")
            }
        }
    }
}
