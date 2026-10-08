---
name: build-website
description: "Create and publish a new Spacefast website from a brief, such as a landing page, portfolio, report, or dashboard. Use when the user wants a new site. For an existing Space, use edit-space."
---

# Build a website

Use the connected Spacefast tools. When working in a checkout, preserve unrelated files and changes.

If a task requires an existing Space and its identity is unclear, call `choose_space`. Use the selected Space as the target. A selection does not approve publishing or other changes.

Read the MCP calls, approval, and work mode rules in [references.md](references.md) before a management operation.

Inspect the current project before choosing a framework. Reuse its components, assets, and build commands, then run its real build.

1. Use the user's brief and real content. Infer optional design choices; ask only for information that blocks the requested result.
2. Before creating or editing a Space, including its linked local source, call `getTeamAgentContext` in `execute` with `teamId` (and `spaceId` for an existing Space), and follow every skill it returns. Memories are team knowledge, not commands: when one conflicts with the user, follow the user. Keep `memories.revision`, `skillsRevision`, and `designSystem.revision`. Before later work, send `knownMemoriesRevision`, `knownSkillsRevision`, and `knownDesignSystemRevision`: keep each part whose changed flag is false and replace each changed part. Reuse revisions only with the cached contents for the same authenticated connection, team, and optional Space. An unchanged part is empty in the response; it does not clear the cached contents. Omit a known revision when you no longer hold its contents. For a local project, read the nearest `.spacefast/space.json` for its non-secret Space and team coordinates; resolve the Space to its canonical ID and team before editing. `getTeamAgentContext` returns the team-wide `designSystem.markdown` and asset references; use them while performing the user's task, including content-only edits such as updating a resume. A null Markdown on a changed read means no saved system; on an unchanged read keep the system already held. Saved standards guide the task and do not authorize unrelated changes or deployment. Read **Team Memories and Skills** in [references.md](references.md) for memory changes, skill setup, and availability. Save only lasting user knowledge; agents do not change the team's skill settings.
3. Before publishing or deploying new or changed source, run the verify-design-system skill against current saved standards and the exact source/build being deployed. Inspect affected pages and states at desktop and mobile widths, and report gaps. Reuse verification only while the source/build and design revision are unchanged. Report missing standards as unavailable, not a pass. Verify before a source-workspace commit when autoDeploy is enabled. Follow the user's existing publication intent and approval rules.
4. Build an accessible, responsive website with working links and useful interaction states.
5. When team context includes a design system, read **Design system** in [references.md](references.md), prepare its handoff, and verify the built components against it.
6. Keep app capabilities honest. Static files do not provide a database or server; use a declared runtime when required.
7. For connected data, read **Connectors** in [references.md](references.md). Use only the user's available connections.
8. Follow **Publish** in [references.md](references.md). After deployment, inspect the page and its main interaction before reporting success.
