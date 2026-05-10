//
//  ThreadRuntimeSummaryView.swift
//  gmin
//
//  Created by Codex on 5/10/26.
//

import SwiftASB
import SwiftUI

struct ThreadRuntimeSummaryView: View {
    var model: GminCodexModel

    var body: some View {
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
}

#Preview {
    ThreadRuntimeSummaryView(model: GminCodexModel())
        .padding()
}
