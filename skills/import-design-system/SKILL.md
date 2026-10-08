---
name: import-design-system
description: "Save branding, design tokens, component standards, writing guidelines, and asset references from user-provided material into a Spacefast team's design system."
---

# Import a design system

Use the connected Spacefast tools. When working in a checkout, preserve unrelated files and changes.

If a task requires an existing Space and its identity is unclear, call `choose_space`. Use the selected Space as the target. A selection does not approve publishing or other changes.

Read the MCP calls, approval, and work mode rules in [references.md](references.md) before a management operation.

1. Resolve the intended team and optional Space. Read Team Memories and Skills and Design system in references.md. Read the user's actual reference material before extracting standards.
2. Read the current saved document and revision. Prepare only evidence-backed changes to branding, editorial, tokens, components, and assets; preserve fields outside this import.
3. Save the partial patch through updateTeamDesignSystem with expectedRevision, then read it back. Report the saved scope and the fields changed. A standards import does not authorize source edits or deployment.
