//
//  ActiveTurnSurfaceView.swift
//  gmin
//
//  Created by Codex on 5/10/26.
//

import SwiftASB
import SwiftUI

struct ActiveTurnSurfaceView: View {
    var model: GminCodexModel

    var body: some View {
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
                ActiveTurnMinimapView(minimap: minimap)
            } else if let status = model.completedTurnStatusMessage {
                Label(status, systemImage: "checkmark.circle")
                    .foregroundStyle(.secondary)
            } else {
                Text("No turn is active. The composer below starts one SwiftASB turn in the selected thread.")
                    .foregroundStyle(.secondary)
            }
        }
    }
}

private struct ActiveTurnMinimapView: View {
    var minimap: CodexTurnHandle.Minimap

    var body: some View {
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
    }
}

#Preview {
    ActiveTurnSurfaceView(model: GminCodexModel())
        .padding()
}
