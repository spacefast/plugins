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
2. Build an accessible, responsive website with working links and useful interaction states.
3. Keep app capabilities honest. Static files do not provide a database or server; use a declared runtime when required.
4. For connected data, read **Connectors** in [references.md](references.md). Use only the user's available connections.
5. Follow **Publish** in [references.md](references.md). After deployment, inspect the page and its main interaction before reporting success.
