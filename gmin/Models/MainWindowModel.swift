//
//  MainWindowModel.swift
//  gmin
//
//  Created by Codex on 5/5/26.
//

import Foundation
import Observation
import SwiftUI

@MainActor
@Observable
final class MainWindowModel {
    var columnVisibility: NavigationSplitViewVisibility = .all
    var selectedThreadID: CodexThreadDraft.ID?
    var isArchivePresented = false

    private(set) var threads: [CodexThreadDraft]

    var pinnedThreads: [CodexThreadDraft] {
        normalThreads
            .filter(\.isPinned)
            .sortedByRecency()
    }

    var recentThreads: [CodexThreadDraft] {
        normalThreads
            .filter { !$0.isPinned }
            .sortedByRecency()
    }

    var archivedThreads: [CodexThreadDraft] {
        threads
            .filter(\.isArchived)
            .sortedByRecency()
    }

    var selectedThread: CodexThreadDraft? {
        threads.first { $0.id == selectedThreadID }
    }

    var selectedThreadBadges: [InspectorBadgeDraft] {
        selectedThread?.badges ?? InspectorBadgeDraft.emptySelectionBadges
    }

    private var normalThreads: [CodexThreadDraft] {
        threads.filter { !$0.isArchived }
    }

    init(threads: [CodexThreadDraft] = CodexThreadDraft.sampleThreads) {
        self.threads = threads
        selectedThreadID = normalThreads.first?.id
    }

    func presentArchive() {
        isArchivePresented = true
    }

    func createThread() {
        let thread = CodexThreadDraft(
            title: "New Codex Thread",
            workspaceName: "gmin",
            summary: "Ready for a SwiftASB-backed conversation once the app-server model lands.",
            updatedAt: .now,
            status: .ready,
            isPinned: false,
            isArchived: false,
            badges: InspectorBadgeDraft.newThreadBadges,
        )
        threads.append(thread)
        selectedThreadID = thread.id
    }

    func archiveSelectedThread() {
        guard let selectedThreadID else { return }

        updateThread(id: selectedThreadID) { thread in
            thread.isArchived = true
            thread.isPinned = false
        }
        self.selectedThreadID = normalThreads.sortedByRecency().first?.id
    }

    func unarchiveThread(id: CodexThreadDraft.ID) {
        updateThread(id: id) { thread in
            thread.isArchived = false
        }
        selectedThreadID = id
    }

    private func updateThread(
        id: CodexThreadDraft.ID,
        mutate: (inout CodexThreadDraft) -> Void,
    ) {
        guard let index = threads.firstIndex(where: { $0.id == id }) else { return }

        mutate(&threads[index])
    }
}

struct CodexThreadDraft: Identifiable, Hashable {
    enum Status: String, Hashable {
        case ready = "Ready"
        case running = "Running"
        case needsReview = "Needs Review"
        case archived = "Archived"

        var systemImage: String {
            switch self {
                case .ready:
                    "checkmark.circle"
                case .running:
                    "waveform.path.ecg"
                case .needsReview:
                    "exclamationmark.triangle"
                case .archived:
                    "archivebox"
            }
        }
    }

    let id: UUID
    var title: String
    var workspaceName: String
    var summary: String
    var updatedAt: Date
    var status: Status
    var isPinned: Bool
    var isArchived: Bool
    var badges: [InspectorBadgeDraft]

    init(
        id: UUID = UUID(),
        title: String,
        workspaceName: String,
        summary: String,
        updatedAt: Date,
        status: Status,
        isPinned: Bool,
        isArchived: Bool,
        badges: [InspectorBadgeDraft],
    ) {
        self.id = id
        self.title = title
        self.workspaceName = workspaceName
        self.summary = summary
        self.updatedAt = updatedAt
        self.status = status
        self.isPinned = isPinned
        self.isArchived = isArchived
        self.badges = badges
    }
}

