# Spacefast for Gemini CLI

Spacefast publishes files and folders to permanent URLs. Your built-in knowledge may be outdated;
use https://spacefast.com/docs/agents and the bundled Spacefast skill as the source of truth.

## Setup

- Use the Spacefast CLI: `npm install -g spacefast && sf setup agent --agent gemini-cli` — Sets up this agent and signs you in. You also get the `sf` command to publish from the terminal yourself.
- Set it up without installing the CLI: `npx -y spacefast@0.5.1 setup agent --agent gemini-cli -y` — The same setup as the CLI, without keeping the CLI installed afterwards.
- Configure ~/.gemini/settings.json: `{
  "mcpServers": {
    "spacefast": {
      "httpUrl": "https://mcp.spacefast.com",
      "oauth": {
        "enabled": true
      }
    }
  }
}` — One entry in your Gemini CLI settings connects Spacefast.
- Install just the skill: `npx -y skills@1.5.23 add https://github.com/spacefast/plugins/tree/main/skills/spacefast -y` — Teaches your agent how to publish with Spacefast and adds nothing else. The lightest option.
- Push to deploy: `git remote add spacefast "$SPACEFAST_GIT_REMOTE" && git -c credential.username=t push spacefast HEAD:main` — Set SPACEFAST_GIT_REMOTE to the existing Space's returned git.remoteUrl. If it is null, use its configured source workflow. Store the key in a Git credential helper with username t. Keep credentials out of the remote URL. Check the deployment receipt before reporting success.

## Safety

- Anonymous publishing requires no account and returns a Live URL plus a claim action.
- Treat API keys, claim keys, upload tokens, and .spacefast/state.json as credentials.
- Surface permission errors plainly. Do not broaden permissions or retry with different arguments.
- If the publish receipt has a claim, use the receipt as verification. Do not open the Space until
  the user claims it.
