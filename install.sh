#!/usr/bin/env bash
set -euo pipefail

REPO="duyu654/SeaArt_CLI"
VERSION="0.4.8"
TAG="v${VERSION}"

log() {
  printf '%s\n' "$*"
}

fail() {
  printf 'Error: %s\n' "$*" >&2
  exit 1
}

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || fail "Missing required command: $1"
}

detect_target() {
  local os arch
  os="$(uname -s)"
  arch="$(uname -m)"

  case "$os" in
    Darwin)
      case "$arch" in
        arm64) printf 'darwin-arm64' ;;
        x86_64) printf 'darwin-x64' ;;
        *) fail "Unsupported macOS architecture: $arch" ;;
      esac
      ;;
    Linux)
      case "$arch" in
        x86_64|amd64) printf 'linux-x64' ;;
        *) fail "Unsupported Linux architecture: $arch" ;;
      esac
      ;;
    MINGW*|MSYS*|CYGWIN*)
      case "$arch" in
        x86_64|amd64) printf 'windows-x64.exe' ;;
        *) fail "Unsupported Windows architecture: $arch" ;;
      esac
      ;;
    *)
      fail "Unsupported operating system: $os"
      ;;
  esac
}

download() {
  local url output
  url="$1"
  output="$2"

  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$url" -o "$output"
    return
  fi

  if command -v wget >/dev/null 2>&1; then
    wget -qO "$output" "$url"
    return
  fi

  fail "Either curl or wget is required."
}

verify_checksum() {
  local file checksum_file expected actual
  file="$1"
  checksum_file="$2"

  expected="$(awk '{print $1}' "$checksum_file")"
  if command -v sha256sum >/dev/null 2>&1; then
    actual="$(sha256sum "$file" | awk '{print $1}')"
  elif command -v shasum >/dev/null 2>&1; then
    actual="$(shasum -a 256 "$file" | awk '{print $1}')"
  else
    log "Checksum tools not found; skipping checksum verification."
    return
  fi

  [ "$expected" = "$actual" ] || fail "Checksum mismatch for $(basename "$file")"
}

main() {
  local suffix asset asset_url checksum_url tmpdir install_dir binary_name dest
  need_cmd uname
  suffix="$(detect_target)"

  if [[ "$suffix" == *.exe ]]; then
    asset="sac-${VERSION}-${suffix}"
    binary_name="sac.exe"
  else
    asset="sac-${VERSION}-${suffix}"
    binary_name="sac"
  fi

  asset_url="https://github.com/${REPO}/releases/download/${TAG}/${asset}"
  checksum_url="${asset_url}.sha256"
  tmpdir="$(mktemp -d)"
  trap 'rm -rf "$tmpdir"' EXIT

  log "Downloading ${asset} from ${REPO} ${TAG}"
  download "$asset_url" "$tmpdir/$asset"
  download "$checksum_url" "$tmpdir/$asset.sha256"
  verify_checksum "$tmpdir/$asset" "$tmpdir/$asset.sha256"

  install_dir="${SAC_INSTALL_DIR:-$HOME/.local/bin}"
  mkdir -p "$install_dir"
  dest="$install_dir/$binary_name"
  cp "$tmpdir/$asset" "$dest"
  chmod +x "$dest"

  log "Installed to $dest"
  "$dest" --version

  case ":$PATH:" in
    *":$install_dir:"*) ;;
    *)
      log "Add this to your shell profile if needed:"
      log "export PATH=\"$install_dir:\$PATH\""
      ;;
  esac
}

main "$@"
