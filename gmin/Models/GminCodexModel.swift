//
//  GminCodexModel.swift
//  gmin
//
//  Created by Codex on 5/10/26.
//

import Foundation
import Observation
import SwiftASB
import SwiftUI

@MainActor
@Observable
final class GminCodexModel {
    private let appServer = CodexAppServer()

    @ObservationIgnored
    private var turnCompletionTask: Task<Void, Never>?

    private(set) var library: CodexAppServer.Library?
    private(set) var startupSession: CodexAppServer.StartupSession?
    private(set) var startupErrorMessage: String?
    private(set) var actionErrorMessage: String?
    private(set) var selectedCodexThread: CodexThread?
    private(set) var selectedThreadDashboard: CodexThread.Dashboard?
    private(set) var selectedThreadRecentTurns: CodexThread.RecentTurns?
    private(set) var selectedThreadErrorMessage: String?
    private(set) var activeTurn: CodexTurnHandle?
    private(set) var completedTurnStatusMessage: String?
    private(set) var isStarting = false
    private(set) var isStarted = false
    private(set) var isLoadingSelectedThread = false
    private(set) var isSubmittingTurn = false

    var selectedThread: CodexAppServer.Library.ThreadSnapshot? {
        library?.selectedThread
    }

    var activeTurnMinimap: CodexTurnHandle.Minimap? {
        activeTurn?.minimap
    }

    var canStartTurn: Bool {
        isStarted
            && selectedCodexThread != nil
            && activeTurn == nil
            && !isLoadingSelectedThread
            && !isSubmittingTurn
    }

    var selectedThreadBadges: [InspectorBadge] {
        InspectorBadge.makeBadges(
            model: self,
            library: library,
            selectedThread: selectedThread
        )
    }

    deinit {
        turnCompletionTask?.cancel()
        let appServer = appServer
        Task { await appServer.stop() }
    }

    func startIfNeeded() async {
        guard !isStarting, !isStarted else { return }

        isStarting = true
        startupErrorMessage = nil
        actionErrorMessage = nil

        do {
            let session = try await appServer.start(
                .init(
                    clientInfo: .init(
                        name: "gmin",
                        title: "gmin",
                        version: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.1.0"
                    )
                )
            )
            startupSession = session

            library = try await appServer.makeLibrary(
                configuration: .init(
                    sortedBy: .turnFinishedNewestFirst,
                    groupedBy: .repository,
                    query: .unarchived(limit: 50),
                    mcpServerStatusRequest: .init(detail: .toolsAndAuthOnly)
                )
            )

            isStarted = true
        } catch {
            startupErrorMessage = Self.startupMessage(for: error)
            await appServer.stop()
            isStarted = false
            startupSession = nil
            library = nil
        }

        isStarting = false
    }

    func createThread() async {
        guard isStarted else {
            actionErrorMessage = "gmin cannot create a thread because the local Codex runtime is not ready."
            return
        }

        do {
            let thread = try await appServer.startThread(
                .init(
                    currentDirectoryPath: FileManager.default.currentDirectoryPath,
                    ephemeral: false,
                    serviceName: "gmin"
                )
            )
            await library?.refreshAll()
            library?.selectThread(thread.id)
            await attach(thread)
            actionErrorMessage = nil
        } catch {
            actionErrorMessage = "SwiftASB could not create a stored Codex thread: \(error.localizedDescription)"
        }
    }

    func selectThread(_ threadID: String?) {
        guard library?.selectedThreadID != threadID else { return }

        library?.selectThread(threadID)
        clearSelectedThreadHandle()
    }

    func attachSelectedThreadIfNeeded() async {
        guard isStarted else { return }
        guard let selectedThread else {
            clearSelectedThreadHandle()
            return
        }
        guard selectedCodexThread?.id != selectedThread.id else { return }

        await resumeSelectedThread(selectedThread)
    }

    func submitTextTurn(_ text: String) async -> Bool {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return false }

        if selectedCodexThread == nil {
            await attachSelectedThreadIfNeeded()
        }

        guard let thread = selectedCodexThread else {
            actionErrorMessage = "gmin cannot send a turn because no stored Codex thread is attached yet."
            return false
        }

