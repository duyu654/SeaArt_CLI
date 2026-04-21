# sac for Claude Code

This repository is a binary-only public mirror for `sac`, the SeaArt CLI.

## Required Flow

1. Read this file first
2. Read `SKILL.md`
3. Run from the repository root:

```bash
bash install.sh
source ./.sac-env
```

`source ./.sac-env` only affects the current shell process. If `sac` is still not found after sourcing, use the absolute path written by the installer:

```bash
SAC_BIN="$(cat .sac-bin-path)"
"$SAC_BIN" --version
```

4. Verify:

```bash
sac --version
sac auth status
```

5. If authentication is required:

```bash
sac auth login --api-key sa-xxxxxxxx
sac auth status --check
```

## PATH Handling

`install.sh` writes two files:

- `.sac-bin-path` — absolute path to the installed binary (e.g. `/root/.local/bin/sac`)
- `.sac-env` — a one-line `export PATH=...` statement

After `source ./.sac-env`, `sac` should be available on `PATH`. If it is still not found, invoke the binary via the absolute path:

```bash
SAC_BIN="$(cat .sac-bin-path)"
"$SAC_BIN" --version
```

When writing shell tool calls inside this session, prefer the absolute path from `.sac-bin-path` over bare `sac` if there is any doubt about `PATH` propagation.

## Claude Code Hooks

Claude Code hooks let you run shell commands automatically before or after tool calls. If you want `sac` to participate in a hook workflow, use the absolute path from `.sac-bin-path` to ensure it is always found regardless of `PATH` state:

```bash
SAC_BIN="$(cat .sac-bin-path)"
```

Example `.claude/settings.json` hook that runs a `sac` command after every file write:

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

Replace `/path/to/repo` with the actual path to the cloned mirror repository. Hooks run in the environment Claude Code inherits — `PATH` mutations from `source .sac-env` do not carry over into hook processes.

## Claude Operating Rules

- Always prefer `sac --non-interactive --quiet --output json <command> [flags]` for structured output
- Do not use `--output json` with text-only modes: `chat --stream`, interactive `chat`, `generate task --output-only-url`, `update`
- Never run bare `sac chat` from automation — always pass `--message "..."`
- When `sac` is not on `PATH`, use the absolute binary path in `.sac-bin-path`
- Treat `SKILL.md` as the authoritative command contract; do not guess flags or output shape from examples alone
- For long-running generation tasks, prefer `--async` to get the task ID immediately, then poll with `sac generate task <id>`
- Pass `SAC_API_KEY` as an environment variable when you cannot guarantee `~/.sac/config.json` is present in the execution environment

## Environment Variables

| Variable | Purpose |
|---|---|
| `SAC_API_KEY` | API key (overrides config file) |
| `SAC_OUTPUT` | Force output format (`json` or `text`) |
| `SAC_TIMEOUT` | Request timeout in seconds (default: 300) |
| `SAC_MULTIMODAL_BASE_URL` | Override multimodal gateway URL |
| `SAC_LLM_BASE_URL` | Override LLM gateway URL |
| `HTTPS_PROXY` / `HTTP_PROXY` | HTTP proxy (uppercase required for Node.js fetch) |

## What sac Covers

- `sac generate image` — text-to-image, image-to-image
- `sac generate video` — text-to-video, image-to-video, video enhancement
- `sac generate audio` — music and sound generation
- `sac generate 3d` — text-to-3D, image-to-3D
- `sac generate task` — poll or fetch a task result by ID
- `sac chat` — single-turn or interactive LLM chat
- `sac chat models` — list available LLM models
- `sac chat set-model` — persist default LLM model
- `sac auth login/status/logout` — API key management
- `sac config show/set` — view and write config values

## Exit Codes

| Code | Meaning |
|---|---|
| 0 | Success |
| 1 | General error |
| 2 | Bad arguments or usage |
| 3 | Authentication failed |
| 4 | Quota exceeded |
| 5 | Timeout |
| 6 | Network or validation uncertainty |
| 10 | Content filtered |

## Notes

- Source code is intentionally not included in this repository
- `SKILL.md` is usage documentation, not a Claude-native skill installation mechanism
- `install.sh` writes `.sac-bin-path` and `.sac-env`
- The binary is a self-contained Node.js bundle; no `npm install` is required after installation
