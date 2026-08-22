---
name: spacefast-references
description: "Deep reference for the Spacefast MCP plugin skill — hosted vs On-Device, skills/execute routing, approval/resume, and catalog notes. Loaded on demand from SKILL.md."
---

# Spacefast — References

Deep reference for the Spacefast skill. The router and the load-bearing publish path live in
`SKILL.md`. This file holds everything an agent loads only when the task needs it. Nothing here
overrides the safety rules in `SKILL.md`.

## Skills And Docs Tools

Call `skills` with no args to list workflows. Pass `query` to search. Pass exact `name` for the
full recipe (instructions + verification). Recipes include `publish-and-verify`,
`create-and-publish-site`, `claim-flow`, `rollback-safely`, `ci-github-actions`, and others.

Use `execute` to search the OpenAPI catalog for capability, limits, domains, access control, and error recovery.
Website mirrors: https://spacefast.com/docs/agents · https://spacefast.com/docs/llms.txt

## Hosted Vs On-Device

Hosted Streamable HTTP: `https://mcp.spacefast.com` (OAuth, `mcp:tools`). It has no filesystem;
publish small generated files inline or use catalog manifest and signed-upload operations for larger artifacts.

On-Device (`spacefast-local` / `npx -y spacefast mcp`): path-based `publish` and local `.spacefast/`
custody.

Both runtimes expose exactly four tools: `execute`, `skills`, `resume`, and `publish`.

## Update And Claim

Prefer current local state when present (walk up from the working directory):

- project state: `.spacefast/state.json` (and non-secret `.spacefast/space.json`)
- auth state: `~/.spacefast/auth.json`

On-Device reuses checkout state automatically. Never commit space keys; never ask the user to
paste them. After browser claim, follow the `claim-flow` skill through `execute`.

## Approvals And Execute

`execute` runs read-only JavaScript immediately. Mutating JavaScript is previewed and returns
`approval_required`. Show the preview; use `approval.url` or native elicitation when present;
then `resume` with the public `elicitationId`. Use `tools.search` and `tools.describe` before
code-mode mutation. Do not run generated Spacefast JavaScript in the shell.

## Signed Uploads

For large hosted artifacts, use manifest or signed-upload operations instead of base64 in
tool arguments. Catalog operations (`prepare_publish`, `finalize_publish`, …) are discovered
through `execute` → `tools.search`. Treat upload tokens as secrets.

## Product Rules

- `space` is the main object; `publish` is the canonical action. Deploying is publishing: a
  deployment is a version, and the canonical nouns are version, channel, and build.
- `version` is an immutable snapshot.
- `API key`, `space key`, and `claim link` have distinct meanings.
- New spaces are private until explicit Grants widen access.

## References

- Agent guide: https://spacefast.com/docs/agents
- API docs and OpenAPI: https://spacefast.com/docs/api
- CLI docs: https://spacefast.com/docs/cli
- Publish contract: https://spacefast.com/publish-spec.json
- Error reference: https://spacefast.com/docs/errors
- Machine-readable index: https://spacefast.com/docs/llms.txt
