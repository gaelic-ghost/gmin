//
//  ArchiveSheetView.swift
//  gmin
//
//  Created by Codex on 5/5/26.
//

import SwiftUI
import SwiftASB

struct ArchiveSheetView: View {
    @Bindable var model: GminCodexModel

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Archived Threads")
                    .font(.title2.weight(.semibold))

                Spacer()

                Button("Done") {
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
            }

            if let archivedThreads = model.library?.archivedThreads, !archivedThreads.isEmpty {
                List(archivedThreads) { thread in
                    HStack(alignment: .firstTextBaseline, spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(thread.displayTitle)
                                .font(.headline)

                            Text(thread.preview.isEmpty ? thread.projectInfo.displayName : thread.preview)
                                .font(.callout)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                        }

                        Spacer()

                        Button {
                            Task {
                                await model.unarchiveThread(id: thread.id)
                                dismiss()
                            }
                        } label: {
                            Label("Unarchive", systemImage: "tray.and.arrow.up")
                        }
                    }
                    .padding(.vertical, 6)
                }
                .listStyle(.inset)
            } else {
                ContentUnavailableView(
                    "No Archived Threads",
                    systemImage: "archivebox",
                    description: Text("Archived threads will appear here and can be restored to the sidebar."),
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .padding(20)
    }
}
