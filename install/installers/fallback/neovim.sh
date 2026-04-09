#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/../../lib/common.sh"
source "$script_dir/../../lib/tool_versions.sh"
source "$script_dir/../../lib/version.sh"
install_dir="/opt/nvim-linux64"
fallback_version="$(normalize_version "$NEOVIM_FALLBACK_VERSION")"
download_url="https://github.com/neovim/neovim/releases/download/v${fallback_version}/nvim-linux64.tar.gz"

current_nvim_version() {
  if ! command_exists nvim; then
    return 1
  fi

  nvim --version | awk 'NR==1 { sub(/^NVIM v/, "", $2); print $2 }'
}

main() {
  local current_version=""

  if current_version="$(current_nvim_version 2>/dev/null || true)" && [[ -n "$current_version" ]] && version_ge "$current_version" "$NEOVIM_REQUIRED_VERSION"; then
    log_info "nvim $current_version already satisfies $NEOVIM_REQUIRED_VERSION"
    exit 0
  fi

  local tmp_dir archive_path
  tmp_dir="$(mktemp -d)"
  archive_path="$tmp_dir/nvim-linux64.tar.gz"
  trap "rm -rf \"$tmp_dir\"" EXIT

  log_info "Downloading Neovim v$fallback_version"
  curl -fsSL "$download_url" -o "$archive_path"

  sudo rm -rf "$install_dir"
  sudo tar -C /opt -xzf "$archive_path"

  bash "$script_dir/../../post/neovim.sh"
}

main "$@"
