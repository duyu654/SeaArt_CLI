---
name: sac
description: Use sac (SeaArt CLI) to generate images, video, audio, and 3D assets, chat with LLMs, inspect task results, or manage SeaArt API credentials and config.
---

# sac Skill

Operational reference for the binary-only public mirror. Read this after `CLAUDE.md` or `AGENTS.md`.

## Install

Run from the repository root (the directory containing `install.sh`):

```bash
bash install.sh
source ./.sac-env
sac --version
```

The installer writes two files in the repository root:

- `.sac-bin-path` — absolute path to the installed binary (e.g. `/root/.local/bin/sac`)
- `.sac-env` — a single `export PATH=...` line for the install directory

`source ./.sac-env` only affects the current shell process. If `sac` is still not found after sourcing, read the absolute path and invoke it directly:

```bash
SAC_BIN="$(cat .sac-bin-path)"
"$SAC_BIN" --version
```

In all subsequent shell commands in this session, if `PATH` propagation is uncertain, substitute `"$(cat .sac-bin-path)"` for bare `sac`.

To install to a custom directory:

```bash
SAC_INSTALL_DIR=/usr/local/bin bash install.sh
```

## Authentication

**Required before any generate or chat command.**

Save a key to `~/.sac/config.json` (validates before saving):

```bash
sac auth login --api-key sa-xxxxxxxx
```

Or pass via environment variable (takes precedence over config file, no file write):

```bash
export SAC_API_KEY=sa-xxxxxxxx
```

Verify:

```bash
sac auth status          # show stored key info (no network call)
sac auth status --check  # validate key against the API (network call)
```

Validation behavior:

- `sac auth login` validates the key before saving — a stored key is always valid at save time
- `401/403` from `--check` means the key is invalid
- `Task not found` response means the key was accepted (probe task simply does not exist)
- network error, timeout, or 5xx makes `--check` exit with code `6` (uncertainty, not confirmed invalid)

`auth status --check` exit codes:

- `0` — key looks valid
- `3` — authentication failed (key rejected)
- `6` — network or verification uncertainty

Remove stored key:

```bash
sac auth logout
```

`auth login`, `auth status`, and `auth logout` all support `--output json`.

## Agent Baseline

Use this baseline for all structured commands:

```bash
sac --non-interactive --quiet --output json <command> [flags]
```

- `--non-interactive` — fail immediately instead of prompting for missing args
- `--quiet` — suppress spinners, progress lines, and info messages on stderr
- `--output json` — machine-readable stdout

**Text-only modes reject `--output json` with a usage error** — do not pass it to:

- `chat --stream`
- interactive `chat` (no `--message`)
- `generate task --output-only-url`
- `update`

## Global Flags

| Flag | Description |
|---|---|
| `--api-key <token>` | Bearer token (overrides env and config) |
| `--output json\|text` | Force output format (default: auto-detect by TTY) |
| `--timeout <seconds>` | Request timeout (default: 300) |
| `--quiet` | Suppress spinners and info messages |
| `--verbose` | Print HTTP request/response details to stderr |
| `--dry-run` | Show what would be sent without executing |
| `--non-interactive` | Fail on missing args instead of prompting |
| `--async` | Return task ID immediately without polling |
| `--no-color` | Disable ANSI colors |

## Configuration

Priority order (highest to lowest):

- command-line `--flag`
- environment variable
- `~/.sac/config.json`
- built-in default

| Key | Env var | Default |
|---|---|---|
| `api_key` | `SAC_API_KEY` | — |
| `output` | `SAC_OUTPUT` | auto-detect |
| `timeout` | `SAC_TIMEOUT` | `300` |
| `default_image_model` | — | `volces_seedream_4_5` |
| `default_chat_model` | — | `deepseek-v3-0324` |
| `multimodal_base_url` | `SAC_MULTIMODAL_BASE_URL` | SeaArt gateway |
| `llm_base_url` | `SAC_LLM_BASE_URL` | SeaArt gateway |

```bash
sac config show                                      # view current config
sac config show --output json
sac config set --key default_chat_model --value deepseek-v3-0324
sac config set --key output --value json
sac config set --key timeout --value 600
```

## Output Semantics

- TTY → human-readable text with spinners
- Non-TTY / pipe → JSON automatically when the command supports structured output
- `--output json` or `SAC_OUTPUT=json` forces JSON in any context

JSON output shapes:

