---
name: update-design
description: "Bring a named existing Spacefast Space or linked project into alignment with the team's current saved design system. Update affected source and assets, verify the result, and follow the request's deployment intent."
---

# Update an existing design

Use the connected Spacefast MCP tools. Sign-in is required. If the connection is unavailable, ask the user to reconnect in plugin settings.

If a task requires an existing Space and its identity is unclear, call `choose_space`. Use the selected Space as the target. A selection does not approve publishing or other changes.

Read the MCP calls, approval, and work mode rules in [references.md](references.md) before a management operation.

1. Resolve only the requested existing Space and its source revision. Read Team Memories and Skills, Design system, and Source edits in references.md.
2. Compare the source with the team's current saved standards. Change only the requested scope and preserve independent user choices.
3. Before publishing or deploying new or changed source, run the verify-design-system skill against current saved standards and the exact source/build being deployed. Inspect affected pages and states at desktop and mobile widths, and report gaps. Reuse verification only while the source/build and design revision are unchanged. Report missing standards as unavailable, not a pass. Verify before a source-workspace commit when autoDeploy is enabled. Follow the user's existing publication intent and approval rules.
4. Verify each named Space separately. Report saved source, preview, and live deployment as separate states.
