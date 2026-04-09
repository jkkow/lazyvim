#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/../lib/common.sh"

main() {
  if command_exists fd; then
    log_info "fd command already available"
    exit 0
  fi

  if ! command_exists fdfind; then
    log_warn "fdfind not found, skipping fd symlink"
    exit 0
  fi

  sudo install -d /usr/local/bin
  sudo ln -sfn "$(command -v fdfind)" /usr/local/bin/fd
  log_info "Created /usr/local/bin/fd -> $(command -v fdfind)"
}

main "$@"
