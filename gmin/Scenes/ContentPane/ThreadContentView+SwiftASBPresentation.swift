//
//  ThreadContentView+SwiftASBPresentation.swift
//  gmin
//
//  Created by Codex on 5/10/26.
//

import Foundation
import SwiftASB

extension CodexAppServer.ThreadStatusType {
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

extension CodexThread.Dashboard.ActivityStatus {
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

extension CodexDiagnosticEvent {
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

extension CodexTurnPlanUpdate.Step.Status {
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

extension CodexTurnHandle.Minimap.CallSnapshot.Kind {
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

extension CodexThread.RecentTurns.TurnSnapshot {
    var completedDate: Date? {
        completedAt.map { Date(timeIntervalSince1970: TimeInterval($0) / 1_000) }
    }
}

extension CodexThread.RecentTurns.TurnSnapshot.Item {
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

extension String {
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
