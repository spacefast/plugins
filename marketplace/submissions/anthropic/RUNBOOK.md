# Anthropic plugin directory submission

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

- Door: https://platform.claude.com/plugins/submit
- Mechanism: portal
- Source: https://code.claude.com/docs/en/discover-plugins
- Source commit: `ec261f072b7f1c80a6b778f151ba17b7dcd377f0`
- Public plugin commit: `{{PLUGINS_SHA}}`
- Slug: `spacefast` (final; do not rename)
- Privacy: https://automattic.com/privacy/
- Terms: https://wordpress.com/tos/
- Support: mailto:support@spacefast.com
- Reviewer account pointer: GitHub marketplace-reviewers environment: SPACEFAST_REVIEWER_ACCOUNT

## Upload or paste

- `marketplace/submissions/anthropic/entry.json`
- `plugins/assets/logo-400.png`
- `plugins/assets/logo.svg`

## Final upstream check

Use the generated entry's tools, App-only callback names, server instructions, and prompt examples for the hosted Claude declaration. These fields use the Claude client profile. They describe this source version, not the currently deployed endpoint. Re-check the deployed connection before submitting them.

The tools array contains the static Spacefast catalog for this source version. Authenticated tools/list also advertises individually named connected-service tools for the caller's available accounts and grants. Their exact names, descriptions, annotations, and provider schemas come from those connections, so this file is not an exhaustive authenticated catalog. Capture tools/list from the deployed review connection before submission. Initial connector inputs use { arguments: providerArgs }; a paused call continues through the same named tool with { continuation: { executionId } } after the human decides at its approval URL.

Individually named connector tools do not establish directory approval. Verify the directory's third-party API custody requirements before submission.

The store copy, commands, URLs, keywords, and asset paths in these files are generated. Do not edit them by hand. The plugin sends no hook telemetry. CLI setup telemetry is disclosed before use and can be disabled with `SPACEFAST_TELEMETRY_DISABLED=1 or DO_NOT_TRACK=1`.
