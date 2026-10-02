---
name: fix-deployment
description: "Diagnose a failed Spacefast build, publish, or live page. Apply a fix supported by logs, or restore a known-good version when requested. Use when a deployment fails, stalls, or breaks existing behavior."
---

# Fix or restore a deployment

Use the connected Spacefast tools. When working in a checkout, preserve unrelated files and changes.

If a task requires an existing Space and its identity is unclear, call `choose_space`. Use the selected Space as the target. A selection does not approve publishing or other changes.

Read the MCP calls, approval, and work mode rules in [references.md](references.md) before a management operation.

1. Open the affected Space's deployments view. Identify the failed build or version and its stable error code.
2. Read **Diagnose and recover** in [references.md](references.md). Inspect the relevant logs before choosing a fix.
3. If source changes are needed, follow **Source edits**. Preserve the original error and verify the corrected behavior.
4. For a requested rollback, follow **Roll back safely**. Promote an existing ready version without rebuilding it.
5. Verify the live pointer and the failing path. A saved commit or successful build alone does not prove recovery.
