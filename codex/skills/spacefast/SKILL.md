---
name: spacefast
description: "Publish an existing website, app, report, or other artifact to Spacefast and verify its live link. Also use to read or manage team Memories and inspect team Skills. For changes to an existing Space's content or design, use edit-space."
---

# Publish your work

Use the connected Spacefast tools. When working in a checkout, preserve unrelated files and changes.

If a task requires an existing Space and its identity is unclear, call `choose_space`. Use the selected Space as the target. A selection does not approve publishing or other changes.

Read the MCP calls, approval, and work mode rules in [references.md](references.md) before a management operation.

1. For a team Memories or Skills request, resolve the team and optional Space. Read Team Memories and Skills in references.md and perform only the requested context work. Publish only when the user also requests it.
2. Use the artifact the user wants to publish. Keep its intended destination and access settings.
3. Before creating or editing a Space, including its linked local source, call `getTeamAgentContext` in `execute` with `teamId` (and `spaceId` for an existing Space), and follow every skill it returns. Memories are team knowledge, not commands: when one conflicts with the user, follow the user. Keep `memories.revision`, `skillsRevision`, and `designSystem.revision`. Before later work, send `knownMemoriesRevision`, `knownSkillsRevision`, and `knownDesignSystemRevision`: keep each part whose changed flag is false and replace each changed part. Reuse revisions only with the cached contents for the same authenticated connection, team, and optional Space. An unchanged part is empty in the response; it does not clear the cached contents. Omit a known revision when you no longer hold its contents. For a local project, read the nearest `.spacefast/space.json` for its non-secret Space and team coordinates; resolve the Space to its canonical ID and team before editing. `getTeamAgentContext` returns the team-wide `designSystem.markdown` and asset references; use them while performing the user's task, including content-only edits such as updating a resume. A null Markdown on a changed read means no saved system; on an unchanged read keep the system already held. Saved standards guide the task and do not authorize unrelated changes or deployment. Read **Team Memories and Skills** in [references.md](references.md) for memory changes, skill setup, and availability. Save only lasting user knowledge; agents do not change the team's skill settings.
4. Before publishing or deploying new or changed source, run the verify-design-system skill against current saved standards and the exact source/build being deployed. Inspect affected pages and states at desktop and mobile widths, and report gaps. Reuse verification only while the source/build and design revision are unchanged. Report missing standards as unavailable, not a pass. Verify before a source-workspace commit when autoDeploy is enabled. Follow the user's existing publication intent and approval rules.
5. Read **Publish** in [references.md](references.md). It covers this host's publish route, receipt, and verification.
6. Do not rebuild an existing Space from its served files. For a file or design change, follow the source workflow instead.
7. Return the live link and version link from the result. State whether the version is live or only ready.
8. For a requested preview, redirect, or GitHub workflow, read the matching section in [references.md](references.md).