| Command + flags | Shape |
|---|---|
| `generate image` (default) | `{ "task_id": "...", "urls": ["https://..."] }` |
| `generate image --out-dir` | `{ "task_id": "...", "saved": ["/path/to/file"] }` |
| `generate image --async` | `{ "task_id": "...", "status": "in_progress" }` |
| `generate video` (default) | `{ "task_id": "...", "urls": ["https://..."] }` |
| `generate audio` (default) | `{ "task_id": "...", "urls": ["https://..."] }` |
| `generate 3d` (default) | `{ "task_id": "...", "urls": ["https://..."] }` |
| `generate task <id>` | full task payload with `output[].content[].url` |
| `chat --message "..."` | `{ "content": "..." }` |
| `auth status` | `{ "status": "...", "source": "..." }` |

## Command Reference

### generate image

```bash
sac generate image --prompt "a cat in space"
sac generate image --prompt "product shot" --model kling_v3_image --aspect-ratio 1:1
sac generate image --prompt "国风山水画" --model tencent_image_creation_3 --resolution 1024:1024
sac generate image --prompt "make it anime" --image-url https://example.com/input.png --action 1
sac generate image --prompt "text" --n 2
sac generate image --prompt "text" --width 1024 --height 1024
sac generate image --prompt "text" --out-dir ./output
sac generate image --prompt "text" --async
sac generate image --list-models
sac generate image --list-models --provider volces
```

Built-in default model: `volces_seedream_4_5`

**SeaArt models**: `sdxl`, `z_image`, `z_image_turbo`

**Volces models**: `volces_seedream_5`, `volces_seedream_4_5`, `volces_seedream_4_0`, `volces_seedream_3_0`, `volces_seedream_4_5_multi_blend`, `volces_jimeng_3_1`, `volces_jimeng_3_0`, `volces_jimeng_i2i_3_0`, `volces_jimeng_tilesr`, `volces_seededit_3_0`, `volces_seededit_3_0_i2i`, `volces_seededit_single_ip`, `volces_seededit_multi_ip`, `volces_seededit_multi_style`, `volces_seededit_3d_style`, `volces_seededit_portrait`

**Alibaba models**: `alibaba_wan27_image_pro`

**Nano models**: `nano_banana_2`

**Kling models**: `kling_v3_image`, `kling_omni_image`, `kling_v3_omni_image`

**Tencent models**: `tencent_image_creation_3` (supports `--resolution`, `--seed`, `--logo-add 0|1`, `--revise 0|1`)

Key flags: `--model`, `--prompt`, `--n`, `--width`, `--height`, `--aspect-ratio`, `--resolution`, `--seed`, `--image-url`, `--action`, `--out-dir`, `--out-prefix`, `--async`

### generate video

```bash
sac generate video --prompt "a fox in snow"
sac generate video --prompt "text" --model vidu_q3_pro --async
sac generate video --prompt "text" --model kling_v3 --aspect-ratio 16:9 --duration 5
sac generate video --prompt "car drives away" --model kling_v3_i2v --image-url https://example.com/img.webp
sac generate video --model kling_avatar --image-url https://example.com/avatar.png --audio-url https://example.com/voice.mp3
sac generate video --prompt "你好" --model kling_lipsync --lipsync-mode text2video --video-url https://example.com/face.mp4 --voice-id voice_123 --voice-language zh
sac generate video --model tencent_mps_super_resolution --video-url https://example.com/input.mp4 --resolution 1080P
sac generate video --prompt "commercial" --model vidu_q3_reference --image-urls https://example.com/img.webp
sac generate video --prompt "commercial" --model alibaba_wanx26_reference --reference-urls https://example.com/img.jpg
sac generate video --prompt "a fox in snow" --model volces_seedance_3_0 --resolution 720p
sac generate video --model volces_seedance_30_i2v --image-url https://example.com/first.jpg --prompt "slow push"
sac generate video --list-models
```

Built-in default model: `volces_seedance_1_5_pro`

**Vidu models**: `vidu_q3_pro` (t2v), `vidu_q3_pro_i2v` (i2v, requires `--image-url`), `vidu_q3_reference` (requires `--image-urls`), `vidu_q3_pro_start_end` (requires `--image-url` start + `--image-tail-url` end), `vidu_template_v2` (requires `--image-url`, `--template`), `vidu_one_click_mv` (requires `--image-urls`, `--audio-url`)

