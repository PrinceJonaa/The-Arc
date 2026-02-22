# Global Agent Contract

This file applies to **any agent** working in this repository.

Primary rule: `PROJECT_WHITEBOARD.md` is the single source of truth and the only persistent run memory.

## Project Context

- **Platform:** iOS (Swift / SwiftUI)
- **Build system:** XcodeGen (`project.yml` → `*.xcodeproj`)
- **Linting:** SwiftLint (`.swiftlint.yml`)
- **Design language:** iOS 26 Liquid Glass (with graceful fallbacks for iOS 18+)
- **Focus:** Speed and availability

## Mandatory Run Flow (Every Run)

1. Read `PROJECT_WHITEBOARD.md` first.
2. Claim or create a task ID for this run.
3. Execute one scoped task.
4. Run relevant validations.
5. Record the run in `PROJECT_WHITEBOARD.md` (append one row to `Async Run Event Log`).
6. If you must edit narrative architecture/docs sections, do it in a focused follow-up pass; do not edit existing async event rows.

## Validation Rules

For code changes, run:

```bash
# Regenerate Xcode project from project.yml
xcodegen generate

# Lint
swiftlint lint --strict

# Build (simulator)
xcodebuild -project TheArc.xcodeproj -scheme TheArc \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  build 2>&1 | tail -20
```

For docs-only changes:

- Run at least the command(s) referenced by updated docs where practical.

## Async Collaboration Mode (Required For Concurrent Runs)

To support many concurrent agents and PRs:

- Treat `PROJECT_WHITEBOARD.md` as append-only for run updates.
- Do not edit existing rows in async event shards.
- Do not manually edit `Role Task Board` or `Role Run Ledger` rows; they are derived from async events.
- `Last verified` is derived from latest async event row timestamp (not a per-run manual edit).
- Keep one run = one async event row.

Git merge behavior:

- `.gitattributes` sets `PROJECT_WHITEBOARD.md merge=union` to reduce row-level collisions.
- Event rows are sharded in the whiteboard to reduce hot-spot edits when many agents write at once.

## Task Status Rules

Allowed status values:

- `pending`
- `in_progress`
- `blocked`
- `done`
- `deferred`

## iOS 26 Liquid Glass Design Rules

When writing UI code:

1. **Never add custom backgrounds to navigation bars, tab bars, or toolbars** — let the system handle Liquid Glass.
2. **Use `.foregroundStyle()` instead of `.foregroundColor()`** — adaptive to Liquid Glass.
3. **Use `.continuous` corner style** everywhere — `RoundedRectangle(cornerRadius: 16, style: .continuous)`.
4. **Limit glass layers to 1–2 max** — content dominates, glass enhances.
5. **Always provide accessibility fallbacks** — check `reduceTransparency` and `isLowPowerModeEnabled`.
6. **Use semantic materials** — `.ultraThinMaterial`, `.regularMaterial`, etc.
7. **Use spring animations** over linear/ease — `.spring(response: 0.3, dampingFraction: 0.7)`.
8. **Provide accessibility labels for all icon-only buttons** — `Label("Title", systemImage: "icon").labelStyle(.iconOnly)`.
9. **Never hardcode control dimensions** — let the system determine sizes.
10. **Use `GlassCard` or `.adaptiveGlass()` modifier** for custom glass surfaces.

## Safety Guardrails

- Do not commit secrets or tokens.
- Do not create separate per-role journals; use only `PROJECT_WHITEBOARD.md`.
- Keep tasks scoped and reversible.
- Ask before introducing dependencies or changing build behavior.
- Never rewrite/delete existing async event rows; append only.

## Commit/PR Expectations

- Keep one run focused on one scoped objective.
- Include whiteboard update in the same commit/PR as the work.
- Summarize what changed, what was validated, and next step.

## If No Work Is Performed

Still record an async event row with:

- reason no work was performed (`summary`)
- blockers/dependencies (`validation` and/or `next`)
- explicit next action (`next`)
