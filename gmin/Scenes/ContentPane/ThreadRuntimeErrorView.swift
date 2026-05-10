//
//  ThreadRuntimeErrorView.swift
//  gmin
//
//  Created by Codex on 5/10/26.
//

import SwiftUI

struct ThreadRuntimeErrorView: View {
    var message: String

    var body: some View {
        ContentUnavailableView(
            "Codex Runtime Unavailable",
            systemImage: "exclamationmark.triangle",
            description: Text(message),
        )
    }
}

#Preview {
    ThreadRuntimeErrorView(
        message: "SwiftASB could not find a compatible Codex CLI executable."
    )
}
