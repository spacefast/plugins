# Goose via the official MCP Registry submission

Status: **Version 0.5.1 published to the official MCP Registry; Goose discovery pending**  
Customer-facing availability: **Soon**  
Verified: **2026-10-09**

## Hard-gate blockers

- None for the published registry version.

For a future update, validate the canonical `server.json` and authenticate ownership of the `io.github.spacefast` namespace. Use a new version if the published metadata changes. A reviewer account is not required.

## Submit

- Door: https://registry.modelcontextprotocol.io
- Mechanism: oidc_publish
- Source: https://github.com/aaif-goose/goose/discussions/10830
- Source commit: `56ee46c0c771c59fc31724ec024ae48cb8270bc1`
- Public plugin commit: `{{PLUGINS_SHA}}`
- Slug: `io.github.spacefast/mcp` (final; do not rename)
- Privacy: https://automattic.com/privacy/
- Terms: https://wordpress.com/tos/
- Support: https://automattic.com/contact/
- Reviewer account pointer: Not required for the official MCP Registry.

## Upload or paste

- `marketplace/submissions/goose/entry.json`
- `server.json`

## Final upstream check

Use the canonical `server.json` and existing `io.github.spacefast/mcp` identity in the official MCP Registry. Verify the published version before publishing; an identical immutable version needs no resubmission. Goose has retired its own directory submissions and will use the official Registry when its discovery support lands. Registry publication alone does not confirm visibility in Goose. For direct installation, run `goose configure`, choose Add Extension, then Remote Extension (Streamable HTTP), and enter `https://mcp.spacefast.com`. Complete browser OAuth when prompted; no API key or custom headers are required.

The store copy, commands, URLs, keywords, and asset paths in these files are generated. Do not edit them by hand. The plugin sends no hook telemetry. CLI setup telemetry is disclosed before use and can be disabled with `SPACEFAST_TELEMETRY_DISABLED=1 or DO_NOT_TRACK=1`.
