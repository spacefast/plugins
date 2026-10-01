# Docker MCP Catalog submission

Status: **Blocked by hard-gate prerequisites**  
Customer-facing availability: **Soon**  
Verified: **2026-08-27**

## Hard-gate blockers

- `published_setup_ui`
- `downstream_setup_ui_pins`
- `openai_app_registration`
- `live_openai_challenge`
- `reviewer_account`
- `submission_day_reverification`

## Submit

- Door: https://github.com/docker/mcp-registry
- Mechanism: pull_request
- Source: https://github.com/docker/mcp-registry
- Source commit: `bbb3507cd7c0c7e1039e151c18084aec311fbcfe`
- Public plugin commit: `{{PLUGINS_SHA}}`
- Slug: `spacefast` (final; do not rename)
- Privacy: https://automattic.com/privacy/
- Terms: https://wordpress.com/tos/
- Reviewer account pointer: GitHub marketplace-reviewers environment: SPACEFAST_REVIEWER_ACCOUNT

## Upload or paste

- `marketplace/submissions/docker/entry.json`
- `marketplace/submissions/docker/servers/spacefast/server.yaml`
- `marketplace/submissions/docker/servers/spacefast/tools.json`
- `marketplace/submissions/docker/servers/spacefast/readme.md`
- `plugins/assets/logo-400.png`
- `plugins/assets/logo.svg`

## Final upstream check

Copy the generated `servers/spacefast` directory into the upstream checkout. It is the exact three-file output shape of `task remote-wizard` for an OAuth remote server.

The store copy, commands, URLs, keywords, and asset paths in these files are generated. Do not edit them by hand. The plugin sends no hook telemetry. CLI setup telemetry is disclosed before use and can be disabled with `SPACEFAST_TELEMETRY_DISABLED=1 or DO_NOT_TRACK=1`.
