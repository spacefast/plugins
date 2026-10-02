---
name: custom-domain
description: "Connect a domain the user owns to a Spacefast Space, check DNS and HTTPS, or move an existing domain to Spacefast. Use for domain setup and cutover; preserve the existing site until the new destination works."
---

# Use your own domain

Use the connected Spacefast tools. When working in a checkout, preserve unrelated files and changes.

If a task requires an existing Space and its identity is unclear, call `choose_space`. Use the selected Space as the target. A selection does not approve publishing or other changes.

Read the MCP calls, approval, and work mode rules in [references.md](references.md) before a management operation.

1. Resolve the Space and the domain. Open its domains view to read the current state.
2. Read **Set up a custom domain** in [references.md](references.md). Use the DNS values returned by Spacefast.
3. For an existing production domain, also read **Migrate DNS** before changing its destination.
4. Use Domain Connect when the result offers it. Otherwise, explain the exact provider change without claiming it already happened.
5. Report the domain as live only after DNS, HTTPS, and representative content checks succeed.
