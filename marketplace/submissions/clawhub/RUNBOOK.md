# ClawHub (OpenClaw) submission

Status: **Blocked by hard-gate prerequisites**  
Customer-facing availability: **Not listed**  
Verified: **2026-08-27**

## Hard-gate blockers

- `published_setup_ui`
- `downstream_setup_ui_pins`
- `openai_app_registration`
- `live_openai_challenge`
- `reviewer_account`
- `submission_day_reverification`

## Submit

- Door: https://clawhub.ai
- Mechanism: cli_publish
- Source: https://docs.openclaw.ai/clawhub/cli
- Source commit: `6e6aaa55e82c26ae5ae77654cb268c4eace06ceb`
- Public plugin commit: `{{PLUGINS_SHA}}`
- Slug: `spacefast` (final; do not rename)
- Privacy: https://automattic.com/privacy/
- Terms: https://automattic.com/tos/
- Support: https://automattic.com/contact/
- Reviewer account pointer: GitHub marketplace-reviewers environment: SPACEFAST_REVIEWER_ACCOUNT

## Upload or paste

- `marketplace/submissions/clawhub/entry.json`
- `plugins/claude-code/.claude-plugin/plugin.json`
- `plugins/claude-code/.mcp.json`
- `plugins/assets/logo.png`
- `plugins/assets/logo-400.png`
- `plugins/assets/logo.svg`

## Final upstream check

OpenClaw loads Claude bundles, including their skills and the MCP servers in `.mcp.json`. The Claude Code plugin's `.mcp.json` still names the hosted server (`https://mcp.spacefast.com`), so a bundle published today installs hosted MCP, not On-Device stdio. Publish after that file switches to `npx -y spacefast mcp`, or confirm hosted sign-in works with `openclaw mcp login spacefast`. Publish the Claude Code plugin folder as a Claude bundle from the released `spacefast/plugins` tag: `clawhub login` (device approval with the publishing GitHub account), then `clawhub package publish ./claude-code --family bundle-plugin --bundle-format claude --dry-run`, and the same command without `--dry-run` once the plan is right. ClawHub scans each release automatically; a held release stays visible only in its owner's dashboard. Before publishing, check the install path with `openclaw plugins install spacefast --marketplace spacefast/plugins`.

The store copy, commands, URLs, keywords, and asset paths in these files are generated. Do not edit them by hand. The plugin sends no hook telemetry. CLI setup telemetry is disclosed before use and can be disabled with `SPACEFAST_TELEMETRY_DISABLED=1 or DO_NOT_TRACK=1`.