        guard activeTurn == nil else {
            actionErrorMessage = "gmin cannot start another turn in \(selectedThread?.displayTitle ?? "the selected thread") because that thread already has active work."
            return false
        }

        isSubmittingTurn = true
        actionErrorMessage = nil
        completedTurnStatusMessage = nil

        do {
            let turn = try await thread.startTextTurn(trimmedText)
            activeTurn = turn
            observeCompletion(for: turn)
            isSubmittingTurn = false
            return true
        } catch {
            isSubmittingTurn = false
            actionErrorMessage = "SwiftASB could not start a turn in \(selectedThread?.displayTitle ?? "the selected thread"): \(error.localizedDescription)"
            return false
        }
    }

    func interruptActiveTurn() async {
        guard let activeTurn else { return }

        do {
            try await activeTurn.interrupt()
            actionErrorMessage = nil
        } catch {
            actionErrorMessage = "SwiftASB could not interrupt the active turn: \(error.localizedDescription)"
        }
    }

    func archiveSelectedThread() async {
        guard let selectedThread else { return }

        do {
            try await appServer.archiveThread(.init(threadID: selectedThread.id))
            await library?.refreshAll()
            actionErrorMessage = nil
        } catch {
            actionErrorMessage = "SwiftASB could not archive \(selectedThread.displayTitle): \(error.localizedDescription)"
        }
    }

    func unarchiveThread(id: String) async {
        do {
            _ = try await appServer.unarchiveThread(.init(threadID: id))
            await library?.refreshAll()
            library?.selectThread(id)
            actionErrorMessage = nil
        } catch {
            actionErrorMessage = "SwiftASB could not restore the archived thread: \(error.localizedDescription)"
        }
    }

    func refreshLibrary() async {
        await library?.refreshAll()
        await library?.refreshSelectedGitStatus()
    }

    private func resumeSelectedThread(_ selectedThread: CodexAppServer.Library.ThreadSnapshot) async {
        isLoadingSelectedThread = true
        selectedThreadErrorMessage = nil
        actionErrorMessage = nil
        clearSelectedThreadHandle()

        do {
            let thread = try await appServer.resumeThread(
                .init(
                    threadID: selectedThread.id,
                    currentDirectoryPath: selectedThread.currentDirectoryPath,
                    serviceName: "gmin"
                )
            )
            await attach(thread)
        } catch {
            selectedThreadErrorMessage = "SwiftASB could not resume \(selectedThread.displayTitle): \(error.localizedDescription)"
        }

        isLoadingSelectedThread = false
    }

    private func attach(_ thread: CodexThread) async {
        selectedCodexThread = thread
        selectedThreadDashboard = await thread.makeDashboard()

        do {
            selectedThreadRecentTurns = try await thread.makeRecentTurns(
                limit: 12,
                cachePolicy: .chatUI(pageSize: 12)
            )
            selectedThreadErrorMessage = nil
        } catch {
            selectedThreadRecentTurns = nil
            selectedThreadErrorMessage = "SwiftASB resumed \(selectedThread?.displayTitle ?? "the selected thread"), but could not load recent turn history: \(error.localizedDescription)"
        }
    }

    private func clearSelectedThreadHandle() {
        turnCompletionTask?.cancel()
        turnCompletionTask = nil
        selectedCodexThread = nil
        selectedThreadDashboard = nil
        selectedThreadRecentTurns = nil
        selectedThreadErrorMessage = nil
        activeTurn = nil
        completedTurnStatusMessage = nil
    }

    private func observeCompletion(for turn: CodexTurnHandle) {
        turnCompletionTask?.cancel()
        turnCompletionTask = Task { [weak self] in
            do {
                for try await event in turn.events {
                    if case .completed = event {
                        let closedTurn = try await turn.complete()
                        await self?.finishTurn(turnID: turn.turn.id, status: closedTurn.status)
                        return
                    }
                }
            } catch is CancellationError {
                return
            } catch {
                await self?.recordTurnCompletionError(turnID: turn.turn.id, error: error)
            }
        }
    }

    private func finishTurn(turnID: String, status: String) async {
        guard activeTurn?.turn.id == turnID else { return }

        activeTurn = nil
        completedTurnStatusMessage = "Turn \(turnID) finished with status \(status)."
        await refreshLibrary()
    }

    private func recordTurnCompletionError(turnID: String, error: Error) async {
        guard activeTurn?.turn.id == turnID else { return }

        activeTurn = nil
        actionErrorMessage = "SwiftASB could not finish reading turn \(turnID): \(error.localizedDescription)"
        await refreshLibrary()
    }

    private static func startupMessage(for error: Error) -> String {
        guard let startupError = error as? CodexAppServerStartupError else {
            return "SwiftASB could not start the local Codex runtime: \(error.localizedDescription)"
        }

        switch startupError {
        case let .codexCLINotFound(reason):
            return "SwiftASB could not find a compatible Codex CLI executable: \(reason)"
        case let .incompatibleCodexCLI(diagnostics):
            return "SwiftASB found Codex CLI \(diagnostics.versionString), but gmin requires a version inside SwiftASB's reviewed support window."
        case let .unknownCodexCLIVersion(diagnostics):
            return "SwiftASB found Codex CLI \(diagnostics.versionString), but could not parse the version string against SwiftASB's reviewed support window."
        case let .launchFailed(reason):
            return "SwiftASB found Codex but could not launch the app-server: \(reason)"
        case let .initializeFailed(reason):
            return "SwiftASB launched Codex but could not finish app-server initialization: \(reason)"
        }
    }
}

