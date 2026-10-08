# Kimi Code plugin marketplace submission

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

- Door: https://github.com/MoonshotAI/kimi-code/compare
- Mechanism: pull_request
- Source: https://github.com/MoonshotAI/kimi-code
- Source commit: `3219e10707dc3ac5d3c9992aaf1c945c74335b1c`
- Public plugin commit: `{{PLUGINS_SHA}}`
- Slug: `spacefast` (final; do not rename)
- Privacy: https://automattic.com/privacy/
- Terms: https://wordpress.com/tos/
- Support: https://automattic.com/contact/
- Reviewer account pointer: GitHub marketplace-reviewers environment: SPACEFAST_REVIEWER_ACCOUNT

## Upload or paste

- `marketplace/submissions/kimi/entry.json`
- `marketplace/submissions/kimi/plugins/marketplace.spacefast.json`
- `plugins/assets/logo-400.png`
- `plugins/assets/logo.svg`

## Final upstream check

Append the generated object to `plugins/marketplace.json`, run the repository checks, and open a PR. Kimi does not document a separate public submission form.

The store copy, commands, URLs, keywords, and asset paths in these files are generated. Do not edit them by hand. The plugin sends no hook telemetry. CLI setup telemetry is disclosed before use and can be disabled with `SPACEFAST_TELEMETRY_DISABLED=1 or DO_NOT_TRACK=1`.
