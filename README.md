# gmin

`gmin` is a native macOS Codex GUI app in active development. The longer-term goal is a first-class desktop client for navigating projects and threads, reading and driving the currently selected conversation, surfacing rich inspector metadata, and eventually coordinating with related devices and services like text-to-speech and an iOS remote companion.

The project currently provides a validated SwiftUI/Xcode baseline with local persistence, a settings scene, test targets, maintainer tooling, and a first live `SwiftASB`-backed thread surface.

## Product Direction

The planned primary interface is a three-pane `NavigationSplitView`:

- The sidebar handles stored thread navigation through `CodexAppServer.Library`.
- The content column resumes the selected stored thread, displays recent turn history, and starts one active turn at a time.
- The detail inspector is a slim badge-strip that surfaces compact runtime, thread, Git, model, MCP, and hook status.
- The window toolbar hosts thread- and workspace-level actions instead of burying them in ad hoc controls.

That shape maps cleanly to SwiftUI's documented split-view model, where leading-column selections drive subsequent columns and the container supports two- or three-column navigation at the scene root.

## Current Status

- Native macOS SwiftUI app project managed through Xcode.
- `App`-based entrypoint with a main `WindowGroup` and a dedicated Settings scene.
- `NavigationSplitView` shell backed by SwiftASB app-server startup, stored-thread library state, selected-thread handles, and recent-turn companions.
- Core Data scaffold retained for early local persistence experiments.
- `SwiftASB` added as a Swift package dependency and used for runtime startup, Codex CLI diagnostics, thread library state, selected-thread resume, recent turns, and active-turn handles.
- Swift Testing unit-test target plus XCTest-based UI test targets.
- Repo guidance and maintainer scripts installed for validation and releases.

## Project Layout

- [`gmin/`](gmin) contains the app entrypoint, scenes, assets, and persistence layer.
- [`gminTests/`](gminTests) contains Swift Testing-based unit tests.
- [`gminUITests/`](gminUITests) contains UI smoke-test scaffolding.
- [`scripts/repo-maintenance/`](scripts/repo-maintenance) contains the shared maintainer validation and release helpers.

## Getting Started

1. Open `gmin.xcodeproj` in Xcode.
2. Build the app with the `gmin` scheme, or run:
   `xcodebuild -project gmin.xcodeproj -scheme gmin -configuration Debug -destination 'platform=macOS' build`
3. Run repo-maintenance validation when you touch docs or workflow files:
   `bash scripts/repo-maintenance/validate-all.sh`

## Planned Capabilities

- Richer SwiftASB-backed active-turn controls for approvals, elicitation, steering, and inspector drill-downs.
- First-class TTS driven by `SpeakSwiftlyServer`.
- Rich thread/project navigation and inspector metadata surfaces.
- A later iOS remote-control app that can coordinate with the macOS client.

## Notes

- The current UI is still early, but it now exercises real SwiftASB startup, library, selected-thread, recent-history, and turn-start workflows.
- Approval, elicitation, steering, and deeper inspector workflows are still planned follow-up surfaces.
- See [`ROADMAP.md`](ROADMAP.md) for the next planned steps.