struct InspectorBadge: Identifiable, Hashable {
    let id: String
    var title: String
    var systemImage: String
    var detail: String
    var status: BadgeStatus

    enum BadgeStatus: String, Hashable {
        case neutral
        case good
        case warning
        case active

        var tint: Color {
            switch self {
            case .neutral:
                .secondary
            case .good:
                .green
            case .warning:
                .yellow
            case .active:
                .cyan
            }
        }
    }
}

extension InspectorBadge {
    static func makeBadges(
        model: GminCodexModel,
        library: CodexAppServer.Library?,
        selectedThread: CodexAppServer.Library.ThreadSnapshot?
    ) -> [Self] {
        [
            runtimeBadge(model: model),
            selectedThreadBadge(selectedThread),
            gitBadge(library: library),
            modelBadge(library: library),
            mcpBadge(library: library),
            hookBadge(library: library),
        ]
    }

    private static func runtimeBadge(model: GminCodexModel) -> Self {
        if let startupErrorMessage = model.startupErrorMessage {
            return .init(
                id: "runtime",
                title: "Runtime",
                systemImage: "exclamationmark.triangle",
                detail: startupErrorMessage,
                status: .warning
            )
        }

        if model.isStarting {
            return .init(
                id: "runtime",
                title: "Runtime",
                systemImage: "bolt.horizontal",
                detail: "SwiftASB is starting the local Codex app-server and validating the selected CLI.",
                status: .active
            )
        }

        if let diagnostics = model.startupSession?.cliExecutableDiagnostics {
            return .init(
                id: "runtime",
                title: "Runtime",
                systemImage: "bolt.horizontal.circle",
                detail: "Codex CLI \(diagnostics.versionString) is ready at \(diagnostics.resolvedExecutablePath ?? "the selected executable").",
                status: .good
            )
        }

        return .init(
            id: "runtime",
            title: "Runtime",
            systemImage: "bolt.horizontal",
            detail: "The local Codex runtime has not started yet.",
            status: .neutral
        )
    }

    private static func selectedThreadBadge(
        _ selectedThread: CodexAppServer.Library.ThreadSnapshot?
    ) -> Self {
        guard let selectedThread else {
            return .init(
                id: "thread",
                title: "Thread",
                systemImage: "text.bubble",
                detail: "Select a stored Codex thread to show its workspace and activity.",
                status: .neutral
            )
        }

        return .init(
            id: "thread",
            title: "Thread",
            systemImage: selectedThread.status.systemImage,
            detail: "\(selectedThread.displayTitle) in \(selectedThread.projectInfo.displayName).",
            status: selectedThread.status.badgeStatus
        )
    }

