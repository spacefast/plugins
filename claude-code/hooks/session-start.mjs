import { readFile } from "node:fs/promises";
import path from "node:path";

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
    `Spacefast project detected. This directory is linked to ${space}${live}. Use the Spacefast skill and preserve .spacefast/space.json. Treat .spacefast/state.json as credential material: never print, commit, or archive it.\n`,
  );
}
