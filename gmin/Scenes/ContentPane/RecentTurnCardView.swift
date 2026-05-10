//
//  RecentTurnCardView.swift
//  gmin
//
//  Created by Codex on 5/10/26.
//

import SwiftASB
import SwiftUI

struct RecentTurnCardView: View {
    var turn: CodexThread.RecentTurns.TurnSnapshot

    var body: some View {
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
}
