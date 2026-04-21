# sac

Binary-only public mirror for SeaArt CLI.

This repository intentionally does **not** include source code. The full source repository is maintained separately. This public mirror only ships:

- basic usage docs
- `SKILL.md` for agent usage
- `install.sh` for no-brainer installation
- GitHub Releases for binary distribution

## For Claude Code

If an agent receives this repository URL, the expected flow is:

1. Read `SKILL.md`
2. Run `bash install.sh`
3. Verify with `sac --version` and `sac auth status`

## Mirror Metadata

Mirror metadata:

- `VERSION`: mirrored CLI version
- `SOURCE_COMMIT`: GitLab source commit used for this public mirror
- `MIRROR.json`: machine-readable mirror metadata

Current public release tag: `v0.4.9`

Download binaries from:

[https://github.com/duyu654/SeaArt_CLI/releases/tag/v0.4.9](https://github.com/duyu654/SeaArt_CLI/releases/tag/v0.4.9)

## Fast Install

From a cloned repository:

```bash
bash install.sh
```

Default install target is `~/.local/bin`, so no elevated privileges are required.

If you explicitly want a system-wide location, choose it yourself:

```bash
SAC_INSTALL_DIR=/usr/local/bin bash install.sh
```

## Install

### macOS Apple Silicon

```bash
curl -L -o sac https://github.com/duyu654/SeaArt_CLI/releases/download/v0.4.9/sac-0.4.9-darwin-arm64
chmod +x sac
mkdir -p "$HOME/.local/bin"
mv sac "$HOME/.local/bin/sac"
```

### macOS Intel

```bash
curl -L -o sac https://github.com/duyu654/SeaArt_CLI/releases/download/v0.4.9/sac-0.4.9-darwin-x64
chmod +x sac
mkdir -p "$HOME/.local/bin"
mv sac "$HOME/.local/bin/sac"
```

### Linux x64

```bash
curl -L -o sac https://github.com/duyu654/SeaArt_CLI/releases/download/v0.4.9/sac-0.4.9-linux-x64
chmod +x sac
mkdir -p "$HOME/.local/bin"
mv sac "$HOME/.local/bin/sac"
```

### Windows x64

Download `sac-0.4.9-windows-x64.exe` from the release page and place it somewhere in your `PATH`, or rename it to `sac.exe`.

## Verify

```bash
sac --version
sac auth status
```

## Authentication

```bash
sac auth login --api-key sa-xxxxxxxx
```

Or:

```bash
export SAC_API_KEY=sa-xxxxxxxx
```

## Quick Start

```bash
sac generate image --prompt "a cat in space"
sac generate video --prompt "a fox in snow"
sac generate audio --prompt "epic orchestral theme"
sac generate 3d --prompt "a stylized toy robot"
```

## For Agents

Read `SKILL.md` first.

Recommended baseline:

```bash
sac --non-interactive --quiet --output json <command> [flags]
```

Some modes are intentionally text-only and reject `--output json`, including `chat --stream`, interactive `chat`, `generate task --output-only-url`, and `update`.
