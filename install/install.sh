#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$script_dir/lib/common.sh"
source "$script_dir/lib/tool_versions.sh"

first_line() {
  local line=""
  while IFS= read -r line; do
    printf '%s' "$line"
    return 0
  done

  return 1
}

command_version_line() {
  local cmd="$1"
  shift

  if ! command_exists "$cmd"; then
    return 1
  fi

  "$@" 2>/dev/null | first_line
}

dpkg_version() {
  local package_name="$1"
  if ! dpkg_installed "$package_name"; then
    return 1
  fi

  dpkg-query -W -f='${Version}' "$package_name" 2>/dev/null
}

current_nvim_version() {
  if ! command_exists nvim; then
    return 1
  fi

  nvim --version | awk 'NR==1 { sub(/^NVIM v/, "", $2); print $2 }'
}

print_summary_row() {
  local name="$1"
  local required="$2"
  local installed="$3"

  printf '  %-18s required: %-12s installed: %s\n' "$name" "$required" "$installed"
}

print_installation_summary() {
  local mode="$1"
  local nvim_version=""

  log_section "INSTALLATION SUMMARY"
  printf 'Mode: %s\n' "$mode"

  nvim_version="$(current_nvim_version 2>/dev/null || true)"
  if [[ -z "$nvim_version" ]]; then
    nvim_version="not found"
  fi
  print_summary_row "neovim" "$NEOVIM_REQUIRED_VERSION" "$nvim_version"

  local git_version=""
  git_version="$(command_version_line git git --version | awk '{print $3}' || true)"
  [[ -z "$git_version" ]] && git_version="not found"
  print_summary_row "git" "-" "$git_version"

  local curl_version=""
  curl_version="$(command_version_line curl curl --version | awk '{print $2}' || true)"
  [[ -z "$curl_version" ]] && curl_version="not found"
  print_summary_row "curl" "-" "$curl_version"

  local fd_version=""
  if command_exists fd; then
    fd_version="$(command_version_line fd fd --version | awk '{print $2}' || true)"
  elif command_exists fdfind; then
    fd_version="$(command_version_line fdfind fdfind --version | awk '{print $2}' || true)"
  fi
  [[ -z "$fd_version" ]] && fd_version="not found"
  print_summary_row "fd" "-" "$fd_version"

  local fzf_version=""
  fzf_version="$(command_version_line fzf fzf --version | awk '{print $1}' || true)"
  [[ -z "$fzf_version" ]] && fzf_version="not found"
  print_summary_row "fzf" "$FZF_REQUIRED_VERSION" "$fzf_version"

  local rg_version=""
  rg_version="$(command_version_line rg rg --version | awk '{print $2}' || true)"
  [[ -z "$rg_version" ]] && rg_version="not found"
  print_summary_row "ripgrep" "-" "$rg_version"

  local unzip_version=""
  unzip_version="$(command_version_line unzip unzip -v | awk 'NR==1 { print $2 }' || true)"
  [[ -z "$unzip_version" ]] && unzip_version="not found"
  print_summary_row "unzip" "-" "$unzip_version"

  local py_version=""
  py_version="$(command_version_line python python --version | awk '{print $2}' || true)"
  [[ -z "$py_version" ]] && py_version="not found"
  print_summary_row "python" "-" "$py_version"

  local py_venv_status=""
  if command_exists python3 && python3 -m venv --help >/dev/null 2>&1; then
    py_venv_status="available"
  else
    py_venv_status="not available"
  fi
  print_summary_row "python3-venv" "-" "$py_venv_status"

  local wl_clipboard_status=""
  if command_exists wl-copy && command_exists wl-paste; then
    wl_clipboard_status="available"
  else
    wl_clipboard_status="not found"
  fi
  print_summary_row "wl-clipboard" "-" "$wl_clipboard_status"

  local xclip_version=""
  xclip_version="$(command_version_line xclip xclip -version | awk '{print $3}' || true)"
  [[ -z "$xclip_version" ]] && xclip_version="not found"
  print_summary_row "xclip" "-" "$xclip_version"

  local xsel_version=""
  xsel_version="$(command_version_line xsel xsel --version | awk '{print $3}' || true)"
  [[ -z "$xsel_version" ]] && xsel_version="not found"
  print_summary_row "xsel" "-" "$xsel_version"

  local build_essential_version=""
  build_essential_version="$(dpkg_version build-essential || true)"
  [[ -z "$build_essential_version" ]] && build_essential_version="not installed"
  print_summary_row "build-essential" "-" "$build_essential_version"

  local jetbrains_mono_version=""
  jetbrains_mono_version="$(dpkg_version fonts-jetbrains-mono || true)"
  [[ -z "$jetbrains_mono_version" ]] && jetbrains_mono_version="not installed"
  print_summary_row "jetbrains-mono" "-" "$jetbrains_mono_version"
}

require_ubuntu() {
  if [[ ! -r /etc/os-release ]]; then
    log_error "Cannot determine OS: /etc/os-release not found"
    exit 1
  fi

  # shellcheck disable=SC1091
  source /etc/os-release

  if [[ "${ID:-}" != "ubuntu" ]]; then
    log_error "This installer supports Ubuntu only (detected: ${ID:-unknown})"
    exit 1
  fi
}

run_manifest() {
  local manifest_file="$1"
  local total_entries
  local current_index=0
  local relative_path=""

  total_entries="$(awk 'NF && $1 !~ /^#/ { count++ } END { print count + 0 }' "$manifest_file")"

  while IFS= read -r relative_path || [[ -n "$relative_path" ]]; do
    [[ -z "$relative_path" ]] && continue
    [[ "$relative_path" == \#* ]] && continue

    current_index=$((current_index + 1))

    local script_path="$script_dir/$relative_path"
    if [[ ! -f "$script_path" ]]; then
      log_error "Missing installer script: $relative_path"
      exit 1
    fi

    log_info "[$current_index/$total_entries] Running $relative_path"
    bash "$script_path"
  done < "$manifest_file"
}

main() {
  local install_optional=true

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --base-only)
        install_optional=false
        ;;
      --all)
        install_optional=true
        ;;
      -h|--help)
        cat <<'EOF'
Usage: install.sh [--base-only|--all]

--base-only  Install only required packages.
--all        Install required and optional packages.
EOF
        exit 0
        ;;
      *)
        log_error "Unknown option: $1"
        exit 1
        ;;
    esac
    shift
  done

  require_ubuntu

  log_section "PRIVILEGE CHECK"
  sudo -v

  log_section "APT UPDATE"
  sudo apt-get update

  log_section "BASE INSTALLATION"
  run_manifest "$script_dir/manifests/base.txt"

  if [[ "$install_optional" == true ]]; then
    log_section "OPTIONAL INSTALLATION"
    run_manifest "$script_dir/manifests/optional.txt"
  else
    log_info "Optional package installation skipped (--base-only)"
  fi

  print_installation_summary "$([[ "$install_optional" == true ]] && printf 'base + optional' || printf 'base only')"
  log_info "Installation complete"
}

main "$@"
