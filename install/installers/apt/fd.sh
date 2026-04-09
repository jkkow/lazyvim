#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/../../lib/common.sh"

main() {
  if command_exists fd; then
    log_info "fd already installed"
    exit 0
  fi

  if ! command_exists fdfind; then
    apt_install fd-find
  fi

  bash "$script_dir/../../post/fd.sh"
}

main "$@"
