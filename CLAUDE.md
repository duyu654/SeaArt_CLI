# sac for Claude Code

This repository is a binary-only public mirror for `sac`.

## Required Flow

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

5. If authentication is required:

```bash
sac auth login --api-key sa-xxxxxxxx
sac auth status --check
```

## Claude Operating Rules

- Prefer `sac --non-interactive --quiet --output json <command> [flags]` for structured commands
- Do not use `--output json` with text-only modes such as `chat --stream`, interactive `chat`, `generate task --output-only-url`, or `update`
- Never run bare `sac chat` from automation; use `sac chat --message "..."`
- When `sac` is still unavailable on `PATH`, invoke the absolute path stored in `.sac-bin-path`
- `SKILL.md` is the command contract; do not guess flags or output behavior from examples alone

## What sac Covers

- `sac generate image`
- `sac generate video`
- `sac generate audio`
- `sac generate 3d`
- `sac generate task`
- `sac chat`
- `sac auth`
- `sac config`

## Notes

- Source code is intentionally not included in this repository
- `SKILL.md` is usage documentation, not a Claude-native skill installation mechanism
- `install.sh` writes:
  - `.sac-bin-path`
  - `.sac-env`

If `sac` is still unavailable on `PATH`, invoke the absolute path stored in `.sac-bin-path`.
