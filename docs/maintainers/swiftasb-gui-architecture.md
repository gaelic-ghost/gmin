# SwiftASB GUI Architecture

`gmin` is a native macOS SwiftUI client for the Codex app-server. It is both Gale's personal desktop app and a showcase for building real GUI apps on top of SwiftASB.

This note records the decisions already made so the first implementation slices stay aligned.

## Chosen Shape

- The app is a SwiftUI macOS app backed by SwiftASB.
- SwiftUI owns the app lifecycle, scene structure, navigation, focus, commands, sheets, popovers, and rendering.
- SwiftASB owns the Codex app-server process, typed protocol requests, thread handles, turn handles, diagnostics, local history companions, and active-turn companions.
- The app should use SwiftASB public handles and observable companions directly where practical instead of replaying raw app-server events into a duplicate UI cache.

## SwiftASB Ownership

- App-wide model owns `CodexAppServer`.
- A workspace or selected conversation model owns each `CodexThread`.
- The active thread owns at most one active `CodexTurnHandle` at a time.
- Active-turn UI reads `CodexTurnHandle.minimap`.
- Thread-wide UI reads `CodexThread.makeDashboard()`.
- History and inspector surfaces should prefer `CodexThread.makeRecentTurns(...)`, `makeRecentFiles(...)`, and `makeRecentCommands(...)`.

Same-thread turn overlap is a product constraint, not an error to hide. The UI should disable or redirect turn-start controls when the selected thread already has active work.

## Window Structure

The main window is a three-column `NavigationSplitView`.

- Sidebar: project and thread navigation.
- Content: the selected active thread.
- Detail: a permanently thin inspector badge strip.

The detail column is not a large inspector panel. Each badge is a compact status/action entry point. Badges can reveal richer detail through popovers on hover or keyboard focus, and can open a larger sheet on click when a workflow needs more room.

## Sidebar Decisions

- Pinned threads get a dedicated sidebar section.
- Normal active threads are sorted by recency.
- Recency is a sort of the same backing collection, not a separate conceptual section.
- Archived threads do not stay in the main sidebar.
- Archive is opened from a button into a sheet.
- The archive sheet lists archived threads and lets the user unarchive a thread, making it normal again.

## Content Decisions

The content column is the active thread surface.

Near-term responsibilities:

- Show selected thread identity and workspace context.
- Show transcript/history once SwiftASB-backed thread loading lands.
- Show active turn state, approvals, elicitation, cancellation, and steering.
- Keep startup, compatibility, turn, approval, cancellation, and shutdown errors readable and specific.

## Inspector Badge Strip Decisions

The detail column remains a thin vertical badge strip.

Initial badge families:

- Runtime status.
- Model and reasoning settings.
- Git status and common actions.
- Files touched.
- Commands run.
- MCP servers and tools.
- Hooks and diagnostics.
- Tokens and compaction.
- TTS or speech output state.

Each badge should be designed carefully. A badge is not just an icon: it needs a clear status vocabulary, keyboard behavior, accessibility label, hover/focus detail, and a larger action surface only when the workflow earns it.

## Toolbar And Commands

Toolbars should host the most-used workspace and thread actions only. Avoid burying critical actions in ad hoc inline controls, but keep the toolbar selective.

Command routing should use SwiftUI's native focus and scene mechanisms. Menu items and toolbar actions should resolve through the active window or selected thread rather than a broad app-wide command bus.

The git toolbar entry should eventually open an ornament-like surface with common git actions as individual buttons. Until that interaction is designed and validated, git actions should stay represented as a deliberate future UI decision instead of a placeholder cluster of unrelated controls.

## Persistence Direction

Core Data remains available for app-owned local state, such as workspaces, local thread metadata, UI preferences, pinned state, archive state, and window/session restoration data.

SwiftASB remains the source for app-server thread handles, active turn handles, live events, diagnostics, and SwiftASB-managed local history views.

Do not persist raw generated wire payloads as the app's public model. If persistence needs protocol-derived fields, map them into app-owned records with names that match user-visible behavior.

## First Implementation Slice

Replace the bootstrap placeholder with a modular three-column SwiftUI shell:

- Main window model with sample thread records.
- Sidebar sections for pinned and recent normal threads.
- Archive sheet with unarchive behavior.
- Active thread content pane.
- Thin inspector badge strip with compact badge buttons and popovers.
- Selective toolbar buttons for first expected actions.

This slice intentionally does not start the live Codex app-server. The next slice should introduce the real app-wide SwiftASB model and wire one selected thread workflow through SwiftASB handles.