    private static func gitBadge(library: CodexAppServer.Library?) -> Self {
        guard let library else {
            return .init(
                id: "git",
                title: "Git",
                systemImage: "point.topleft.down.to.point.bottomright.curvepath",
                detail: "Git status will load after SwiftASB creates the app-wide library.",
                status: .neutral
            )
        }

        if let error = library.latestGitStatusErrorDescription {
            return .init(
                id: "git",
                title: "Git",
                systemImage: "exclamationmark.triangle",
                detail: error,
                status: .warning
            )
        }

        guard let status = library.selectedGitStatus else {
            return .init(
                id: "git",
                title: "Git",
                systemImage: "point.topleft.down.to.point.bottomright.curvepath",
                detail: "Select a thread with repository facts to show branch, SHA, remotes, and dirty-file counts.",
                status: .neutral
            )
        }

        let branch = status.repository?.branch ?? status.status.branch ?? "detached"
        let changed = status.status.changedFileCount
        let untracked = status.status.untrackedFileCount
        return .init(
            id: "git",
            title: "Git",
            systemImage: changed == 0 ? "checkmark.seal" : "point.topleft.down.to.point.bottomright.curvepath",
            detail: "\(branch) has \(changed) changed files and \(untracked) untracked files.",
            status: changed == 0 ? .good : .active
        )
    }

    private static func modelBadge(library: CodexAppServer.Library?) -> Self {
        guard let capabilities = library?.modelCapabilities else {
            return .init(
                id: "model",
                title: "Model",
                systemImage: "cpu",
                detail: "Model capability status will load with the app-wide SwiftASB snapshots.",
                status: .neutral
            )
        }

        return .init(
            id: "model",
            title: "Model",
            systemImage: "cpu",
            detail: "Model capabilities are loaded. Web search: \(capabilities.webSearch ? "available" : "unavailable"). Image generation: \(capabilities.imageGeneration ? "available" : "unavailable").",
            status: .good
        )
    }

    private static func mcpBadge(library: CodexAppServer.Library?) -> Self {
        let serverCount = library?.mcpServers.count ?? 0
        return .init(
            id: "mcp",
            title: "MCP",
            systemImage: "puzzlepiece.extension",
            detail: serverCount == 0 ? "No MCP server status has loaded yet." : "\(serverCount) configured MCP server statuses are loaded.",
            status: serverCount == 0 ? .neutral : .good
        )
    }

    private static func hookBadge(library: CodexAppServer.Library?) -> Self {
        guard let snapshot = library?.hookListSnapshot else {
            return .init(
                id: "hooks",
                title: "Hooks",
                systemImage: "link",
                detail: "Hook diagnostics will load with the app-wide SwiftASB snapshots.",
                status: .neutral
            )
        }

        return .init(
            id: "hooks",
            title: "Hooks",
            systemImage: snapshot.hasDiagnostics ? "exclamationmark.triangle" : "link",
            detail: snapshot.hasDiagnostics ? "Configured hook diagnostics need attention." : "Configured hook diagnostics are loaded with no reported issues.",
            status: snapshot.hasDiagnostics ? .warning : .good
        )
    }
}

extension CodexAppServer.Library.ThreadSnapshot {
    var displayTitle: String {
        let title = name?.trimmingCharacters(in: .whitespacesAndNewlines)
        if let title, !title.isEmpty {
            return title
        }

        let previewTitle = preview.trimmingCharacters(in: .whitespacesAndNewlines)
        return previewTitle.isEmpty ? "Untitled Thread" : previewTitle
    }

    var updatedDate: Date {
        Date(timeIntervalSince1970: TimeInterval(updatedAt) / 1000)
    }
}

extension CodexAppServer.ThreadStatus {
    var systemImage: String {
        switch type {
        case .active:
            "waveform.path.ecg"
        case .systemError:
            "exclamationmark.triangle"
        case .notLoaded:
            "circle.dashed"
        case .idle:
            "checkmark.circle"
        }
    }

    var badgeStatus: InspectorBadge.BadgeStatus {
        switch type {
        case .active:
            .active
        case .systemError:
            .warning
        default:
            .good
        }
    }
}
