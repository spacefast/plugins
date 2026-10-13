---
name: setup
description: "Check the Spacefast connection after installation or when the user asks to get started. Explain the features available in this host."
---

# Get started

Check the connection. Then explain the features that help with the user's task.
Setup does not authorize publishing, changing settings, or creating a monitor.

## Check the connection

Spacefast's hosted MCP server at `https://mcp.spacefast.com` requires OAuth.
If tools are unavailable or authentication fails, direct the user to connect Spacefast in the host's plugin settings.
Do not ask for a token in chat. Do not report a working connection until a read succeeds.

Run this known read in one bounded `execute` program:

1. Call `tools.search({ query: "getBootstrap", limit: 10 })`.
   Select the path ending in `.getBootstrap`.
   If needed, follow `nextOffset` for at most three pages. Do not invent a path.
2. Call `tools[item.path]({})`.
   For a user-supplied reference, add the optional `teamRef` or `spaceRef` field at the top level.
3. On `ok: false`, return the whole result unchanged and stop.
4. Set `data = result.data.data`.
   Return `data.me?.subject`, `data.me?.user?.name`, and each team's `id` and `name` from `data.teams`.
   Read optional reference values only when their `status` is `resolved`.
   Do not return the complete account payload or credentials.

Report the connected account or service identity. A service connection is not its creator's personal account.
Reuse the Space already established in the conversation. An ordinary publish does not need a Space chooser.

## Introduce available features

Explain that Spacefast can build and publish websites, update existing Spaces, manage sharing, connect domains, and restore deployments.
Mention only features relevant to the user's task.

Describe optional host features only when the host or connected server advertises them:

- The Space Library and mention picker can help the user select a Space.
- If `choose_space` is available, use it when a choice is needed. Honor cancellation.
- Plugin settings, HTML previews, and event subscriptions depend on host support.
  Do not promise these features merely because this skill describes them.

A selected Space supplies context. It does not authorize a write.
Continue the user's existing task after setup succeeds.
