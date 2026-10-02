---
name: spacefast-references
description: "Deep reference for Spacefast MCP: connectors, source sync and recovery, and product nouns. Load it from SKILL.md only when needed."
---

# Spacefast references

The router and the load-bearing publish and edit paths live in `SKILL.md`. This file holds what an
agent loads only when the task needs it. Nothing here overrides the safety rules in `SKILL.md`.

## Connectors

A connector is a tool source registered for the team: an OpenAPI spec, a GraphQL endpoint, or a remote MCP server. A connection is one authenticated account on it. `search()` with no arguments lists the connectors, how many connections each has, and a few representative tools. `search({ connector })` lists one connector's tools; `search({ query })` searches tool names and summaries across everything you can reach. Every listed tool carries an `address`, its `safety`, and the `effect` policy resolved for it: `approve`, `require_approval`, or `block`.

Call the connector namespace inside one `execute` program, for example `tools.linear.mutation.issueCreate({ input: { teamId, title } })` on a Linear GraphQL connector. Use `tools.search` and `tools.describe.tool` in the program to find names and argument types. Calls use the caller's grants and connection policy; credentials stay outside the program. A bare connector slug requires exactly one usable connection; with several accounts use `tools.<connector>.<connectionId>.<tool>(args)` with the connection id from search, or the run returns `connection_ambiguous`.

A call that resolves to `require_approval` parks the run: `execute` returns `awaiting_approval` with a `runId` prefixed `cxr_` and an `approvalUrl`. Continue it with `resume_execution` under the approval rules. A parked run survives the request that created it but expires; when it does, submit the work again. Never send `accept` for a user who has not seen the action.

Do not ask for a credential; no endpoint returns one. If nothing is connected, tell the user to connect it in the dashboard. Do not retry a `block` against another address.

## Source editing

CodeStorage stores base, staged, and working snapshots on protected workspace refs. Postgres stores
coordination metadata. Agents manage this state; the Apps only display it. The workflow itself is in
`SKILL.md`; these are the paths around it.

On branch movement, call the workspace sync operation. It replays staging first, then working changes. Resolve each returned conflict with complete contents, an explicit deletion, or a verified pinned side. Read the result because another phase can have more conflicts.

A restore replaces selected working files from staging or a saved commit. Undo applies the inverse of a non-merge commit to working files. Neither changes staging, commits, deployments, or saved history. Never send a display patch as an input patch.

Connected repositories are read-only through these source tools. Use their established upstream workflow for changes.

History follows first parents. Keep the source commit pinned across pages. Use source comparison for saved Git source and deployment comparison for served artifacts. Reading deployment contents requires `versions:download`.

Show compact cards instead of repeating full trees or logs when the work mode calls for review. Do not expose internal staging refs. Do not invent a form that asks the user to trigger a write; Apps carry only the writes they support.

## Plan-gated behavior

Do not guess whether a team is on a free or paid plan. Publish the intended artifact, then read
and report the API or runtime diagnostics. When a feature is plan-gated, say exactly what the
diagnostic says, in this wording: "Not available on Free. Available on Go and Plus."
For large files, report the blocked paths and size diagnostics; do not rewrite or delete user
files unless asked. Proxy rules are not plan-gated: an unclaimed Space reaches only the trusted
hosts, and claiming opens the rest.

## Product rules

- `space` is the main object; `publish` is the canonical action. Deploying is publishing: a
  deployment is a version, and the canonical nouns are version, channel, and build.
- `version` is an immutable snapshot. `domain` is user-facing; avoid `hostname` except for DNS
  diagnostics.
- `API key`, `space key`, and `claim link` have distinct meanings.
- New Spaces are private until explicit Grants widen access.

## References

- Agent guide: https://spacefast.com/docs/agents
- API docs and OpenAPI: https://spacefast.com/docs/api
- CLI docs: https://spacefast.com/docs/cli
- Publish contract: https://spacefast.com/publish-spec.json
- Error reference: https://spacefast.com/docs/errors
- Machine-readable index: https://spacefast.com/docs/llms.txt
