//
//  SelectedThreadRuntimeView.swift
//  gmin
//
//  Created by Codex on 5/10/26.
//

import SwiftASB
import SwiftUI

struct SelectedThreadRuntimeView: View {
    var model: GminCodexModel

    var body: some View {
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
}

#Preview {
    SelectedThreadRuntimeView(model: GminCodexModel())
        .padding()
}
