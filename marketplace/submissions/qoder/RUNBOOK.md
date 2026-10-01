# Qoder plugin marketplace submission

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

- Door: https://qoder.com/account/apphub-publications
- Mechanism: portal
- Source: https://qoder.com/marketplace
- Source commit: `309185424b5cc4bfc2b8367d0bd6b6f222ed75f2`
- Public plugin commit: `{{PLUGINS_SHA}}`
- Slug: `spacefast` (final; do not rename)
- Privacy: https://automattic.com/privacy/
- Terms: https://wordpress.com/tos/
- Reviewer account pointer: GitHub marketplace-reviewers environment: SPACEFAST_REVIEWER_ACCOUNT

## Upload or paste

- `marketplace/submissions/qoder/entry.json`
- `plugins/assets/logo-400.png`
- `plugins/assets/logo.svg`

## Final upstream check

Use the generated entry as the pre-drafted portal, issue, API, or repository submission payload. Do not rewrite store copy by hand.

The store copy, commands, URLs, keywords, and asset paths in these files are generated. Do not edit them by hand. The plugin sends no hook telemetry. CLI setup telemetry is disclosed before use and can be disabled with `SPACEFAST_TELEMETRY_DISABLED=1 or DO_NOT_TRACK=1`.
