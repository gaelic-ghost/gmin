# gmin

`gmin` is an early native macOS app shell for a Codex app-server client. The repository currently provides a validated SwiftUI/Xcode baseline with local persistence, a settings scene, test targets, and maintainer tooling, but it does not yet include a real backend client or live app-server integration.

## Current Status

- Native macOS SwiftUI app project managed through Xcode.
- `App`-based entrypoint with a main `WindowGroup` and a dedicated Settings scene.
- Core Data scaffold kept in place for local persistence experiments.
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

## Notes

- The current UI is intentionally a bootstrap shell that makes the app structure visible while the real client feature set is still being designed.
- The README previously mentioned SwiftASB, but there is not yet a real package dependency or wired client surface in the current project.
- See [`ROADMAP.md`](ROADMAP.md) for the next planned steps.
