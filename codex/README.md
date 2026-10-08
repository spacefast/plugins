# Spacefast for Codex

Publish local files and manage Spacefast spaces from Codex. The plugin adds 10 task skills and setup,
plus one hosted Streamable HTTP MCP connection.

## Install

```bash
codex plugin marketplace add spacefast/plugins
codex plugin add spacefast@spacefast
codex mcp login spacefast
```

The Codex app opens browser OAuth during installation. The shell CLI does not run that
post-install hook yet, so the explicit login command above opens it. Start a new Codex task after
installation.

## Use

Ask Codex: **Publish this project with Spacefast.** The matching skill handles building,
publishing, editing, sharing, domains, or deployment recovery.

Anonymous publishes go through the CLI: `sf publish` needs no account and returns a Live URL plus a claim link. The hosted MCP connection needs browser OAuth before any tool runs.

## Included

- Publish files and folders, then update the same space
- Edit Space source files through MCP without a local checkout
- Inspect deployments, domains, and analytics
- Handle anonymous claim actions and account tokens safely
- Choose direct publish or hosted MCP for the job
- Hosted Streamable HTTP MCP at `https://mcp.spacefast.com` with browser OAuth

## Publish to your team

Complete the browser OAuth flow opened by the install commands.

## In ChatGPT and Codex

Open **Your Spaces** from the sidebar or a conversation tab to browse the Space Library. Search,
load more Spaces, and select one to see its live URL and dashboard link. Supported hosts can open
a Space directly through a library deep link and switch between inline and fullscreen views.

Use the Spacefast composer mention picker, or select a Space and click **Add to chat**, to include
it in the conversation. Removing that attachment leaves it removed. While the library is open,
the agent can read its selection, search, and open another Space through the mounted App tools.
When a destination is unclear, the agent can show a Space chooser. Hosts with rich forms show
descriptions and thumbnails; other hosts use their supported form or a choice in chat.

Plugin settings include **Spaces per page** (10–50, default 20) and **Show Space status** (on by
default). These settings belong to your user account. Team and service connections use defaults.

On desktop, open an HTML or HTM file with **HTML Preview** to inspect its preview and edit its
source. **Save** writes the opened file only when the host allows it. Saving does not publish the
file. External changes keep your unsaved draft; reload explicitly before replacing it.

Cloud MCP also supports durable event subscriptions for Space build, deployment, channel, and
domain changes when the host supports MCP Events. Subscriptions start only when requested;
installation does not create a monitor. Features appear only on hosts that support them.

## Design verification reminders

Linked-project session context and publishing skills remind the agent to run
`verify-design-system` before deploying changed work. A PreToolUse hook reinforces
the reminder for Spacefast MCP publishing, deployment-related execute programs,
and CLI publishing/build/promotion commands. Git pushes are not matched.

These hooks are advisory. They do not run the skill, block the pending call, or
change its arguments or approvals. The agent can read a tool-call reminder after
the call runs. Dynamic execute programs and shell wrappers may not be recognized.

Manually installed Codex plugins include the hooks. Review and trust new or changed
definitions with `/hooks` before relying on them; installation does not grant trust.
The OpenAI public-directory package includes the skill guidance but no lifecycle hooks.
See [Codex hooks](https://learn.chatgpt.com/docs/hooks) and
[plugin packaging](https://developers.openai.com/plugins/build/plugins#bundled-mcp-servers-and-lifecycle-hooks).

## Skill only

If you do not want the plugin or MCP connections, install only the skill:

```bash
npx -y skills@1.5.23 add spacefast/plugins --skill spacefast -g -y
```

## Telemetry

Plugin hooks send no telemetry. The CLI records only install and setup outcomes: agent, method,
outcome, reason code, CLI version, OS, and timestamp. It never sends a machine, user, team, path,
file-content, or credential identifier. Set `SPACEFAST_TELEMETRY_DISABLED=1` or `DO_NOT_TRACK=1`
to disable disclosure and delivery before any event is sent.

Raw events are retained for 30 days and aggregate counts for 90 days. See the [privacy policy](https://automattic.com/privacy/).

## Guides

- [Spacefast agent guide](https://spacefast.com/docs/agents)
- [Codex plugin marketplaces](https://learn.chatgpt.com/docs/build-plugins#add-a-marketplace-from-the-cli)
- [Spacefast CLI reference](https://spacefast.com/docs/cli)
