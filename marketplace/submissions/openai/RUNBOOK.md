# OpenAI plugin directory submission

Status: **Live**  
Customer-facing availability: **Available**  
Verified: **2026-10-12**

## Hard-gate blockers

- Version 1.0.1 is published. Version 1.0.3 still needs package validation and portal review checks.

## Submit

- Door: https://platform.openai.com/plugins
- Mechanism: portal
- Source: https://developers.openai.com/plugins/deploy/submission
- Source commit: `c50bc33efe8adc998e4f3177d9380b989267e210`
- Public plugin commit: `{{PLUGINS_SHA}}`
- Slug: `app-6aa80fbfddb0819188f1304e303c856d` (final; do not rename)
- Privacy: https://automattic.com/privacy/
- Terms: https://wordpress.com/tos/
- Support: https://automattic.com/contact/
- Reviewer account pointer: GitHub marketplace-reviewers environment: SPACEFAST_REVIEWER_ACCOUNT

## Upload or paste

- `marketplace/submissions/openai/entry.json`
- `dist/openai-plugin/spacefast-openai-1.0.3.zip`
- `plugins/assets/logo-400.png`
- `plugins/assets/logo.svg`

## Final upstream check

Build the public upload with `bun scripts/marketplaces/openai-package.mjs`. Upload `dist/openai-plugin/spacefast-openai-1.0.3.zip` as a new draft of the existing `app-6aa80fbfddb0819188f1304e303c856d` plugin. Connect the declared MCP server through OAuth in the portal. Check the imported listing, skills, review cases, and release notes on the saved version. The portal creates its app binding; author uploads must not include `.app.json` or the manifest's `apps` field. Preserve bindings in native or private plugin distributions. Draft upload does not submit the version for review or publish it.

The tools array describes this source version's hosted simple MCP catalog for the declared endpoint. Simple mode exposes each first-party Spacefast API operation as a named tool with its input schema. It retains publishing, Space Apps, and approval continuations. Connected-service tools are unavailable on this surface. resume_execution continues a saved execution after its approval decision. Verify the deployed authenticated catalog before submission; source metadata does not establish directory approval.

The store copy, commands, URLs, keywords, and asset paths in these files are generated. Do not edit them by hand. The plugin sends no hook telemetry. CLI setup telemetry is disclosed before use and can be disabled with `SPACEFAST_TELEMETRY_DISABLED=1 or DO_NOT_TRACK=1`.
