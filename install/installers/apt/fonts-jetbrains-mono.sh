#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/../../lib/common.sh"

font_available() {
  if ! command_exists fc-match; then
    return 1
  fi

  local matched_family
  matched_family="$(fc-match -f '%{family}\n' 'JetBrains Mono' 2>/dev/null || true)"
  [[ "$matched_family" == *"JetBrains Mono"* ]]
}

main() {
  if dpkg_installed fonts-jetbrains-mono || font_available; then
    log_info "JetBrains Mono already available"
    exit 0
  fi

  apt_install fonts-jetbrains-mono
}

main "$@"
