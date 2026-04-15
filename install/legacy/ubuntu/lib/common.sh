#!/usr/bin/env bash

log_section() {
  printf '\n========== %s ==========' "$*"
  printf '\n'
}

log_info() {
  printf '[INFO] %s\n' "$*"
}

log_warn() {
  printf '[WARN] %s\n' "$*" >&2
}

log_error() {
  printf '[ERROR] %s\n' "$*" >&2
}

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

dpkg_installed() {
  dpkg -s "$1" >/dev/null 2>&1
}

apt_install() {
  sudo apt-get install -y "$@"
}
