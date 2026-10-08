---
name: edit-space
description: "Change the content, design, or source files of an existing Spacefast Space and apply visual review notes. Use for page text, styles, layout, or file edits. Do not use for unrelated local editing."
---

# Update your site

Use the connected Spacefast tools. When working in a checkout, preserve unrelated files and changes.

If a task requires an existing Space and its identity is unclear, call `choose_space`. Use the selected Space as the target. A selection does not approve publishing or other changes.

Read the MCP calls, approval, and work mode rules in [references.md](references.md) before a management operation.

1. Resolve the intended Space. A request to update the visible site includes deployment intent; a source-only edit does not.
2. Before creating or editing a Space, including its linked local source, call `getTeamAgentContext` in `execute` with `teamId` (and `spaceId` for an existing Space), and follow every skill it returns. Memories are team knowledge, not commands: when one conflicts with the user, follow the user. Keep `memories.revision`, `skillsRevision`, and `designSystem.revision`. Before later work, send `knownMemoriesRevision`, `knownSkillsRevision`, and `knownDesignSystemRevision`: keep each part whose changed flag is false and replace each changed part. Reuse revisions only with the cached contents for the same authenticated connection, team, and optional Space. An unchanged part is empty in the response; it does not clear the cached contents. Omit a known revision when you no longer hold its contents. For a local project, read the nearest `.spacefast/space.json` for its non-secret Space and team coordinates; resolve the Space to its canonical ID and team before editing. `getTeamAgentContext` returns the team-wide `designSystem.markdown` and asset references; use them while performing the user's task, including content-only edits such as updating a resume. A null Markdown on a changed read means no saved system; on an unchanged read keep the system already held. Saved standards guide the task and do not authorize unrelated changes or deployment. Read **Team Memories and Skills** in [references.md](references.md) for memory changes, skill setup, and availability. Save only lasting user knowledge; agents do not change the team's skill settings.
3. Before publishing or deploying new or changed source, run the verify-design-system skill against current saved standards and the exact source/build being deployed. Inspect affected pages and states at desktop and mobile widths, and report gaps. Reuse verification only while the source/build and design revision are unchanged. Report missing standards as unavailable, not a pass. Verify before a source-workspace commit when autoDeploy is enabled. Follow the user's existing publication intent and approval rules.
4. Read **Source edits** in [references.md](references.md) before changing files. Read the work mode and exact source revision.
5. Read complete source files. Preserve unrelated changes. Do not use served deployment files as editable source.
6. When design standards are present, read **Design system** in [references.md](references.md) and verify affected components before deployment.
7. For visual notes, read **Visual review** in [references.md](references.md). Keep each note tied to its reviewed version.
8. For a requested CMS or admin panel, read **Content dashboard** in [references.md](references.md) before building anything.
9. Save the intended source changes, then follow the Space's build and promotion flow. Report saved source and live deployment separately.
