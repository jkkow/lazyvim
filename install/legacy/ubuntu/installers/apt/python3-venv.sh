#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/../../lib/common.sh"

main() {
  if command_exists python3 && python3 -m venv --help >/dev/null 2>&1; then
    log_info "python3-venv already available"
    exit 0
  fi

  apt_install python3-venv
}

main "$@"
