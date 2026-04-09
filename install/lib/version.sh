#!/usr/bin/env bash

normalize_version() {
  local version="$1"
  printf '%s' "${version#v}"
}

version_ge() {
  local current_version required_version
  current_version="$(normalize_version "$1")"
  required_version="$(normalize_version "$2")"

  dpkg --compare-versions "$current_version" ge "$required_version"
}
