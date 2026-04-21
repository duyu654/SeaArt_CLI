---
name: sac
description: Use sac (SeaArt CLI) to generate images, video, audio, and 3D assets, chat with LLMs, inspect task results, or manage SeaArt API credentials and config.
---

# sac Skill

Operational reference for the binary-only public mirror.

## Install

From the repository root:

```bash
bash install.sh
source ./.sac-env
```

The installer writes:

- `.sac-bin-path`: absolute installed binary path
- `.sac-env`: `PATH` export for the chosen install directory

If `sac` is still unavailable on `PATH`, invoke the binary recorded in `.sac-bin-path`.

You can also download the correct binary from the GitHub Releases page manually, place it in your `PATH`, and verify:

```bash
sac --version
```

## Authentication

Use either a stored key or an environment variable:

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

Validation behavior:

- `sac auth login` validates the key before saving it
- `401/403` means the key is invalid
- a probe response saying `Task not found.` means the key was accepted and the fake task simply does not exist
- network, timeout, or server uncertainty makes validation fail closed

Useful `--check` exit codes:

- `0`: key looks valid
- `3`: authentication failed
- `6`: network or verification uncertainty

## Agent Baseline

Use this default baseline for structured commands:

```bash
sac --non-interactive --quiet --output json <command> [flags]
```

Baseline meaning:

- `--non-interactive`: fail instead of prompting
- `--quiet`: suppress spinners and status noise
- `--output json`: machine-readable stdout when supported

Text-only modes reject `--output json` instead of ignoring it. Current examples:

- `chat --stream`
- interactive `chat`
- `generate task --output-only-url`
- `update`

## Core Capabilities

`sac` supports:

- image generation and editing
- video generation and enhancement
- audio generation
- 3D generation
- task status queries
- LLM chat and model listing
- auth and config management

## Default Model Routing

Built-in defaults currently are:

- image: `volces_seedream_4_5`
- video: `volces_seedance_1_5_pro`
- audio: `lyria_3_pro_preview`
- 3D prompt-only: `tripo3d_text_to_model`
- 3D single image: `tripo3d_image_to_model`
- 3D repeated `--image-urls`: `tripo3d_multiview_to_model`

If a persistent config default exists, that config value can override the built-in fallback where supported.

## Command Reference

### auth

```bash
sac auth login --api-key sa-xxxxxxxx
sac auth status
sac auth status --check
sac auth logout
```

`auth login`, `auth status`, and `auth logout` support `--output json`.

### generate image

```bash
sac generate image --prompt "a cat in space"
sac generate image --prompt "product shot" --model kling_v3_image --aspect-ratio 1:1
sac generate image --prompt "brand poster" --model tencent_image_creation_3 --resolution 1024:1024
sac generate image --prompt "make it anime" --image-url https://example.com/input.png --action 1
sac generate image --list-models
```

Notes:

- default model: `volces_seedream_4_5`
- use `--image-url` plus `--action 1` for image-to-image style flows
- use `--async` to return a task ID immediately
- use `--out-dir` to download generated assets locally

### generate video

```bash
sac generate video --prompt "a fox in snow"
sac generate video --prompt "car drives away" --model kling_v3_i2v --image-url https://example.com/input.png
sac generate video --model tencent_mps_super_resolution --video-url https://example.com/input.mp4 --resolution 1080P
sac generate video --prompt "commercial shot" --model alibaba_wanx26_reference --reference-urls https://example.com/ref.jpg
```

Notes:

- default model: `volces_seedance_1_5_pro`
- image-to-video models require `--image-url`
- enhancement or extension flows usually require `--video-url`
- some provider models require extra flags such as `--duration`, `--aspect-ratio`, `--resolution`, `--voice-id`, or `--lipsync-mode`

### generate audio

```bash
sac generate audio --prompt "epic orchestral theme"
sac generate audio --prompt "pop anthem" --model mureka_song_generator --lyrics "verse one..."
sac generate audio --model kling_video_to_audio --video-url https://example.com/clip.mp4 --sound-effect-prompt "rain and city ambience"
```

Notes:

- default model: `lyria_3_pro_preview`
- `mureka_song_generator` requires `--lyrics`
- `kling_video_to_audio` requires `--video-url` or `--video-id`

### generate 3d

```bash
sac generate 3d --prompt "a stylized toy robot"
sac generate 3d --image-url https://example.com/object.png
sac generate 3d --image-urls https://example.com/front.png --image-urls https://example.com/left.png --image-urls https://example.com/back.png --image-urls https://example.com/right.png
sac generate 3d --model tencent_hunyuan_3d --prompt "a carved jade dragon" --result-format GLB --enable-pbr
```

Routing rules:

- prompt only => `tripo3d_text_to_model`
- one `--image-url` => `tripo3d_image_to_model`
- repeated `--image-urls` => `tripo3d_multiview_to_model`
- mixed or Tencent-style inputs should pass `--model` explicitly

### generate task

```bash
sac generate task <task-id>
sac generate task <task-id> --output json
sac generate task <task-id> --output-only-url
```

Notes:

- use `--output json` for full task payloads
- `--output-only-url` is raw text mode and rejects JSON

### chat

```bash
sac chat --message "Hello"
sac chat --message "Summarize this text" --output json
sac chat --message "Write a poem" --stream
sac chat models
sac chat models --filter claude
sac chat set-model --model deepseek-v3-0324
```

Important behavior:

- never run bare `sac chat` from automation
- without `--message`, a TTY session starts an interactive REPL
- without `--message` in non-interactive mode, the command fails instead of hanging
- `--output json` is valid only for non-streaming single-turn chat

### config

```bash
sac config show
sac config show --output json
sac config set --key output --value json
sac config set --key timeout --value 600
sac config set --key default_chat_model --value deepseek-v3-0324
```

Useful config keys:

- `api_key`
- `output`
- `timeout`
- `default_image_model`
- `default_chat_model`
- `multimodal_base_url`
- `llm_base_url`

## Output Semantics

- TTY defaults to human-readable text
- non-TTY commands often auto-switch to JSON when structured output is supported
- force output with `--output json` or `--output text`
- commands that intentionally stream tokens or emit raw lines reject JSON instead of silently changing behavior

## Global Flags

Common global flags:

- `--api-key <token>`
- `--output json|text`
- `--timeout <seconds>`
- `--quiet`
- `--verbose`
- `--dry-run`
- `--non-interactive`
- `--async`
- `--no-color`

## Piping Patterns

```bash
sac generate image --prompt "a cat" --quiet --output json \
  | node -e "const d=JSON.parse(require('fs').readFileSync(0,'utf8')); console.log(d.urls[0])"
```

```bash
echo '[{"role":"user","content":"hello"}]' | sac chat --messages-file - --quiet --output json
```

## Exit Codes

- `0`: success
- `1`: general error
- `2`: usage or bad arguments
- `3`: authentication failed
- `4`: quota exceeded
- `5`: timeout
- `6`: network or validation uncertainty
- `10`: content filtered

## Configuration Precedence

Priority order:

- `--api-key` > `SAC_API_KEY` > config file
- `--output` > `SAC_OUTPUT` > config file > auto-detect
- `--timeout` > `SAC_TIMEOUT` > config file > `300`
