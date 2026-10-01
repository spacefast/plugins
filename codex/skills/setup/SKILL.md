---
name: setup
description: "Set up the Spacefast plugin after installation or when the user asks to check its connection and available features."
---

# Set up Spacefast

Check the connection, then give the user a short introduction based on what this host supports.
Setup does not authorize publishing, changing settings, or creating a monitor.

## Check the connection

Cloud MCP at `https://mcp.spacefast.com` requires browser OAuth before any tool runs. If its tools are
unavailable or authentication fails, direct the user to connect Spacefast in the host's plugin
settings. Do not ask for a token in chat. Do not claim the connection works until a read succeeds.

Use one bounded `execute` program to read the account and teams:

1. Call `tools.search({ query: "Get account identity and teams", limit: 10 })`. Select the item
   whose `path` ends with `.account.getBootstrap`. If needed, follow `nextOffset` for at most
   three pages. Do not use the separate connector `search` tool for this API operation.
2. Call `tools.describe.tool({ path: item.path })`. Read `inputTypeScript` and `outputTypeScript`.
3. Call `tools[item.path]({})`, or include an existing user-provided team or Space reference as
   the described input allows. On `ok: false`, return its error and stop. Do not guess another path.
4. Read `result.data.data` as the bootstrap payload. Return only its subject, user display name,
   and team names needed for setup. Read optional reference values only when `status` is
   `resolved`. Do not dump the account payload or any credential.

Report the connected account or service identity. A service connection is not its creator's
personal account. Reuse the current task's known Space; do not require a chooser for an ordinary
publish. If choosing a Space helps the user, call `choose_space`; honor cancel or decline.

## Introduce the available entrypoints

- **Your Spaces** opens the Space Library from the sidebar or a conversation tab. The library
  supports search, pagination, detail links, deep links, and host-supported display modes.
- The composer mention picker and the library's **Add to chat** button attach a chosen Space.
  Removing an attachment must leave it removed. The mounted library tools let the agent inspect
  the view, search, and select a Space without automatically attaching it.
- Native plugin settings offer `pageSize` (10–50, default 20) and `showStatus` (default true).
  Leave these unchanged unless the user asks. For requested changes through `execute`, discover
  and describe `getPluginSettings` and `updatePluginSettings`, update only the requested fields,
  then verify with a read. Team and service connections cannot write personal settings.
- Desktop **HTML Preview** opens host-provided HTML or HTM files. **Save** writes only the opened
  file, subject to host write support and conflict checks. It does not publish anything. Use the
  regular Spacefast publishing skill only when publishing is part of the user's request.
- `choose_space` uses rich forms when supported, standard forms otherwise, or returns choices
  for chat. A selected Space is context, not permission for a later write.
- Cloud MCP exposes durable Space events to hosts that support MCP Events. For a requested
  monitor, use the host's event subscription flow and advertised event list. Do not invent a
  callback URL or secret, and do not claim a subscription exists without a successful result.

Mention only the features useful for the current task. The packaged [plugin guide](../../README.md)
has the full overview. Continue the user's existing task once setup is verified.
