import { readFileSync } from "node:fs";

const reminder =
  "Before publishing or deploying new or changed source, run the verify-design-system skill against current saved standards and the exact source/build being deployed. Inspect affected pages and states at desktop and mobile widths, and report gaps. Reuse verification only while the source/build and design revision are unchanged. Report missing standards as unavailable, not a pass. Verify before a source-workspace commit when autoDeploy is enabled. Follow the user's existing publication intent and approval rules.";
let event;
try {
  event = JSON.parse(readFileSync(0, "utf8"));
} catch {
  process.exit(0);
}

const tool = event?.tool_name;
const input = event?.tool_input;
if (tool?.constructor === String && input?.constructor === Object) {
  let deployment = false;
  if (/^mcp__(?:plugin_spacefast(?:[-_]local)?_)?spacefast(?:[-_]local)?__publish$/.test(tool)) {
    deployment = true;
  } else if (
    /^mcp__(?:plugin_spacefast(?:[-_]local)?_)?spacefast(?:[-_]local)?__execute$/.test(tool)
  ) {
    deployment =
      input.code?.constructor === String &&
      /\b(?:createPublish|createSpaceBuild|retryBuild|finalizeSpaceVersion|promoteSpaceVersion|commitSpaceSourceWorkspaceChanges)\b/.test(
        input.code,
      );
  } else if (/^(?:Bash|PowerShell|exec_command|shell_command)$/.test(tool)) {
    const command = input.command ?? input.cmd;
    // Match command positions, rather than examples printed with echo or read from docs.
    const cli =
      /(?:^|[\n;&|])\s*(?:env\s+)?(?:[A-Za-z_]\w*=(?:"[^"]*"|'[^']*'|[^\s;&|]+)\s+)*(?:(?:[^\s"';&|]*[\\/])?sf(?:\.exe)?|"[^"\n]*[\\/]sf(?:\.exe)?"|'[^'\n]*[\\/]sf(?:\.exe)?'|(?:npx|bunx|bun\s+x)\s+(?:(?:-y|--yes)\s+)?(?:spacefast|@spacefast\/cli)(?:@[^\s;&|]+)?)\s+(?:publish|build|promote|redeploy|git\s+build|builds\s+retry)\b/;
    deployment = command?.constructor === String && cli.test(command);
  }
  if (deployment) {
    process.stdout.write(
      JSON.stringify({
        hookSpecificOutput: {
          hookEventName: "PreToolUse",
          additionalContext:
            reminder +
            " This reminder is advisory; do not replay a publish that already completed.",
        },
      }) + "\n",
    );
  }
}
