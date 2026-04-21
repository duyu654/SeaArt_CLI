---
name: sac
description: Use sac (SeaArt CLI) to generate images, video, audio, and 3D assets, chat with LLMs, inspect task results, or manage SeaArt API credentials and config.
---

# sac Skill

## Install

From the repository root:

```bash
bash install.sh
```

Or download the correct binary from the GitHub Releases page manually, place it in your `PATH`, and verify:

```bash
sac --version
```

## Authentication

```bash
sac auth login --api-key sa-xxxxxxxx
```

Or:

```bash
export SAC_API_KEY=sa-xxxxxxxx
```

Verify:

```bash
sac auth status
sac auth status --check
```

## Agent Baseline

Use this default baseline when you need machine-readable output:

```bash
sac --non-interactive --quiet --output json <command> [flags]
```

Text-only modes reject `--output json`. Current examples:

- `chat --stream`
- interactive `chat`
- `generate task --output-only-url`
- `update`

## Core Commands

### auth

```bash
sac auth login --api-key sa-xxxxxxxx
sac auth status --check
sac auth logout
```

### image

```bash
sac generate image --prompt "a cat in space"
sac generate image --prompt "product shot" --model kling_v3_image --aspect-ratio 1:1
sac generate image --list-models
```

Default model: `volces_seedream_4_5`

### video

```bash
sac generate video --prompt "a fox in snow"
sac generate video --prompt "car drives away" --model kling_v3_i2v --image-url https://example.com/input.png
sac generate video --model tencent_mps_super_resolution --video-url https://example.com/input.mp4 --resolution 1080P
```

Default model: `volces_seedance_1_5_pro`

### audio

```bash
sac generate audio --prompt "epic orchestral theme"
```

Default model: `lyria_3_pro_preview`

### 3d

```bash
sac generate 3d --prompt "a stylized toy robot"
sac generate 3d --image-url https://example.com/object.png
```

Defaults:

- prompt only => `tripo3d_text_to_model`
- one `--image-url` => `tripo3d_image_to_model`
- repeated `--image-urls` => `tripo3d_multiview_to_model`

### task

```bash
sac generate task <task-id>
```

### chat

```bash
sac chat --message "Hello"
sac chat models
```
