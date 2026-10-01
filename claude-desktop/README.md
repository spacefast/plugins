# Spacefast for Claude Desktop

Publish and manage Spacefast spaces from Claude Desktop.

## Install

Download [`claude-desktop.mcpb`](https://github.com/spacefast/plugins/releases/latest/download/claude-desktop.mcpb)
and open it. If Claude Desktop does not open the bundle, go to **Settings → Extensions → Advanced
settings → Install Extension** and select the file.

## Use

Ask Claude: **Publish this with Spacefast.**

The extension runs the Spacefast On-Device MCP surface. It publishes new artifacts inline, edits Space
source files without a local checkout, and runs OpenAPI-generated management operations. Publishing a
local folder by path needs the native Linux `sf` build; on macOS and Windows, publish inline files or
use the CLI.

## Publish to your team

The API key requested during installation is optional. Leave it blank to publish anonymously and
receive a claim action.

## Telemetry

Plugin hooks send no telemetry. The CLI records only install and setup outcomes: agent, method,
outcome, reason code, CLI version, OS, and timestamp. It never sends a machine, user, team, path,
file-content, or credential identifier. Set `SPACEFAST_TELEMETRY_DISABLED=1` or `DO_NOT_TRACK=1`
to disable disclosure and delivery before any event is sent.

Raw events are retained for 30 days and aggregate counts for 90 days. See the [privacy policy](https://automattic.com/privacy/).

## Guides

- [Spacefast agent guide](https://spacefast.com/docs/agents)
- [Claude Desktop extension installation](https://support.claude.com/en/articles/10949351-getting-started-with-local-mcp-servers-on-claude-desktop)
- [Latest Spacefast release](https://github.com/spacefast/plugins/releases/latest)
