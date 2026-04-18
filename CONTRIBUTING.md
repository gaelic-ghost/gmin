# Contributing

## Local Baseline

- Open `gmin.xcodeproj` in Xcode for normal day-to-day app work.
- Use the `gmin` scheme for app builds and launches.
- Keep project-structure changes Xcode-mediated. Do not edit `gmin.xcodeproj/project.pbxproj` directly.

## Validation

- Run `bash scripts/repo-maintenance/validate-all.sh` before commits that touch repo guidance or maintainer tooling.
- Run `xcodebuild -project gmin.xcodeproj -scheme gmin -configuration Debug -destination 'platform=macOS' build` for a baseline compile check.
- Add or update tests in `gminTests/` and `gminUITests/` when behavior changes.

## Git Workflow

- Prefer focused feature branches named `<scope>/<slug>`.
- Keep commits scoped and descriptive, following `<scope>: <imperative summary>`.
- Open pull requests for substantial changes instead of working directly on `main`.

## Documentation

- Keep [`README.md`](README.md), [`ROADMAP.md`](ROADMAP.md), and [`AGENTS.md`](AGENTS.md) aligned with the current codebase.
- If the repo workflow changes materially, refresh the guidance with `sync-xcode-project-guidance`.
