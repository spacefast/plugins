export function resolveMcpLaunchSpec(platform = process.platform, comSpec = process.env.ComSpec) {
  if (platform === "win32") {
    return {
      command: comSpec || "cmd.exe",
      args: ["/d", "/s", "/c", "npx -y spacefast mcp"],
    };
  }

  return {
    command: "npx",
    args: ["-y", "spacefast", "mcp"],
  };
}
