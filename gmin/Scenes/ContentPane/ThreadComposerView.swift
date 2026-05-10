//
//  ThreadComposerView.swift
//  gmin
//
//  Created by Codex on 5/10/26.
//

import SwiftUI

struct ThreadComposerView: View {
    var model: GminCodexModel
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Composer")
                .font(.headline)

            TextEditor(text: $text)
                .font(.body)
                .frame(minHeight: 90)
                .padding(8)
                .background(.quaternary, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                .disabled(!model.canStartTurn)

            HStack {
                if model.isSubmittingTurn {
                    ProgressView()
                        .controlSize(.small)
                }

                Spacer()

                Button {
                    Task {
                        if await model.submitTextTurn(text) {
                            text = ""
                        }
                    }
                } label: {
                    Label("Send", systemImage: "paperplane")
                }
                .keyboardShortcut(.return, modifiers: [.command])
                .disabled(!model.canStartTurn || text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
    }
}

#Preview {
    @Previewable @State var text = "Summarize this thread."

    ThreadComposerView(model: GminCodexModel(), text: $text)
        .padding()
}
