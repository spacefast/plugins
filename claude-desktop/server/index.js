#!/usr/bin/env node
import { spawn } from "node:child_process";

import { resolveMcpLaunchSpec } from "./launch-spec.js";

const { command, args } = resolveMcpLaunchSpec();
const child = spawn(command, args, {
  env: process.env,
  stdio: "inherit",
});

child.on("exit", (code, signal) => {
  if (signal) {
    process.kill(process.pid, signal);
    return;
  }
  process.exit(code ?? 1);
});

child.on("error", (error) => {
  console.error(error);
  process.exit(1);
});
