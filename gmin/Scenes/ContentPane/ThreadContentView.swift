//
//  ThreadContentView.swift
//  gmin
//
//  Created by Codex on 5/5/26.
//

/*
 The Content Pane is the center column of the NavigationSplitView
 */

import SwiftUI

struct ThreadContentView: View {
    var thread: CodexThreadDraft?

    var body: some View {
        Group {
            if let thread {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        threadHeader(thread)
                        plannedWorkflow
                        transcriptPlaceholder(thread)
                    }
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .padding(28)
                }
                .navigationTitle(thread.title)
                .navigationSubtitle(thread.workspaceName)
            } else {
                ContentUnavailableView(
                    "Select a Thread",
                    systemImage: "sidebar.left",
                    description: Text("Choose a thread from the sidebar or create a new one."),
                )
                .navigationTitle("Thread")
            }
        }
    }

    private var plannedWorkflow: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("SwiftASB Attachment Plan")
                .font(.headline)

            VStack(alignment: .leading, spacing: 8) {
                Label("App model owns CodexAppServer startup and diagnostics.", systemImage: "bolt.horizontal")
                Label("Selected conversation owns one CodexThread.", systemImage: "text.bubble")
                Label("Active turn controls read CodexTurnHandle.minimap.", systemImage: "map")
                Label("Recent files, commands, and turns come from SwiftASB companions.", systemImage: "clock.arrow.trianglehead.counterclockwise.rotate.90")
            }
            .foregroundStyle(.secondary)
        }
    }

    private func threadHeader(_ thread: CodexThreadDraft) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Label(thread.status.rawValue, systemImage: thread.status.systemImage)
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(thread.status == .running ? .cyan : .secondary)

                Text(thread.updatedAt, format: .relative(presentation: .named))
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }

            Text(thread.summary)
                .font(.title3)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func transcriptPlaceholder(_ thread: CodexThreadDraft) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Thread Surface")
                .font(.headline)

            Text("This first slice is the native window structure. The next slice can replace this placeholder with the live SwiftASB-backed transcript, composer, active-turn controls, approvals, and readable runtime failures for “\(thread.title)”.")
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
