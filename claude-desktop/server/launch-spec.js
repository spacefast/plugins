export function resolveMcpLaunchSpec(platform = process.platform, comSpec = process.env.ComSpec) {
  const packageSpec = "spacefast@0.5.0";
  if (platform === "win32") {
    return {
      command: comSpec || "cmd.exe",
      args: ["/d", "/s", "/c", `npx -y ${packageSpec} mcp`],
    };
  }

  return {
    command: "npx",
    args: ["-y", packageSpec, "mcp"],
  };
}
