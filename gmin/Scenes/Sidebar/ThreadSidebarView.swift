//
//  ThreadSidebarView.swift
//  gmin
//
//  Created by Codex on 5/5/26.
//

/*
 The Sidebare Pane is the leading column of the NavigationSplitView
 */

import SwiftUI

struct ThreadSidebarView: View {
    @Bindable var model: MainWindowModel

    var body: some View {
        List(selection: $model.selectedThreadID) {
            if !model.pinnedThreads.isEmpty {
                Section("Pinned") {
                    ForEach(model.pinnedThreads) { thread in
                        ThreadSidebarRow(thread: thread)
                    }
                }
            }

            Section("Threads") {
                if model.recentThreads.isEmpty {
                    ContentUnavailableView(
                        "No Threads",
                        systemImage: "text.bubble",
                        description: Text("Create a thread to start shaping the SwiftASB-backed workflow."),
                    )
                } else {
                    ForEach(model.recentThreads) { thread in
                        ThreadSidebarRow(thread: thread)
                    }
                }
            }
        }
        .navigationTitle("gmin")
    }
}

private struct ThreadSidebarRow: View {
    var thread: CodexThreadDraft

    var body: some View {
        Label {
            VStack(alignment: .leading, spacing: 3) {
                Text(thread.title)
                    .lineLimit(1)

                Text(thread.workspaceName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        } icon: {
            Image(systemName: thread.status.systemImage)
                .foregroundStyle(thread.status == .running ? .cyan : .secondary)
        }
        .tag(thread.id)
        .help("\(thread.title) in \(thread.workspaceName)")
    }
}
