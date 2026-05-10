//
//  ThreadHeaderView.swift
//  gmin
//
//  Created by Codex on 5/10/26.
//

import SwiftASB
import SwiftUI

struct ThreadHeaderView: View {
    var thread: CodexAppServer.Library.ThreadSnapshot

    var body: some View {
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
}
