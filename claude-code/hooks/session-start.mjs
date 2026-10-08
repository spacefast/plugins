import { readFile } from "node:fs/promises";
import path from "node:path";

const reminder =
  "Before publishing or deploying new or changed source, run the verify-design-system skill against current saved standards and the exact source/build being deployed. Inspect affected pages and states at desktop and mobile widths, and report gaps. Reuse verification only while the source/build and design revision are unchanged. Report missing standards as unavailable, not a pass. Verify before a source-workspace commit when autoDeploy is enabled. Follow the user's existing publication intent and approval rules.";

async function readJson(file) {
  try {
    return JSON.parse(await readFile(file, "utf8"));
  } catch {
    return undefined;
  }
}

const marker = await readJson(path.join(process.cwd(), ".spacefast", "space.json"));
const space = marker?.space?.constructor === String ? marker.space : undefined;
if (space && space.length > 0) {
  const liveUrl = marker?.liveUrl?.constructor === String ? marker.liveUrl : undefined;
  const live = liveUrl?.startsWith("https://") ? ` at ${liveUrl}` : "";
  process.stdout.write(
    `Spacefast project detected. This directory is linked to ${space}${live}. Use the Spacefast skill and preserve .spacefast/space.json. Treat .spacefast/state.json as credential material: never print, commit, or archive it. ${reminder}\n`,
  );
}
