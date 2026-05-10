//
//  ThreadSidebarView.swift
//  gmin
//
//  Created by Codex on 5/5/26.
//

/*
 The Sidebar Pane is the leading column of the NavigationSplitView
 */

import SwiftASB
import SwiftUI

struct ThreadSidebarView: View {
    @Bindable var model: GminCodexModel

    var body: some View {
        List(selection: selectedThreadID) {
            if let library = model.library {
                if library.isLoadingLocalSnapshot || library.isReconciling {
                    Section {
                        Label("Refreshing stored threads", systemImage: "arrow.triangle.2.circlepath")
                            .foregroundStyle(.secondary)
                    }
                }

                ForEach(library.groups) { group in
                    Section(group.title) {
                        ForEach(group.threads) { thread in
                            ThreadSidebarRow(thread: thread)
                        }
                    }
                }

                if library.unarchivedThreads.isEmpty {
                    Section {
                        ContentUnavailableView(
                            "No Stored Threads",
                            systemImage: "text.bubble",
                            description: Text("Create a thread to start a stored SwiftASB-backed workflow."),
                        )
                    }
                }
            } else {
                Section {
                    ContentUnavailableView(
                        model.isStarting ? "Starting Codex" : "Codex Not Ready",
                        systemImage: model.isStarting ? "bolt.horizontal" : "exclamationmark.triangle",
                        description: Text(model.startupErrorMessage ?? "SwiftASB is preparing the local app-server library."),
                    )
                }
            }
        }
        .navigationTitle("gmin")
    }

    private var selectedThreadID: Binding<String?> {
        Binding {
            model.library?.selectedThreadID
        } set: { threadID in
            model.selectThread(threadID)
        }
    }
}

private struct ThreadSidebarRow: View {
    var thread: CodexAppServer.Library.ThreadSnapshot

    var body: some View {
        Label {
            VStack(alignment: .leading, spacing: 3) {
                Text(thread.displayTitle)
                    .lineLimit(1)

                Text(thread.projectInfo.displayName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        } icon: {
            Image(systemName: thread.status.systemImage)
                .foregroundStyle(thread.status.type == .active ? .cyan : .secondary)
        }
        .tag(thread.id)
        .help("\(thread.displayTitle) in \(thread.projectInfo.displayName)")
    }
}
