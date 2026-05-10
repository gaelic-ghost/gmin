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
import SwiftASB

struct ThreadContentView: View {
    @Bindable var model: GminCodexModel

    var body: some View {
        Group {
            if let message = model.startupErrorMessage {
                runtimeError(message)
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
                        threadHeader(thread)
                        runtimeSummary
                        transcriptPlaceholder(thread)
                    }
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .padding(28)
                }
                .navigationTitle(thread.displayTitle)
                .navigationSubtitle(thread.projectInfo.displayName)
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

    private var runtimeSummary: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("SwiftASB Runtime")
                .font(.headline)

            VStack(alignment: .leading, spacing: 8) {
                if let diagnostics = model.startupSession?.cliExecutableDiagnostics {
                    Label("Codex CLI \(diagnostics.versionString)", systemImage: "terminal")
                    Label(diagnostics.resolvedExecutablePath ?? "Selected executable path unavailable", systemImage: "location")
                }

                if let latestError = model.library?.latestErrorDescription {
                    Label(latestError, systemImage: "exclamationmark.triangle")
                }

                if let latestSnapshotError = model.library?.latestSnapshotErrorDescription {
                    Label(latestSnapshotError, systemImage: "exclamationmark.triangle")
                }

                if let actionError = model.actionErrorMessage {
                    Label(actionError, systemImage: "exclamationmark.triangle")
                }
            }
            .foregroundStyle(.secondary)
        }
    }

    private func threadHeader(_ thread: CodexAppServer.Library.ThreadSnapshot) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Label(thread.status.type.displayName, systemImage: thread.status.systemImage)
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(thread.status.type == .active ? .cyan : .secondary)

                Text(thread.updatedDate, format: .relative(presentation: .named))
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }

            Text(thread.preview.isEmpty ? "No preview is available for this stored Codex thread yet." : thread.preview)
                .font(.title3)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)

            Text(thread.currentDirectoryPath)
                .font(.callout)
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
    }

    private func transcriptPlaceholder(_ thread: CodexAppServer.Library.ThreadSnapshot) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Thread Surface")
                .font(.headline)

            Text("This thread is now selected from SwiftASB's stored-thread library. The next slice can resume the selected CodexThread and attach transcript, composer, active-turn controls, approvals, and history companions for “\(thread.displayTitle)”.")
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func runtimeError(_ message: String) -> some View {
        ContentUnavailableView(
            "Codex Runtime Unavailable",
            systemImage: "exclamationmark.triangle",
            description: Text(message),
        )
    }
}

private extension CodexAppServer.ThreadStatusType {
    var displayName: String {
        switch self {
        case .active:
            "Active"
        case .idle:
            "Idle"
        case .notLoaded:
            "Not Loaded"
        case .systemError:
            "System Error"
        }
    }
}