struct InspectorBadgeDraft: Identifiable, Hashable {
    let id = UUID()
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

private extension [CodexThreadDraft] {
    func sortedByRecency() -> [CodexThreadDraft] {
        sorted { lhs, rhs in
            lhs.updatedAt > rhs.updatedAt
        }
    }
}

extension InspectorBadgeDraft {
    static let emptySelectionBadges = [
        InspectorBadgeDraft(
            title: "Selection",
            systemImage: "sidebar.left",
            detail: "Select a thread to show SwiftASB runtime, model, git, files, commands, MCP, hooks, token, and speech badges.",
            status: .neutral,
        ),
    ]

    static let newThreadBadges = [
        InspectorBadgeDraft(
            title: "Runtime",
            systemImage: "bolt.horizontal",
            detail: "The UI shell is ready. The next slice will start the SwiftASB app-server model.",
            status: .neutral,
        ),
        InspectorBadgeDraft(
            title: "Thread",
            systemImage: "text.bubble",
            detail: "This sample thread is local app state only until SwiftASB thread creation lands.",
            status: .neutral,
        ),
    ]
}

extension CodexThreadDraft {
    static let sampleThreads: [CodexThreadDraft] = [
        CodexThreadDraft(
            title: "Design the SwiftASB GUI shell",
            workspaceName: "gmin",
            summary: "Shape the three-column window, badge strip, and first SwiftASB ownership decisions.",
            updatedAt: .now.addingTimeInterval(-900),
            status: .running,
            isPinned: true,
            isArchived: false,
            badges: [
                InspectorBadgeDraft(
                    title: "Runtime",
                    systemImage: "bolt.horizontal.circle",
                    detail: "SwiftASB will own CodexAppServer startup and diagnostics in the next slice.",
                    status: .active,
                ),
                InspectorBadgeDraft(
                    title: "Git",
                    systemImage: "point.topleft.down.to.point.bottomright.curvepath",
                    detail: "Git gets a dedicated toolbar entry later, with common actions in an ornament-style surface.",
                    status: .neutral,
                ),
                InspectorBadgeDraft(
                    title: "Files",
                    systemImage: "doc.text.magnifyingglass",
                    detail: "Recent file badges should come from SwiftASB recent-file companions once a real thread is attached.",
                    status: .good,
                ),
                InspectorBadgeDraft(
                    title: "Tokens",
                    systemImage: "gauge.with.dots.needle.67percent",
                    detail: "Token and compaction indicators should read thread dashboard and active-turn minimap state.",
                    status: .neutral,
                ),
            ],
        ),
        CodexThreadDraft(
            title: "Plan archive and pinning behavior",
            workspaceName: "gmin",
            summary: "Keep archived threads out of the main list and restore them through a dedicated archive sheet.",
            updatedAt: .now.addingTimeInterval(-4800),
            status: .ready,
            isPinned: false,
            isArchived: false,
            badges: [
                InspectorBadgeDraft(
                    title: "Archive",
                    systemImage: "archivebox",
                    detail: "Archived threads leave the main sidebar and can be unarchived from the archive sheet.",
                    status: .good,
                ),
                InspectorBadgeDraft(
                    title: "Sidebar",
                    systemImage: "list.bullet.rectangle",
                    detail: "Pinned threads are a section. Recent threads are the remaining normal threads sorted by recency.",
                    status: .neutral,
                ),
            ],
        ),
        CodexThreadDraft(
            title: "Earlier transcript experiment",
            workspaceName: "SwiftASB",
            summary: "An archived sample that demonstrates the restore path before real stored thread paging lands.",
            updatedAt: .now.addingTimeInterval(-86400),
            status: .archived,
            isPinned: false,
            isArchived: true,
            badges: [
                InspectorBadgeDraft(
                    title: "Stored",
                    systemImage: "clock.arrow.trianglehead.counterclockwise.rotate.90",
                    detail: "Stored thread history should come through SwiftASB thread history APIs, not raw wire payloads.",
                    status: .neutral,
                ),
            ],
        ),
    ]
}