**Kling models**:
- T2V: `kling_v1`, `kling_v1_5`, `kling_v1_6`, `kling_v2_master`, `kling_v2_1_master`, `kling_v2_5_turbo`, `kling_v2_6`, `kling_v3`
- I2V: `kling_v1_i2v`, `kling_v1_5_i2v`, `kling_v1_6_i2v`, `kling_v2_1_i2v`, `kling_v2_master_i2v`, `kling_v2_1_master_i2v`, `kling_v2_5_turbo_i2v`, `kling_v2_6_i2v`, `kling_v3_i2v`
- Avatar: `kling_avatar` (requires `--image-url` + `--audio-url` or `--audio-id`)
- Motion control: `kling_motion_control`, `kling_v3_motion_control` (require `--image-url`, `--video-url`, `--character-orientation image|video`, `--mode std|pro`)
- Effects single: `kling_effects_single` (requires `--image-url`, `--effect-scene`, `--duration`)
- Effects multi: `kling_effects_multi_v1`, `kling_effects_multi_v15`, `kling_effects_multi_v16` (require exactly 2 `--image-urls`, `--effect-scene`, `--duration`)
- Duration extension: `kling_duration_extension` (requires `--video-url`, `--duration`)
- Lipsync: `kling_lipsync` — `--lipsync-mode text2video` (requires `--prompt`, `--video-url`/`--video-id`, `--voice-id`, `--voice-language`) or `--lipsync-mode audio2video` (requires `--audio-url`)
- Omni: `kling_omni_video`, `kling_v3_omni_video` (prompt-driven; supports `--image-url`, `--video-url`, `--aspect-ratio`, `--duration`)

**Tencent models**: `tencent_kling_v3`, `tencent_kling_v3_omni`, `tencent_mps_super_resolution` (requires `--video-url`, `--resolution 720P|1080P|2K|4K`, optional `--short 0|1`)

**Alibaba models**: `alibaba_wanx26_t2v` (t2v), `alibaba_wanx26_i2v` (i2v, requires `--image-url`, supports `--resolution 720P|1080P`), `alibaba_wanx26_reference` (requires `--reference-urls`; URLs must be accessible from China — avoid Google Cloud Storage CDN)

**Volces models**: `volces_seedance_1_5_pro`, `volces_seedance_2_0`, `volces_seedance_2_0_fast`, `volces_seedance_3_0`, `volces_seedance_3_0_pro`, `volces_seedance_30_i2v`, `volces_seedance_pro_fast`, `volces_draft_video`, `volces_jimeng_dream_actor_m1`, `volces_jimeng_dream_actor_m2`, `volces_realman_avatar_picture_omni_v2`, `volces_realman_avatar_picture_omni_v15`, `volces_realman_avatar_imitator_v2v`

Key flags: `--duration`, `--size`, `--aspect-ratio`, `--resolution`, `--seed`, `--fps`, `--frames`, `--image-url`, `--image-tail-url`, `--image-urls`, `--video-url`, `--video-id`, `--audio-url`, `--audio-id`, `--voice-id`, `--voice-language`, `--voice-speed`, `--lipsync-mode`, `--effect-scene`, `--character-orientation`, `--keep-original-sound`, `--extension-type`, `--template`, `--reference-urls`, `--mask-urls`, `--audio` (AI audio), `--shot-type` (Wanx t2v)

### generate audio

```bash
sac generate audio --prompt "epic orchestral theme"
sac generate audio --prompt "pop anthem" --model mureka_song_generator --lyrics "verse one..."
sac generate audio --model kling_video_to_audio --video-url https://example.com/clip.mp4 --sound-effect-prompt "rain and city"
```

Built-in default model: `lyria_3_pro_preview`

**Models**:
- `lyria_3_pro_preview` — music from text prompt
- `mureka_song_generator` — song with lyrics; requires `--lyrics`; optional `--prompt`, `--mureka-model`, `--n`, `--reference-id`, `--vocal-id`, `--melody-id`
- `kling_video_to_audio` — generate audio for a video; requires `--video-url` or `--video-id`; optional `--sound-effect-prompt`, `--n`

### generate 3d

```bash
sac generate 3d --prompt "a stylized toy robot"
sac generate 3d --image-url https://example.com/object.png
sac generate 3d --image-urls https://example.com/front.png --image-urls https://example.com/left.png --image-urls https://example.com/back.png --image-urls https://example.com/right.png
sac generate 3d --model tencent_hunyuan_3d --prompt "a carved jade dragon" --result-format GLB --enable-pbr
sac generate 3d --model tencent_hunyuan_3d_pro --image-url https://example.com/obj.png --face-count 80000 --generate-type LowPoly --polygon-type triangle
sac generate 3d --model volces_seed3d --prompt "a ceramic cat" --image-url https://example.com/cat.png
sac generate 3d --list-models
```

Default model routing (Tripo3D):
- prompt only → `tripo3d_text_to_model`
- single `--image-url` → `tripo3d_image_to_model`
- repeated `--image-urls` → `tripo3d_multiview_to_model`
- mixed or Tencent/Volces → pass `--model` explicitly

