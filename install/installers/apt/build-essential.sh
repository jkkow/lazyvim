#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/../../lib/common.sh"

main() {
  if dpkg_installed build-essential; then
    log_info "build-essential already installed"
    exit 0
  fi

  apt_install build-essential
}

main "$@"
