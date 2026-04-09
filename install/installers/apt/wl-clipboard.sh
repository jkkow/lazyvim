#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/../../lib/common.sh"

main() {
  if command_exists wl-copy && command_exists wl-paste; then
    log_info "wl-clipboard already installed"
    exit 0
  fi

  apt_install wl-clipboard
}

main "$@"
