# Goose MCP directory submission

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

- Door: https://github.com/aaif-goose/goose/compare
- Mechanism: pull_request
- Source: https://github.com/aaif-goose/goose
- Source commit: `66f4fcf69cf7197c0c0a7487ea5e80ae8fa2cca3`
- Public plugin commit: `{{PLUGINS_SHA}}`
- Slug: `spacefast` (final; do not rename)
- Privacy: https://automattic.com/privacy/
- Terms: https://wordpress.com/tos/
- Support: https://automattic.com/contact/
- Reviewer account pointer: GitHub marketplace-reviewers environment: SPACEFAST_REVIEWER_ACCOUNT

## Upload or paste

- `marketplace/submissions/goose/entry.json`
- `marketplace/submissions/goose/documentation/static/servers.spacefast.json`
- `plugins/assets/logo-400.png`
- `plugins/assets/logo.svg`

## Final upstream check

Append the single generated array item to `documentation/static/servers.json`, preserving the upstream array, then run the repository checks.

The store copy, commands, URLs, keywords, and asset paths in these files are generated. Do not edit them by hand. The plugin sends no hook telemetry. CLI setup telemetry is disclosed before use and can be disabled with `SPACEFAST_TELEMETRY_DISABLED=1 or DO_NOT_TRACK=1`.
