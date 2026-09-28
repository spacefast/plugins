# Spacefast plugins

Publish files and folders with Spacefast from Claude Code, Claude Desktop, Codex, or
Cursor. Each plugin includes the instructions and MCP configuration its client needs.

## Install

### Claude Code

```bash
claude plugin marketplace add spacefast/plugins
claude plugin install spacefast@spacefast
```

[Claude Code setup](./claude-code/)

### Claude Desktop

Download [`spacefast.mcpb`](https://github.com/spacefast/plugins/releases/latest/download/spacefast.mcpb)
and open it in Claude Desktop.

[Claude Desktop setup](./claude-desktop/)

### Codex

```bash
codex plugin marketplace add spacefast/plugins
codex plugin add spacefast@spacefast
```

[Codex setup](./codex/)

### Cursor

[Install the released Cursor plugin](./cursor/).

### Skill only

Use the standalone skill when your agent supports skills but not plugins:

```bash
npx -y skills add spacefast/plugins --skill spacefast -g -y
```

## Use

Ask your agent: **Publish this project with Spacefast.**

Use `sf publish` for local files. Anonymous publishes need no account and return a live URL
plus a one-time claim link. Run `sf login` to publish into your team. The hosted MCP connection
requires a separate browser OAuth sign-in before its tools can run.

The skill files in this repository follow the current MCP tools. Downloadable plugin archives
and release metadata describe the last packaged release; this skill refresh does not replace them.

## Guides

- [Agent guide](https://spacefast.com/docs/agents)
- [CLI reference](https://spacefast.com/docs/cli)
- [Latest release](https://github.com/spacefast/plugins/releases/latest)
