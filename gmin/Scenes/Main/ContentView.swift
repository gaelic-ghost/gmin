//
//  ContentView.swift
//  gmin
//
//  Created by Gale Williams on 4/17/26.
//

import CoreData
import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: false)],
        animation: .default
    )
    private var snapshots: FetchedResults<Item>

    var body: some View {
        NavigationSplitView {
            List {
                Section("Project") {
                    Label("SwiftUI macOS app shell", systemImage: "macwindow")
                    Label("Core Data scaffold retained", systemImage: "internaldrive")
                    Label("Settings scene is wired", systemImage: "gearshape")
                }

                Section("Saved Snapshots") {
                    if snapshots.isEmpty {
                        Text("No snapshots recorded yet.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(snapshots) { snapshot in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(snapshot.timestamp ?? .now, format: snapshotFormatStyle)
                                Text("Bootstrap persistence record")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .onDelete(perform: deleteSnapshots)
                    }
                }
            }
            .navigationTitle("gmin")
        } detail: {
            VStack(alignment: .leading, spacing: 18) {
                Text("Codex Client Bootstrap")
                    .font(.largeTitle)
                    .fontWeight(.semibold)

                Text("This app currently exists as a validated macOS shell for future Codex app-server work. The UI is intentionally simple: it proves the SwiftUI scene structure, local persistence, and project wiring without pretending the real product workflow already exists.")
                    .foregroundStyle(.secondary)

                VStack(alignment: .leading, spacing: 10) {
                    Label("Main app entry is a SwiftUI App with a WindowGroup.", systemImage: "app.connected.to.app.below.fill")
                    Label("A dedicated Settings scene is already present for app configuration work.", systemImage: "slider.horizontal.3")
                    Label("Snapshot records make the Core Data scaffold visible during early development.", systemImage: "clock.arrow.trianglehead.counterclockwise.rotate.90")
                }

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding(24)
            .toolbar {
                ToolbarItemGroup {
                    Button("Record Snapshot", systemImage: "plus") {
                        addSnapshot()
                    }

                    Button("Clear Snapshots", systemImage: "trash") {
                        clearSnapshots()
                    }
                    .disabled(snapshots.isEmpty)
                }
            }
        }
    }

    private func addSnapshot() {
        withAnimation {
            let snapshot = Item(context: viewContext)
            snapshot.timestamp = .now
            saveContext("recording a bootstrap snapshot")
        }
    }

    private func clearSnapshots() {
        withAnimation {
            snapshots.forEach(viewContext.delete)
            saveContext("clearing bootstrap snapshots")
        }
    }

    private func deleteSnapshots(offsets: IndexSet) {
        withAnimation {
            offsets.map { snapshots[$0] }.forEach(viewContext.delete)
            saveContext("deleting selected bootstrap snapshots")
        }
    }

    private func saveContext(_ operation: String) {
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError(
                "gmin failed while \(operation). Core Data save returned \(nsError.domain) code \(nsError.code): \(nsError.localizedDescription)"
            )
        }
    }
}

private let snapshotFormatStyle = Date.FormatStyle(date: .abbreviated, time: .shortened)

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
