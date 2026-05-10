//
//  RecentTurnsSurfaceView.swift
//  gmin
//
//  Created by Codex on 5/10/26.
//

import SwiftASB
import SwiftUI

struct RecentTurnsSurfaceView: View {
    var model: GminCodexModel

    var body: some View {
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
                            RecentTurnCardView(turn: turn)
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
}

#Preview {
    RecentTurnsSurfaceView(model: GminCodexModel())
        .padding()
}
