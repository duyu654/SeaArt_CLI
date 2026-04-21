# sac Public Mirror

Agent entrypoint for the binary-only public mirror.

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

## Agent Rules

- Prefer `sac --non-interactive --quiet --output json <command> [flags]`
- Some modes reject JSON by design: `chat --stream`, interactive `chat`, `generate task --output-only-url`, `update`
- Never start interactive `sac chat` from automation; pass `--message`
- If `sac` is not on `PATH`, use the absolute binary path recorded in `.sac-bin-path`
- Treat `SKILL.md` as the command contract for flags, defaults, and output semantics

## Command Families

- `auth`
- `generate image`
- `generate video`
- `generate audio`
- `generate 3d`
- `generate task`
- `chat`
- `config`
