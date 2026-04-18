//
//  SettingsUtilityWindow.swift
//  gmin
//
//  Created by Gale Williams on 4/17/26.
//

import SwiftUI

struct SettingsUtilityWindow: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Settings")
                .font(.title2)
                .fontWeight(.semibold)

            Text("This window is reserved for future client configuration, connection preferences, and any app-level behavior that should not live in the main workspace.")
                .foregroundStyle(.secondary)

            Label("Backend wiring is not implemented yet.", systemImage: "externaldrive.badge.questionmark")
            Label("Use this scene for durable app configuration later.", systemImage: "gearshape.2")

            Spacer()
        }
        .frame(minWidth: 360, minHeight: 220, alignment: .topLeading)
        .padding(20)
    }
}

#Preview {
    SettingsUtilityWindow()
}
