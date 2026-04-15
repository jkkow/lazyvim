#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/../../lib/common.sh"

main() {
  if command_exists unzip; then
    log_info "unzip already installed"
    exit 0
  fi

  apt_install unzip
}

main "$@"
