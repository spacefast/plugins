---
name: apply-design-system
description: "Apply a Spacefast team's saved design system to a new build or an explicitly requested source edit. Use its standards and brand assets in the real project, then verify the result."
---

# Apply a design system

Use the connected Spacefast tools. When working in a checkout, preserve unrelated files and changes.

If a task requires an existing Space and its identity is unclear, call `choose_space`. Use the selected Space as the target. A selection does not approve publishing or other changes.

Read the MCP calls, approval, and work mode rules in [references.md](references.md) before a management operation.

1. Resolve the team and intended project or Space. For a linked checkout, read `.spacefast/space.json`; for an existing Space without complete source, follow Source edits in references.md. Do not treat served files as source.
2. Read Team Memories and Skills and Design system in references.md. Retrieve current context, applicable memories, enabled team skills, and assets. Resolve truncated guidance or unavailable assets from saved records; do not invent missing standards.
3. Before publishing or deploying new or changed source, run the verify-design-system skill against current saved standards and the exact source/build being deployed. Inspect affected pages and states at desktop and mobile widths, and report gaps. Reuse verification only while the source/build and design revision are unchanged. Report missing standards as unavailable, not a pass. Verify before a source-workspace commit when autoDeploy is enabled. Follow the user's existing publication intent and approval rules.
4. When the project needs a persistent handoff, refresh the generated part of `design.md` while preserving user-authored content. Map applicable rules to actual components, styles, copy, modes, and states before editing.
5. Download and inspect required brand files. Put visitor-facing copies in the project's normal asset source; never embed private Media Library URLs or approximate a missing logo.
6. Perform the requested build or edit in complete source. Run the real build, inspect representative desktop and mobile renders and relevant states, fix actionable deviations, and repeat affected checks.
7. Report the design revision, changed source, visual evidence, and remaining gaps. Publish only according to the original request and current work mode.
