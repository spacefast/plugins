# Cline Marketplace submission

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

- Door: https://github.com/cline/marketplace/compare
- Mechanism: pull_request
- Source: https://github.com/cline/marketplace
- Source commit: `56ee46c0c771c59fc31724ec024ae48cb8270bc1`
- Public plugin commit: `{{PLUGINS_SHA}}`
- Slug: `spacefast` (final; do not rename)
- Privacy: https://automattic.com/privacy/
- Terms: https://wordpress.com/tos/
- Support: https://automattic.com/contact/
- Reviewer account pointer: GitHub marketplace-reviewers environment: SPACEFAST_REVIEWER_ACCOUNT

## Upload or paste

- `marketplace/submissions/cline/entry.json`
- `marketplace/submissions/cline/registry/mcps/spacefast/entry.json`
- `plugins/assets/logo-400.png`
- `plugins/assets/logo.svg`

## Final upstream check

Copy the generated `registry/mcps/spacefast/entry.json` path into the upstream checkout and run `npm run validate`. Do not set the reserved `verified` or `featured` fields.

The store copy, commands, URLs, keywords, and asset paths in these files are generated. Do not edit them by hand. The plugin sends no hook telemetry. CLI setup telemetry is disclosed before use and can be disabled with `SPACEFAST_TELEMETRY_DISABLED=1 or DO_NOT_TRACK=1`.
