#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/../../lib/common.sh"

python_major() {
  if ! command_exists python; then
    return 1
  fi

  python --version 2>&1 | awk '{print $2}' | cut -d. -f1
}

main() {
  if [[ "$(python_major 2>/dev/null || true)" == "3" ]]; then
    log_info "python already available"
    exit 0
  fi

  apt_install python3 python-is-python3
}

main "$@"
