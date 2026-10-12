---
name: apply-design-system
description: "Apply a Spacefast team's saved design system to a new build or an explicitly requested source edit. Use its standards and brand assets in the real project, then verify the result."
---

# Apply a design system

Use the connected Spacefast MCP tools. Sign-in is required. If the connection is unavailable, ask the user to reconnect in plugin settings.

If a task requires an existing Space and its identity is unclear, call `choose_space`. Use the selected Space as the target. A selection does not approve publishing or other changes.

Read the MCP calls, approval, and work mode rules in [references.md](references.md) before a management operation.

1. Resolve the requested Spacefast team and Space. Read Team Memories and Skills, Design system, and Source edits in references.md.
2. Read current standards and required assets before preparing changes. Apply them to the requested complete source and preserve unrelated work.
3. Before publishing or deploying new or changed source, run the verify-design-system skill against current saved standards and the exact source/build being deployed. Inspect affected pages and states at desktop and mobile widths, and report gaps. Reuse verification only while the source/build and design revision are unchanged. Report missing standards as unavailable, not a pass. Verify before a source-workspace commit when autoDeploy is enabled. Follow the user's existing publication intent and approval rules.
4. Report the design revision, source changes, visual evidence, and remaining gaps. Follow the user's publication intent and tool approvals.
