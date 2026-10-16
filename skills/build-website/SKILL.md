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
2. Before creating or editing, read **Team Memories and Skills** in [references.md](references.md). Read the full context before preparing changes and apply relevant saved practices within the task.
3. Before publishing or deploying new or changed source, run the verify-design-system skill against current saved standards and the exact source/build being deployed. Inspect affected pages and states at desktop and mobile widths, and report gaps. Reuse verification only while the source/build and design revision are unchanged. Report missing standards as unavailable, not a pass. Verify before a source-workspace commit when autoDeploy is enabled. Follow the user's existing publication intent and approval rules.
4. Build an accessible, responsive website with working links and useful interaction states.
5. When team context includes a design system, read **Design system** in [references.md](references.md), prepare its handoff, and verify the built components against it.
6. Keep app capabilities honest. Static files do not provide a database or server; use a declared runtime when required.
7. For data from a connected service, follow **MCP calls** in [references.md](references.md). Use only data the user supplied or a connection they authorized.
8. Follow **Publish** in [references.md](references.md). After deployment, inspect the page and its main interaction before reporting success.
