#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/../../lib/common.sh"
source "$script_dir/../../lib/tool_versions.sh"
source "$script_dir/../../lib/version.sh"

current_fzf_version() {
  if ! command_exists fzf; then
    return 1
  fi

  fzf --version | awk 'NR==1 { print $1 }'
}

detect_archive_suffix() {
  local arch
  arch="$(uname -m)"
  case "$arch" in
    x86_64|amd64)
      printf 'linux_amd64'
      ;;
    arm64|aarch64)
      printf 'linux_arm64'
      ;;
    *)
      log_error "Unsupported architecture: $arch"
      return 1
      ;;
  esac
}

main() {
  local fallback_version archive_suffix tmp_dir archive_path binary_path download_url

  fallback_version="$(normalize_version "$FZF_FALLBACK_VERSION")"
  archive_suffix="$(detect_archive_suffix)"
  download_url="https://github.com/junegunn/fzf/releases/download/v${fallback_version}/fzf-${fallback_version}-${archive_suffix}.tar.gz"

  tmp_dir="$(mktemp -d)"
  archive_path="$tmp_dir/fzf.tar.gz"
  trap "rm -rf \"$tmp_dir\"" EXIT

  log_info "Downloading fzf v$fallback_version for $archive_suffix"
  curl -fsSL "$download_url" -o "$archive_path"

  tar -C "$tmp_dir" -xzf "$archive_path"

  binary_path="$(find "$tmp_dir" -maxdepth 1 -type f -name 'fzf' -print -quit || true)"
  if [[ -z "$binary_path" ]]; then
    log_error "Extracted fzf binary not found in archive"
    exit 1
  fi

  sudo install -m 0755 "$binary_path" /usr/local/bin/fzf

  local current_version=""
  current_version="$(current_fzf_version 2>/dev/null || true)"
  if [[ -z "$current_version" ]] || ! version_ge "$current_version" "$FZF_REQUIRED_VERSION"; then
    log_error "Installed fzf version $current_version does not satisfy $FZF_REQUIRED_VERSION"
    exit 1
  fi

  log_info "fzf installed via fallback ($current_version)"
}

main "$@"
