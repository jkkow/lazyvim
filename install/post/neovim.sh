#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/../lib/common.sh"
source "$script_dir/../lib/tool_versions.sh"
source "$script_dir/../lib/version.sh"

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

  if [[ ! -x /opt/nvim-linux64/bin/nvim ]]; then
    log_error "Fallback Neovim binary not found in /opt/nvim-linux64/bin/nvim"
    exit 1
  fi

  sudo install -d /usr/local/bin
  sudo ln -sfn /opt/nvim-linux64/bin/nvim /usr/local/bin/nvim

  if ! command_exists nvim; then
    log_error "nvim still not available after installation"
    exit 1
  fi

  current_version="$(current_nvim_version 2>/dev/null || true)"
  if [[ -z "$current_version" ]] || ! version_ge "$current_version" "$NEOVIM_REQUIRED_VERSION"; then
    log_error "nvim version $current_version does not satisfy $NEOVIM_REQUIRED_VERSION"
    exit 1
  fi

  log_info "nvim available at $(command -v nvim) ($current_version)"
}

main "$@"
