//
//  MainWindowView.swift
//  gmin
//
//  Created by Codex on 5/5/26.
//

/*
 The Sidebar Pane is the leading column of the NavigationSplitView
 The Content Pane is the center column of the NavigationSplitView
 The Detail, or Inspector, Pane is the trailing column of the NavigationSplitView
 */

import SwiftUI

struct MainWindowView: View {
    @State private var codexModel = GminCodexModel()
    @State private var windowState = MainWindowState()

    var autoStart = true

    var body: some View {
        NavigationSplitView(columnVisibility: $windowState.columnVisibility) {
            ThreadSidebarView(model: codexModel)
                .navigationSplitViewColumnWidth(min: 220, ideal: 260, max: 320)
        } content: {
            ThreadContentView(model: codexModel)
                .navigationSplitViewColumnWidth(min: 420, ideal: 720, max: .infinity)
        } detail: {
            InspectorBadgeStripView(badges: codexModel.selectedThreadBadges)
                .navigationSplitViewColumnWidth(min: 52, ideal: 60, max: 72)
        }
        .navigationSplitViewStyle(.balanced)
        .task {
            guard autoStart else { return }

            await codexModel.startIfNeeded()
        }
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Button {
                    Task { await codexModel.createThread() }
                } label: {
                    Label("New Thread", systemImage: "plus.bubble")
                }
                .help("Create a stored Codex thread")
                .disabled(!codexModel.isStarted)

                Button {
                    windowState.isArchivePresented = true
                } label: {
                    Label("Archive", systemImage: "archivebox")
                }
                .help("Open archived threads")
                .disabled(codexModel.library == nil)

                Button {
                    Task { await codexModel.archiveSelectedThread() }
                } label: {
                    Label("Archive Selected Thread", systemImage: "tray.and.arrow.down")
                }
                .help("Archive the selected thread")
                .disabled(codexModel.selectedThread == nil)

                Button {
                    Task { await codexModel.refreshLibrary() }
                } label: {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }
                .help("Refresh stored threads and selected Git status")
                .disabled(codexModel.library == nil)
            }
        }
        .sheet(isPresented: $windowState.isArchivePresented) {
            ArchiveSheetView(model: codexModel)
                .frame(minWidth: 520, minHeight: 360)
        }
    }
}

private struct MainWindowState {
    var columnVisibility: NavigationSplitViewVisibility = .all
    var isArchivePresented = false
}

#Preview {
    MainWindowView(autoStart: false)
}
