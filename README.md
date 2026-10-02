# Spacefast plugins

Turn an idea into a website, dashboard, report, or small web tool you can share. Build it in your conversation, or bring something you already made, and publish it with Spacefast.

Keep improving it through chat. Change the content or design, share a preview, choose who can open it, connect your own domain, or restore an earlier version.

Connect your Spacefast account to publish and manage your team’s Spaces.

Use Spacefast from Claude Code, Codex, or Cursor. Each plugin includes focused skills and the
MCP configuration its client needs.

## Install

### Claude Code

```bash
claude plugin marketplace add spacefast/plugins
claude plugin install spacefast@spacefast
```

[Claude Code setup](./claude-code/)

### Codex

```bash
codex plugin marketplace add spacefast/plugins
codex plugin add spacefast@spacefast
codex mcp login spacefast
```

[Codex setup](./codex/)

### Cursor

```bash
npx -y plugins add spacefast/plugins -t cursor -y
```

[Cursor setup](./cursor/)

### Skill only

Use the standalone skill when your agent supports skills but not plugins:

```bash
npx -y skills@1.5.23 add spacefast/plugins --skill spacefast -g -y
```

## Use

Ask your agent: **Publish this project with Spacefast.**

Anonymous publishes go through the CLI: `sf publish` needs no account and returns a Live URL plus a claim link. The hosted MCP connection needs browser OAuth before any tool runs. The Claude Desktop bundle runs On-Device MCP and can publish anonymously on its own.

## Telemetry

Plugin hooks send no telemetry. The CLI records only install and setup outcomes: agent, method,
outcome, reason code, CLI version, OS, and timestamp. It never sends a machine, user, team, path,
file-content, or credential identifier. Set `SPACEFAST_TELEMETRY_DISABLED=1` or `DO_NOT_TRACK=1`
to disable disclosure and delivery before any event is sent.

Raw events are retained for 30 days and aggregate counts for 90 days. See the [privacy policy](https://automattic.com/privacy/).

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

## Guides

- [Agent guide](https://spacefast.com/docs/agents)
- [CLI reference](https://spacefast.com/docs/cli)
- [Latest release](https://github.com/spacefast/plugins/releases/latest)
