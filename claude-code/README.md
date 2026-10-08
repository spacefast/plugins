# Spacefast for Claude Code

Publish local files and manage Spacefast spaces without leaving Claude Code. The plugin adds 10 task skills and setup, linked-project and design verification hooks, and one hosted HTTP MCP connection.

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

## Telemetry

Plugin hooks send no telemetry. The CLI records only install and setup outcomes: agent, method,
outcome, reason code, CLI version, OS, and timestamp. It never sends a machine, user, team, path,
file-content, or credential identifier. Set `SPACEFAST_TELEMETRY_DISABLED=1` or `DO_NOT_TRACK=1`
to disable disclosure and delivery before any event is sent.

Raw events are retained for 30 days and aggregate counts for 90 days. See the [privacy policy](https://automattic.com/privacy/).

## Guides

- [Spacefast agent guide](https://spacefast.com/docs/agents)
- [Claude Code plugin installation](https://code.claude.com/docs/en/discover-plugins)
- [Spacefast CLI reference](https://spacefast.com/docs/cli)