**Volces**: `volces_seed3d` (requires `--prompt` + `--image-url`)

**Tencent**:
- `tencent_hunyuan_3d` — requires exactly one of `--prompt`/`--image-url`/`--image-base64`; supports `--result-format`, `--enable-pbr`, repeated `--multi-view-image key=url`
- `tencent_hunyuan_3d_pro` — same input requirement; supports `--face-count`, `--generate-type`, `--polygon-type`, `--enable-pbr`
- `tencent_hunyuan_3d_rapid` — same input requirement; supports `--result-format`, `--enable-pbr`

### generate task

Query or wait for any generation task by ID:

```bash
sac generate task <task-id>
sac generate task <task-id> --output json     # full task payload
sac generate task <task-id> --output-only-url # raw URL lines (text only, rejects --output json)
```

`--output json` full payload includes `output[].content[].url` for download URLs.

### chat

```bash
sac chat --message "Hello"                          # single-turn (default model: deepseek-v3-0324)
sac chat --message "Hello" --output json            # { "content": "..." }
sac chat --message "Hello" --stream                 # streaming tokens (text only)
sac chat --model gemini-2.5-pro --message "Hello"
sac chat --system "You are a helpful assistant" --message "Explain recursion"
sac chat --message "user:Hi" --message "assistant:Hello" --message "How are you?"
sac chat --messages-file messages.json
sac chat --messages-file -                          # read JSON messages from stdin
sac chat models                                     # list available LLM models
sac chat models --output json
sac chat models --filter claude
sac chat set-model --model deepseek-v3-0324         # persist default model to config
```

**Important for automation:**

- Never run bare `sac chat` — without `--message` it starts an interactive REPL that blocks on keyboard input
- Without `--message` in non-interactive mode the command exits with a usage error (no hang)
- `--output json` only works for non-streaming single-turn chat
- `sac chat --stream --output json` is a usage error

Default model: `deepseek-v3-0324`. Override with `--model` or by running `sac chat set-model`.

### auth

```bash
sac auth login --api-key sa-xxxxxxxx   # validate and save key to ~/.sac/config.json
sac auth status                        # show stored key info (no network)
sac auth status --check                # validate key against API (network call)
sac auth logout                        # remove stored key
```

`auth login`, `auth status`, and `auth logout` all support `--output json`.

### config

```bash
sac config show
sac config show --output json
sac config set --key <key> --value <value>
```

Writable config keys: `api_key`, `output`, `timeout`, `default_image_model`, `default_chat_model`, `multimodal_base_url`, `llm_base_url`

## Async Task Flow

For long-running generation tasks, use `--async` to get the task ID immediately, then poll separately:

```bash
# Step 1: submit and get task ID
RESULT=$(sac generate image --prompt "a cat" --async --quiet --output json)
TASK_ID=$(echo "$RESULT" | node -e "process.stdin.setEncoding('utf8'); let d=''; process.stdin.on('data',c=>d+=c); process.stdin.on('end',()=>console.log(JSON.parse(d).task_id))")

# Step 2: poll until complete
sac generate task "$TASK_ID" --output json
```

Or use `--out-dir` to download assets directly after polling completes:

```bash
sac generate image --prompt "a cat" --out-dir ./output --output json
# returns: { "task_id": "...", "saved": ["/path/to/output/image_001.webp"] }
```

## Piping Patterns

Extract the first URL from image output:

```bash
sac generate image --prompt "a cat" --quiet --output json \
  | node -e "const d=JSON.parse(require('fs').readFileSync(0,'utf8')); console.log(d.urls[0])"
```

The JSON output shape for `generate image` (without `--out-dir`):

```json
{ "task_id": "...", "urls": ["https://..."] }
```

With `--out-dir`: `{ "task_id": "...", "saved": ["/absolute/path/to/file"] }`

With `--async`: `{ "task_id": "...", "status": "in_progress" }`

Send chat messages via stdin:

```bash
echo '[{"role":"user","content":"hello"}]' | sac chat --messages-file - --quiet --output json
```

## Exit Codes

| Code | Meaning |
|---|---|
| 0 | Success |
| 1 | General error |
| 2 | Usage / bad arguments |
| 3 | Authentication failed |
| 4 | Quota exceeded |
| 5 | Timeout |
| 6 | Network or validation uncertainty |
| 10 | Content filtered |

## Network Proxy

Node.js `fetch` (Node 18+) requires **uppercase** proxy variables:

```bash
HTTPS_PROXY=http://127.0.0.1:9990 HTTP_PROXY=http://127.0.0.1:9990 sac generate image --prompt "..."
```

Lowercase `https_proxy` is ignored by Node.js `fetch`.
