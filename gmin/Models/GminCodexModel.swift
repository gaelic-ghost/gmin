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

    private(set) var library: CodexAppServer.Library?
    private(set) var startupSession: CodexAppServer.StartupSession?
    private(set) var startupErrorMessage: String?
    private(set) var actionErrorMessage: String?
    private(set) var isStarting = false
    private(set) var isStarted = false

    var selectedThread: CodexAppServer.Library.ThreadSnapshot? {
        library?.selectedThread
    }

    var selectedThreadBadges: [InspectorBadge] {
        InspectorBadge.makeBadges(
            model: self,
            library: library,
            selectedThread: selectedThread
        )
    }

    deinit {
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
            actionErrorMessage = nil
        } catch {
            actionErrorMessage = "SwiftASB could not create a stored Codex thread: \(error.localizedDescription)"
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
