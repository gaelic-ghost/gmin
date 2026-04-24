# gmin

`gmin` is a native macOS Codex GUI app in active development. The longer-term goal is a first-class desktop client for navigating projects and threads, reading and driving the currently selected conversation, surfacing rich inspector metadata, and eventually coordinating with related devices and services like text-to-speech and an iOS remote companion.

The project currently provides a validated SwiftUI/Xcode baseline with local persistence, a settings scene, test targets, maintainer tooling, and a new dependency on `SwiftASB` as an in-development foundation package.

## Product Direction

The planned primary interface is a three-pane `NavigationSplitView`:

- The sidebar will handle project and thread navigation.
- The content column will display the currently selected thread.
- The detail inspector will be a slim badge-strip that surfaces compact status and metadata.
- The window toolbar will host thread- and workspace-level actions instead of burying them in ad hoc controls.

That shape maps cleanly to SwiftUI's documented split-view model, where leading-column selections drive subsequent columns and the container supports two- or three-column navigation at the scene root.

## Current Status

- Native macOS SwiftUI app project managed through Xcode.
- `App`-based entrypoint with a main `WindowGroup` and a dedicated Settings scene.
- `NavigationSplitView` starter shell in place for evolving the three-pane layout.
- Core Data scaffold retained for early local persistence experiments.
- `SwiftASB` added as a Swift package dependency.
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

- SwiftASB-backed app and model infrastructure for the Codex GUI.
- First-class TTS driven by `SpeakSwiftlyServer`.
- Rich thread/project navigation and inspector metadata surfaces.
- A later iOS remote-control app that can coordinate with the macOS client.

## Notes

- The current UI is still a bootstrap shell. The repo direction is clearer than the implementation coverage.
- `SwiftASB` is now added as a package dependency, but the app does not yet expose meaningful SwiftASB-backed workflows in the UI.
- See [`ROADMAP.md`](ROADMAP.md) for the next planned steps.
