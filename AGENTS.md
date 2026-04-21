# sac Public Mirror

Agent entrypoint for the binary-only public mirror of `sac`, the SeaArt CLI.

## Steps

1. Read this file first
2. Read `SKILL.md`
3. Run:

```bash
bash install.sh
source ./.sac-env
```

4. Verify:

```bash
sac --version
sac auth status
```

5. If the task requires authentication:

```bash
sac auth login --api-key sa-xxxxxxxx
sac auth status --check
```

## PATH Handling

`install.sh` writes:

- `.sac-bin-path` — absolute path to the installed binary
- `.sac-env` — `export PATH=...` statement for the install directory

After sourcing `.sac-env`, `sac` should be available. If not, use the recorded absolute path:

```bash
SAC_BIN="$(cat .sac-bin-path)"
"$SAC_BIN" --version
```

## Agent Rules

- Always prefer `sac --non-interactive --quiet --output json <command> [flags]` for structured output
- Some modes reject `--output json` by design: `chat --stream`, interactive `chat`, `generate task --output-only-url`, `update`
- Never start interactive `sac chat` from automation — always pass `--message "..."`
- If `sac` is not on `PATH`, use the absolute binary path in `.sac-bin-path`
- Treat `SKILL.md` as the authoritative command contract for flags, defaults, and output semantics
- For long-running tasks, prefer `--async` to get the task ID immediately, then poll with `sac generate task <id>`
- Pass `SAC_API_KEY` as an environment variable when `~/.sac/config.json` may not be present

## Environment Variables

| Variable | Purpose |
|---|---|
| `SAC_API_KEY` | API key (overrides config file) |
| `SAC_OUTPUT` | Force output format (`json` or `text`) |
| `SAC_TIMEOUT` | Request timeout in seconds (default: 300) |
| `SAC_MULTIMODAL_BASE_URL` | Override multimodal gateway URL |
| `SAC_LLM_BASE_URL` | Override LLM gateway URL |
| `HTTPS_PROXY` / `HTTP_PROXY` | HTTP proxy (uppercase required for Node.js fetch) |

## Command Families

### generate

```bash
sac generate image --prompt "..."
sac generate video --prompt "..."
sac generate audio --prompt "..."
sac generate 3d --prompt "..."
sac generate task <task-id>
```

Common flags: `--model`, `--async`, `--out-dir`, `--output json`

### chat

```bash
sac chat --message "..."
sac chat models
sac chat set-model --model <id>
```

### auth

```bash
sac auth login --api-key sa-xxxxxxxx
sac auth status
sac auth status --check
sac auth logout
```

### config

```bash
sac config show
sac config set --key <key> --value <value>
```

## Output Semantics

- TTY defaults to human-readable text
- Non-TTY commands auto-switch to JSON when structured output is supported
- Force with `--output json` or `--output text`
- Commands that stream tokens or emit raw lines reject `--output json` explicitly

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
