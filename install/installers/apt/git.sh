#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/../../lib/common.sh"

main() {
  if command_exists git; then
    log_info "git already installed"
    exit 0
  fi

  apt_install git
}

main "$@"
