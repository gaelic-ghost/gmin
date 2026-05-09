# ROADMAP

## Foundation

- [x] Create the native macOS Xcode app shell.
- [x] Keep the app on the SwiftUI `App` lifecycle with a main window scene and a Settings scene.
- [x] Start the main UI around `NavigationSplitView`.
- [x] Preserve a working Core Data scaffold for local persistence experiments.
- [x] Add the in-development `SwiftASB` package dependency.
- [x] Add unit-test and UI-test targets.
- [x] Sync repo-local Xcode guidance and repo-maintenance tooling.
- [x] Add baseline repository docs for onboarding and maintenance.

## Next

- [ ] Replace the bootstrap placeholder layout with the real three-pane `NavigationSplitView` structure.
- [ ] Build the sidebar around project and thread navigation.
- [ ] Turn the center content column into the active thread view.
- [ ] Shape the detail inspector into a slim badge-strip for compact metadata.
- [ ] Define the first real SwiftASB-backed app and model workflow.
- [ ] Move toolbar actions toward thread- and workspace-level controls.
- [ ] Introduce real persisted model types once the first client surface is defined.
- [ ] Add meaningful unit tests around the first non-template behavior.
- [ ] Revisit UI smoke coverage once the main window structure stabilizes.

## Later

- [ ] Add first-class TTS built around `SpeakSwiftlyServer`.
- [ ] Add richer local/runtime status badges and inspector surfaces.
- [ ] Explore trackpad gestures for high-value navigation and inspection flows, including rotation and next/previous page gestures.
- [ ] Explore supporting services and workflows that don't belong directly in the thread pane.
- [ ] Build the later iOS remote-control companion app.
- [ ] Revisit release automation once the app can ship something more than the shell.
