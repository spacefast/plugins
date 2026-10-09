---
name: custom-domain
description: "Find, check, and register domains through Spacefast forms. Connect a domain the user owns to a Space, check DNS and HTTPS, or move its website to Spacefast. Preserve the existing site until the new destination works."
---

# Find or connect a domain

Use the connected Spacefast tools. When working in a checkout, preserve unrelated files and changes.

If a task requires an existing Space and its identity is unclear, call `choose_space`. Use the selected Space as the target. A selection does not approve publishing or other changes.

Read the MCP calls, approval, and work mode rules in [references.md](references.md) before a management operation.

1. To find, check, or register a domain, call `show_domains` directly when the connected server advertises it. Use it to reopen registration status.
2. For domain search or registration, read **Find and register domains** in [references.md](references.md), including the fallback for servers without `show_domains`. A domain belongs to a team; it does not need a Space. Keep owner details in the App or dashboard form.
3. If the user only requests registration, finish with its status. Continue to Space setup only for a requested connection.
4. For a requested Space connection, resolve the Space and domain. Open the Space's domains view to read its current state.
5. Read **Set up a custom domain** in [references.md](references.md). Use the DNS values returned by Spacefast.
6. For an existing production domain, also read **Migrate DNS** before changing its destination.
7. Use Domain Connect when the result offers it. Otherwise, explain the exact provider change without claiming it already happened.
8. Report the domain as live only after DNS, HTTPS, and representative content checks succeed.
