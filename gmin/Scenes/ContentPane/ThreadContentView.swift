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
    @State private var composerText = ""

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
                        selectedThreadRuntime
                        activeTurnSurface
                        recentTurnsSurface
                        composer
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

    private var selectedThreadRuntime: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Selected Thread")
                .font(.headline)

            if model.isLoadingSelectedThread {
                Label("SwiftASB is resuming the selected stored thread.", systemImage: "arrow.triangle.2.circlepath")
                    .foregroundStyle(.secondary)
            }

            if let message = model.selectedThreadErrorMessage {
                Label(message, systemImage: "exclamationmark.triangle")
                    .foregroundStyle(.yellow)
            }

            if let dashboard = model.selectedThreadDashboard {
                VStack(alignment: .leading, spacing: 8) {
                    Label(dashboard.status.type.displayName, systemImage: dashboard.status.systemImage)
                    Label("Tools \(dashboard.toolCallingStatus.displayName)", systemImage: "wrench.and.screwdriver")
                    Label("MCP \(dashboard.mcpCallingStatus.displayName)", systemImage: "point.3.connected.trianglepath.dotted")

                    if dashboard.isCompactingThreadContext {
                        Label("Compacting thread context", systemImage: "rectangle.compress.vertical")
                    }

                    if let diagnostic = dashboard.latestDiagnostic {
                        Label(diagnostic.displaySummary, systemImage: "exclamationmark.triangle")
                    }
                }
                .foregroundStyle(.secondary)
            } else if !model.isLoadingSelectedThread {
                Text("Select or create a stored thread to attach SwiftASB dashboard and history companions.")
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var activeTurnSurface: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Active Turn")
                    .font(.headline)

                Spacer()

                if model.activeTurn != nil {
                    Button {
                        Task { await model.interruptActiveTurn() }
                    } label: {
                        Label("Interrupt", systemImage: "stop.circle")
                    }
                }
            }

            if let minimap = model.activeTurnMinimap {
                VStack(alignment: .leading, spacing: 10) {
                    Label("Turn \(minimap.turnID)", systemImage: "bolt.horizontal.circle")
                        .font(.callout.weight(.semibold))

                    if let latestPlanUpdate = minimap.latestPlanUpdate {
                        VStack(alignment: .leading, spacing: 6) {
                            if let explanation = latestPlanUpdate.explanation {
                                Text(explanation)
                                    .foregroundStyle(.secondary)
                            }

                            ForEach(latestPlanUpdate.plan, id: \.step) { step in
                                Label(step.step, systemImage: step.status.systemImage)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }

                    if !minimap.callSnapshots.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            ForEach(minimap.callSnapshots) { call in
                                Label(call.displayName, systemImage: call.kind.systemImage)
                                    .foregroundStyle(call.status == .errored ? .yellow : .secondary)
                            }
                        }
                    }

                    if let delta = minimap.latestAgentMessageDelta {
                        Text(delta.delta)
                            .foregroundStyle(.primary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(14)
                .background(.quaternary, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            } else if let status = model.completedTurnStatusMessage {
                Label(status, systemImage: "checkmark.circle")
                    .foregroundStyle(.secondary)
            } else {
                Text("No turn is active. The composer below starts one SwiftASB turn in the selected thread.")
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var recentTurnsSurface: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Turns")
                .font(.headline)

            if let recentTurns = model.selectedThreadRecentTurns {
                if let error = recentTurns.lastLoadErrorDescription {
                    Label(error, systemImage: "exclamationmark.triangle")
                        .foregroundStyle(.yellow)
                }

                if recentTurns.turns.isEmpty {
                    ContentUnavailableView(
                        "No Turns Yet",
                        systemImage: "text.bubble",
                        description: Text("Send a message to create the first stored turn for this thread."),
                    )
                } else {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        ForEach(recentTurns.turns) { turn in
                            turnCard(turn)
                        }
                    }
                }
            } else if model.isLoadingSelectedThread {
                ProgressView("Loading recent turns")
            } else {
                Text("Recent turn history will appear after SwiftASB finishes resuming the selected thread.")
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var composer: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Composer")
                .font(.headline)

            TextEditor(text: $composerText)
                .font(.body)
                .frame(minHeight: 90)
                .padding(8)
                .background(.quaternary, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                .disabled(!model.canStartTurn)

            HStack {
                if model.isSubmittingTurn {
                    ProgressView()
                        .controlSize(.small)
                }

                Spacer()

                Button {
                    Task {
                        if await model.submitTextTurn(composerText) {
                            composerText = ""
                        }
                    }
                } label: {
                    Label("Send", systemImage: "paperplane")
                }
                .keyboardShortcut(.return, modifiers: [.command])
                .disabled(!model.canStartTurn || composerText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
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

    private func turnCard(_ turn: CodexThread.RecentTurns.TurnSnapshot) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label(turn.status.capitalized, systemImage: turn.status.systemImage)
                    .font(.callout.weight(.semibold))

                Spacer()

                if let completedDate = turn.completedDate {
                    Text(completedDate, format: .relative(presentation: .named))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            if let errorMessage = turn.errorMessage {
                Label(errorMessage, systemImage: "exclamationmark.triangle")
                    .foregroundStyle(.yellow)
            }

            ForEach(turn.items) { item in
                VStack(alignment: .leading, spacing: 4) {
                    Label(item.displayTitle, systemImage: item.systemImage)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)

                    if let body = item.displayBody {
                        Text(body)
                            .font(.callout)
                            .foregroundStyle(.primary)
                            .lineLimit(8)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }

            if turn.omittedItemCount > 0 {
                Label("\(turn.omittedItemCount) older low-detail items are outside the resident history window.", systemImage: "ellipsis.circle")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
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

private extension CodexThread.Dashboard.ActivityStatus {
    var displayName: String {
        switch self {
        case .errored:
            "need attention"
        case .idle:
            "idle"
        case .inProgress:
            "running"
        }
    }
}

private extension CodexDiagnosticEvent {
    var displaySummary: String {
        switch self {
        case let .warning(warning):
            warning.message
        case let .guardianWarning(warning):
            warning.message
        case let .modelRerouted(reroute):
            "Model rerouted from \(reroute.fromModel) to \(reroute.toModel)."
        case let .modelVerification(verification):
            "Model verification updated with \(verification.verifications.count) result(s)."
        case let .configWarning(warning):
            warning.summary
        case let .deprecationNotice(notice):
            notice.summary
        case let .mcpServerStatusChanged(status):
            status.error ?? "MCP server \(status.name) is \(status.status.rawValue)."
        case let .remoteControlStatusChanged(status):
            "Remote control is \(status.status.rawValue)."
        }
    }
}

private extension CodexTurnPlanUpdate.Step.Status {
    var systemImage: String {
        switch self {
        case .completed:
            "checkmark.circle"
        case .inProgress:
            "arrow.triangle.2.circlepath"
        case .pending:
            "circle"
        }
    }
}

private extension CodexTurnHandle.Minimap.CallSnapshot.Kind {
    var systemImage: String {
        switch self {
        case .collabTool:
            "person.2.wave.2"
        case .command:
            "terminal"
        case .dynamicTool:
            "wand.and.sparkles"
        case .fileEdit:
            "doc.badge.gearshape"
        case .mcp:
            "point.3.connected.trianglepath.dotted"
        }
    }
}

private extension CodexThread.RecentTurns.TurnSnapshot {
    var completedDate: Date? {
        completedAt.map { Date(timeIntervalSince1970: TimeInterval($0) / 1_000) }
    }
}

private extension CodexThread.RecentTurns.TurnSnapshot.Item {
    var displayTitle: String {
        switch kind {
        case "agentMessage":
            "Agent"
        case "userMessage":
            "You"
        case "commandExecution":
            command ?? "Command"
        case "fileChange":
            path ?? "File edit"
        case "mcpToolCall":
            if let serverName, let toolName {
                "\(serverName).\(toolName)"
            } else {
                toolName ?? "MCP tool"
            }
        default:
            toolName ?? kind
        }
    }

    var displayBody: String? {
        streamedText ?? text ?? status ?? command ?? path
    }

    var systemImage: String {
        switch kind {
        case "agentMessage":
            "sparkles"
        case "userMessage":
            "person.crop.circle"
        case "commandExecution":
            "terminal"
        case "fileChange":
            "doc.badge.gearshape"
        case "mcpToolCall":
            "point.3.connected.trianglepath.dotted"
        case "reasoning":
            "brain"
        case "plan":
            "checklist"
        default:
            "smallcircle.filled.circle"
        }
    }
}

private extension String {
    var systemImage: String {
        switch lowercased() {
        case "completed":
            "checkmark.circle"
        case "failed", "error", "errored":
            "exclamationmark.triangle"
        case "interrupted":
            "stop.circle"
        default:
            "circle.dotted"
        }
    }
}
