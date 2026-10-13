---
name: build-website
description: "Create and publish a new Spacefast website from a brief, such as a landing page, portfolio, report, or dashboard. Use when the user wants a new site. For an existing Space, use edit-space."
---

# Build a website

Use the connected Spacefast MCP tools. Sign-in is required. If the connection is unavailable, ask the user to reconnect in plugin settings.

If a task requires an existing Space and its identity is unclear, call `choose_space`. Use the selected Space as the target. A selection does not approve publishing or other changes.

Read the MCP calls, approval, and work mode rules in [references.md](references.md) before a management operation.

Create complete inline files for a small site. For a larger app, read the advertised source and build tool schemas before choosing its structure.

1. Use the user's brief and real content. Infer optional design choices; ask only for information that blocks the requested result.
2. For a requested Spacefast creation, edit, or design task, read team context. A plain page request triggers this read; the user need not mention Spacefast, memory, or skills. If signed out or no team is reachable, continue local work without team context. This known read flow fits in one read-only `execute` program; it needs no separate schema-only call. Use the target Space's known team. Otherwise discover `getBootstrap`, call its returned path with `{}`, and read `result.data.data.teams` (`id`, `name`). Choose the requested team, or the sole team only when `result.data.data.teamsPagination.hasMore` is false. Ask which team when ambiguous. In the same program, discover `getTeamAgentContext` and call it with `teamId` (and `spaceId` for an existing Space); these are top-level arguments, with no `body`. Return failed results intact. On success, return only `{ teamId }`; `execute` adds the full context automatically. Read that context before generating content or making changes. Do not read Spacefast team context for unrelated local drafts or general page requests.
3. Before publishing or deploying new or changed source, run the verify-design-system skill against current saved standards and the exact source/build being deployed. Inspect affected pages and states at desktop and mobile widths, and report gaps. Reuse verification only while the source/build and design revision are unchanged. Report missing standards as unavailable, not a pass. Verify before a source-workspace commit when autoDeploy is enabled. Follow the user's existing publication intent and approval rules.
4. Build an accessible, responsive website with working links and useful interaction states.
5. When team context includes a design system, read **Design system** in [references.md](references.md), prepare its handoff, and verify the built components against it.
6. Keep app capabilities honest. Static files do not provide a database or server; use a declared runtime when required.
7. For requested connected data, read **Connected data** in [references.md](references.md). Use only a host connection the user authorized for the task.
8. Follow **Publish** in [references.md](references.md). After deployment, inspect the page and its main interaction before reporting success.
