# sac for Claude Code

Binary-only public mirror for `sac`, the SeaArt CLI.

## Required Flow

1. Read this file
2. Read `SKILL.md`
3. Install and verify:

```bash
bash install.sh
source ./.sac-env
sac --version
```

If `sac` is still not found after sourcing, use the absolute path the installer wrote:

```bash
SAC_BIN="$(cat .sac-bin-path)"
"$SAC_BIN" --version
```

In all subsequent shell commands, if `PATH` propagation is uncertain, substitute `"$(cat .sac-bin-path)"` for bare `sac`.

4. Authenticate (required before any generate or chat command):

```bash
sac auth login --api-key sa-xxxxxxxx
# or: export SAC_API_KEY=sa-xxxxxxxx
```

5. Verify authentication:

```bash
sac auth status --output json
```

Expected when authenticated:

```json
{
  "authenticated": true,
  "key": "sa-a...xxxx",
  "source": "config file",
  "config": "/root/.sac/config.json"
}
```

If `"authenticated": false`, re-run `sac auth login` or set `SAC_API_KEY`.

## Authentication Detail

`sac auth login` validates the key before saving it:

- `401/403` → key is invalid, login fails
- `404` or `Task not found` body → key accepted (probe task simply does not exist)
- network / timeout / `5xx` → validation inconclusive, login fails

`sac auth status --check` performs the same validation without mutating config:

- exit code `0` — key looks valid
- exit code `3` — key rejected
- exit code `6` — network or verification uncertainty

## Claude Operating Rules

- Always prefer `sac --non-interactive --quiet --output json <command> [flags]` for structured output
- Do not use `--output json` with text-only modes: `chat --stream`, interactive `chat`, `generate task --output-only-url`, `update`
- Never run bare `sac chat` from automation — always pass `--message "..."`; without `--message` in a non-TTY context it exits with code `2`
- For long-running generation tasks, prefer `--async` to get the task ID immediately, then poll with `sac generate task <id> --output json`
- Pass `SAC_API_KEY` as an environment variable when `~/.sac/config.json` may not be present
- `SKILL.md` is the authoritative command contract — do not guess flags or output shape from examples alone

## Claude Code Hooks

Hooks run in the environment Claude Code inherits — `PATH` mutations from `source .sac-env` do not carry into hook processes. Always use the absolute path from `.sac-bin-path` in hook commands:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "\"$(cat /path/to/repo/.sac-bin-path)\" auth status --check"
          }
        ]
      }
    ]
  }
}
```

Replace `/path/to/repo` with the absolute path to the cloned mirror repository.

## Notes

- Source code is not included in this repository
- `install.sh` writes `.sac-bin-path` and `.sac-env`; no `npm install` needed
- The binary is a self-contained Node.js bundle; see `SKILL.md` for all flags, models, and output shapes
