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
    @State private var model = MainWindowModel()

    var body: some View {
        NavigationSplitView(columnVisibility: $model.columnVisibility) {
            ThreadSidebarView(model: model)
                .navigationSplitViewColumnWidth(min: 220, ideal: 260, max: 320)
        } content: {
            ThreadContentView(thread: model.selectedThread)
                .navigationSplitViewColumnWidth(min: 420, ideal: 720, max: .infinity)
        } detail: {
            InspectorBadgeStripView(badges: model.selectedThreadBadges)
                .navigationSplitViewColumnWidth(min: 52, ideal: 60, max: 72)
        }
        .navigationSplitViewStyle(.balanced)
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Button {
                    model.createThread()
                } label: {
                    Label("New Thread", systemImage: "plus.bubble")
                }
                .help("Create a new local thread shell")

                Button {
                    model.presentArchive()
                } label: {
                    Label("Archive", systemImage: "archivebox")
                }
                .help("Open archived threads")

                Button {
                    model.archiveSelectedThread()
                } label: {
                    Label("Archive Selected Thread", systemImage: "tray.and.arrow.down")
                }
                .help("Archive the selected thread")
                .disabled(model.selectedThread == nil)
            }
        }
        .sheet(isPresented: $model.isArchivePresented) {
            ArchiveSheetView(model: model)
                .frame(minWidth: 520, minHeight: 360)
        }
    }
}

#Preview {
    MainWindowView()
}
