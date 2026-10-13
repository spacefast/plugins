# OpenAI plugin directory submission

Status: **Live**  
Customer-facing availability: **Available**  
Verified: **2026-10-12**

## Hard-gate blockers

- Version 1.0.1 is published. Version 1.0.2 still needs package validation and portal review checks.

## Submit

- Door: https://platform.openai.com/plugins
- Mechanism: portal
- Source: https://developers.openai.com/plugins/deploy/submission
- Source commit: `5d3b180d670d84d5535e77e9a992042a4e5485ec`
- Public plugin commit: `{{PLUGINS_SHA}}`
- Slug: `app-6aa80fbfddb0819188f1304e303c856d` (final; do not rename)
- Privacy: https://automattic.com/privacy/
- Terms: https://wordpress.com/tos/
- Support: https://automattic.com/contact/
- Reviewer account pointer: GitHub marketplace-reviewers environment: SPACEFAST_REVIEWER_ACCOUNT

## Upload or paste

- `marketplace/submissions/openai/entry.json`
- `dist/openai-plugin/spacefast-openai-1.0.2.zip`
- `plugins/assets/logo-400.png`
- `plugins/assets/logo.svg`

## Final upstream check

Build the public upload with `bun scripts/marketplaces/openai-package.mjs`. Upload `dist/openai-plugin/spacefast-openai-1.0.2.zip` as a new draft of the existing `app-6aa80fbfddb0819188f1304e303c856d` plugin. Connect the declared MCP server through OAuth in the portal. Check the imported listing, skills, review cases, and release notes on the saved version. The portal creates its app binding; author uploads must not include `.app.json` or the manifest's `apps` field. Preserve bindings in native or private plugin distributions. Draft upload does not submit the version for review or publish it.

The tools array describes this source version's compact MCP catalog, shared by every client. Spacefast API operations are discovered and called inside execute; resume_execution continues the saved program. Third-party services connected in Spacefast use one tool, search_and_execute_tools_connected_in_spacefast. Its search action returns available accounts, exact operation addresses, provider input schemas, safety, and policy under the caller's grants. Its execute action takes a discovered address and provider arguments; its resume action polls the saved executionId after a human decides at the approval URL. Connected operations are returned by discovery rather than added to tools/list. Verify the deployed authenticated catalog and gateway behavior before submission; source metadata does not establish directory approval.

The store copy, commands, URLs, keywords, and asset paths in these files are generated. Do not edit them by hand. The plugin sends no hook telemetry. CLI setup telemetry is disclosed before use and can be disabled with `SPACEFAST_TELEMETRY_DISABLED=1 or DO_NOT_TRACK=1`.
