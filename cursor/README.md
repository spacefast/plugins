# Spacefast for Cursor

Publish local files and manage Spacefast spaces from Cursor. The plugin adds a project rule plus one
hosted HTTP MCP connection.

## Install

```bash
npx -y plugins add spacefast/plugins -t cursor -y
```

Restart Cursor or run **Developer: Reload Window**.

## Use

Ask Cursor: **Publish this project with Spacefast.** Cursor loads the rule when a request matches its
description: publish, deploy, host, share, or edit an existing Space.

Anonymous publishes go through the CLI: `sf publish` needs no account and returns a Live URL plus a claim link. The hosted MCP connection needs browser OAuth before any tool runs.

## Included

- Publish files and folders, then update the same space
- Edit Space source files through MCP without a local checkout
- Inspect deployments, domains, and analytics
- Handle anonymous claim actions and account tokens safely
- Choose direct publish or hosted MCP for the job
- Hosted HTTP MCP at `https://mcp.spacefast.com` with browser OAuth

## Publish to your team

Complete the browser OAuth flow when Cursor prompts you.

## Telemetry

Plugin hooks send no telemetry. The CLI records only install and setup outcomes: agent, method,
outcome, reason code, CLI version, OS, and timestamp. It never sends a machine, user, team, path,
file-content, or credential identifier. Set `SPACEFAST_TELEMETRY_DISABLED=1` or `DO_NOT_TRACK=1`
to disable disclosure and delivery before any event is sent.

Raw events are retained for 30 days and aggregate counts for 90 days. See the [privacy policy](https://automattic.com/privacy/).

## Guides

- [Spacefast agent guide](https://spacefast.com/docs/agents)
- [Cursor plugins](https://cursor.com/docs/plugins)
- [Spacefast CLI reference](https://spacefast.com/docs/cli)
