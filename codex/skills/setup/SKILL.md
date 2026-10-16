---
name: setup
description: "Check the Spacefast connection and continue the user's task. Ask one short question when they have not said what they want to do."
---

# Get started

Check the connection, then continue the user's task.
Use the user's request and conversation so far. Continue an established task without asking them to repeat it. When they bring work to Spacefast to publish, start publishing that work.

If the task is unclear, ask one concise question and wait. For a fresh publishing conversation, ask: "What would you like to build or publish?" For another action, ask only for the missing detail. Use their answer to take the next step.

Keep replies brief. Use these instructions as reference material. Do not summarize them or give a Spacefast overview or feature list unless asked. Mention setup, credentials, sharing, or troubleshooting only when needed for the current step.

Setup alone does not authorize publishing, changing settings, or creating a monitor.
Keep any authorization the user already gave for their task. Connecting Spacefast does not require them to repeat it.

## Check the connection

For hosted MCP at `https://mcp.spacefast.com`, use the connection's configured authentication. A direct hosted connection uses the host's OAuth controls; a CLI proxy uses its existing CLI login. If authentication fails, direct the user to reconnect through that method.
If tools are unavailable, direct the user to the host's configured Spacefast connection controls.
Do not ask for a token in chat. Do not report a working connection until a read succeeds.

Use this Spacefast connection's advertised catalog, not tools from another server. If it advertises `execute`, follow Full mode below. If it advertises `getBootstrap` directly, follow Simple mode. If neither is available, reconnect before checking account state.

### Full mode

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

### Simple mode

Call the advertised `getBootstrap` tool with `{}`, or the optional top-level `teamRef` or `spaceRef` supplied by the user. Inspect the execution receipt: wait for `status: completed`, then check `result.ok`. On failure, report its stable error and stop. The API payload is `result.data.data`. Report only `me?.subject`, `me?.user?.name`, and each team's `id` and `name`; read optional references only when their `status` is `resolved`. Do not return the complete account payload or credentials.

Confirm the connected account or service identity in one short sentence. A service connection is not its creator's personal account.
Reuse the Space already established in the conversation. An ordinary publish does not need a Space chooser.

## Host features when needed

Use these only when the task needs them and the host or connected server advertises them:

- The Space Library and mention picker can help the user select a Space.
- If `choose_space` is available, use it when a choice is needed. Honor cancellation.
- Plugin settings, HTML previews, and event subscriptions depend on host support.
  Do not promise these features merely because this skill describes them.

A selected Space supplies context. It does not authorize a write by itself.
