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

Read the connected account through the advertised Spacefast catalog:

1. When `getAccount` is advertised as a tool, read its schema and call it directly with `{}`.
   The host may load it through tool search. For a user-supplied reference, add the optional
   `teamRef` or `spaceRef` field at the top level.
2. If the connection instead advertises `search` and `execute` for API work, find
   `getAccount` and its contract with `search`, then call the discovered path in `execute`.
   Follow the connected server's program instructions in `spacefast://skills/execute`.
3. Check the returned status and `result.ok`. Preserve a failed result and its next action.
   A completed read's account payload is at `result.data.data`.
4. Report only the subject or account name and the relevant team names and IDs.
   Use optional reference values only when their `status` is `resolved`.
   Do not return the complete account payload or credentials.

If neither calling convention is available, reconnect before checking account state.
Tools from another server are not part of this connection.

Confirm the connected account or service identity in one short sentence. A service connection is not its creator's personal account.
Reuse the Space already established in the conversation. An ordinary publish does not need a Space chooser.

## Host features when needed

Use these only when the task needs them and the host or connected server advertises them:

- The Space Library and mention picker can help the user select a Space.
- If `choose_space` is available, use it when a choice is needed. Honor cancellation.
- Plugin settings, HTML previews, and event subscriptions depend on host support.
  Do not promise these features merely because this skill describes them.

A selected Space supplies context. It does not authorize a write by itself.
