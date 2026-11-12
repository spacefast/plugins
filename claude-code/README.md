# Spacefast for Claude Code

![Spacefast](assets/logo.png)

Publish local files and manage Spacefast spaces without leaving Claude Code. The plugin adds 12 task skills, a setup skill, and one hosted HTTP MCP connection.

## Install

```bash
claude plugin marketplace add spacefast/plugins
claude plugin install spacefast@spacefast
```

Run `/reload-plugins` or start a new Claude Code session after installation.

## Use

Ask Claude: **Publish this project with Spacefast.** The matching skill handles building,
publishing, editing, sharing, domains, or deployment recovery.

Anonymous publishes go through the CLI: `sf publish` needs no account and returns a Live URL plus a claim link. The hosted MCP connection needs browser OAuth before any tool runs.

## Included

- Publish files and folders, then update the same space
- Edit Space source files through MCP without a local checkout
- Inspect deployments, domains, and analytics
- Handle anonymous claim actions and account tokens safely
- Choose direct publish or hosted MCP for the job
- Hosted HTTP MCP at `https://mcp.spacefast.com` with browser OAuth

## Publish to your team

Complete the browser OAuth flow when Claude prompts you.

## Linked projects and design verification

The skills read `.spacefast/space.json` when working with a linked project and preserve its existing
Space link. Treat `.spacefast/state.json` as credential material: never print, commit, or archive it.

The publishing skills require `verify-design-system` before deploying changed work through MCP
or the CLI, including builds and promotion. Follow the user's existing task and approval requirements.

The Claude plugin includes no lifecycle hooks. These checks rely on the skill instructions.

## Data handling

Spacefast is developed by Automattic Inc. The hosted MCP connection sends the content and account
data needed for your requested task to `https://mcp.spacefast.com` over HTTPS. Spacefast reads and stores
the files, source code, and other content you choose to publish or manage. This content can
include personal data. Account and team features also use profile information such as names
and email addresses. Claude manages its OAuth credentials; the plugin does not bundle them.

If you choose to use the optional CLI, it sends API requests to `https://api.spacefast.com`
and uploads your selected files to the destinations returned by that API.
CLI transfers happen outside the declared MCP connection. Published content is served according
to the Space's access settings.

Content and account data can remain longer than 30 days. Deleting a Space takes it offline;
its content remains until Spacefast purges it. CLI install and setup telemetry goes to
`https://api.spacefast.com/v1/events` and has the separate retention periods and opt-outs below.

See the [privacy policy](https://automattic.com/privacy/), [terms of service](https://automattic.com/tos/),
and [support page](https://automattic.com/contact/).

## Telemetry

The CLI records only install and setup outcomes: agent, method,
outcome, reason code, CLI version, OS, and timestamp. It never sends a machine, user, team, path,
file-content, or credential identifier. Set `SPACEFAST_TELEMETRY_DISABLED=1` or `DO_NOT_TRACK=1`
to disable disclosure and delivery before any event is sent.

Raw events are retained for 30 days and aggregate counts for 90 days. See the [privacy policy](https://automattic.com/privacy/).

## Guides

- [Spacefast agent guide](https://spacefast.com/docs/agents)
- [Claude Code plugin installation](https://code.claude.com/docs/en/discover-plugins)
- [Spacefast CLI reference](https://spacefast.com/docs/cli)
