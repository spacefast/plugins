---
name: update-design
description: "Bring a named existing Spacefast Space or linked project into alignment with the team's current saved design system. Update affected source and assets, verify the result, and follow the request's deployment intent."
---

# Update an existing design

Use the connected Spacefast tools. When working in a checkout, preserve unrelated files and changes.

If a task requires an existing Space and its identity is unclear, call `choose_space`. Use the selected Space as the target. A selection does not approve publishing or other changes.

Read the MCP calls, approval, and work mode rules in [references.md](references.md) before a management operation.

1. Resolve only the named existing Space or linked project, its exact editable source revision, and its current preview or live version. Read Design system and Source edits in references.md, including the work mode.
2. Read Team Memories and Skills in references.md. Retrieve current standards, applicable memories, enabled team skills, and assets. Compare with the last applied handoff when reliable; otherwise inspect the relevant implementation without assuming every difference is safe to replace.
3. Map affected rules to actual components, copy, states, and asset files. Preserve unrelated content, behavior, user-authored handoff text, and independent design choices.
4. Update source and asset copies, run the real build, and inspect desktop, mobile, and affected states against the current standards. Correct deviations and repeat checks.
5. Before publishing or deploying new or changed source, run the verify-design-system skill against current saved standards and the exact source/build being deployed. Inspect affected pages and states at desktop and mobile widths, and report gaps. Reuse verification only while the source/build and design revision are unchanged. Report missing standards as unavailable, not a pass. Verify before a source-workspace commit when autoDeploy is enabled. Follow the user's existing publication intent and approval rules.
6. Save and deploy according to the original request and work mode, checking auto-deploy before starting another build. Verify live routes after a requested deployment; report source, preview, and live status separately.
7. For multiple named Spaces, keep separate baselines, verification, and receipts. Do not roll changes across unmentioned Spaces.
