#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/../../lib/common.sh"
source "$script_dir/../../lib/tool_versions.sh"
source "$script_dir/../../lib/version.sh"

current_nvim_version() {
  if ! command_exists nvim; then
    return 1
  fi

  nvim --version | awk 'NR==1 { sub(/^NVIM v/, "", $2); print $2 }'
}

main() {
  local current_version=""

  if current_version="$(current_nvim_version 2>/dev/null || true)" && [[ -n "$current_version" ]]; then
    if version_ge "$current_version" "$NEOVIM_REQUIRED_VERSION"; then
      log_info "nvim $current_version already satisfies $NEOVIM_REQUIRED_VERSION"
      exit 0
    fi

    log_warn "nvim $current_version is older than $NEOVIM_REQUIRED_VERSION"
  fi

  if ! dpkg_installed neovim; then
    apt_install neovim
  fi

  if current_version="$(current_nvim_version 2>/dev/null || true)" && [[ -n "$current_version" ]] && version_ge "$current_version" "$NEOVIM_REQUIRED_VERSION"; then
    log_info "nvim upgraded through apt"
    exit 0
  fi

  bash "$script_dir/../../installers/fallback/neovim.sh"
}

main "$@"
