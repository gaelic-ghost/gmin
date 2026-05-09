//
//  InspectorBadgeStripView.swift
//  gmin
//
//  Created by Codex on 5/5/26.
//

/*
 The Detail, or Inspector, Pane is the trailing column of the NavigationSplitView
 */

import SwiftUI

struct InspectorBadgeStripView: View {
    var badges: [InspectorBadgeDraft]

    var body: some View {
        VStack(spacing: 10) {
            ForEach(badges) { badge in
                InspectorBadgeButton(badge: badge)
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.vertical, 12)
        .navigationTitle("Inspector")
        .background(.bar)
    }
}

private struct InspectorBadgeButton: View {
    var badge: InspectorBadgeDraft

    @State private var isPopoverPresented = false

    var body: some View {
        Button {
            isPopoverPresented.toggle()
        } label: {
            Image(systemName: badge.systemImage)
                .font(.system(size: 17, weight: .semibold))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(badge.status.tint)
                .frame(width: 36, height: 36)
        }
        .buttonStyle(.plain)
        .contentShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .help("\(badge.title): \(badge.detail)")
        .popover(isPresented: $isPopoverPresented, arrowEdge: .leading) {
            VStack(alignment: .leading, spacing: 8) {
                Label(badge.title, systemImage: badge.systemImage)
                    .font(.headline)
                    .foregroundStyle(badge.status.tint)

                Text(badge.detail)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(width: 280, alignment: .leading)
            .padding(14)
        }
        .accessibilityLabel(badge.title)
        .accessibilityHint(badge.detail)
    }
}
