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

main() {
  local current_version=""

  if current_version="$(current_fzf_version 2>/dev/null || true)" && [[ -n "$current_version" ]] && version_ge "$current_version" "$FZF_REQUIRED_VERSION"; then
    log_info "fzf $current_version already satisfies $FZF_REQUIRED_VERSION"
    exit 0
  fi

  apt_install fzf

  if current_version="$(current_fzf_version 2>/dev/null || true)" && [[ -n "$current_version" ]] && version_ge "$current_version" "$FZF_REQUIRED_VERSION"; then
    log_info "fzf installed via apt ($current_version)"
    exit 0
  fi

  log_warn "fzf version $current_version does not satisfy $FZF_REQUIRED_VERSION after apt install"
  bash "$script_dir/../../installers/fallback/fzf.sh"
}

main "$@"
