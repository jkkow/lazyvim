# Installer Guide

This directory contains an Ubuntu-only installer for the Neovim environment in this repo.

## What this installer does

- Installs required tools listed in `install/manifests/base.txt`.
- Optionally installs extra tools listed in `install/manifests/optional.txt`.
- Uses apt-based installers in `install/installers/apt/`.
- Falls back to a pinned Neovim tarball install when apt Neovim is too old.
- Prints sectioned output and an installation summary with version/status info.

## Usage

Run from repository root:

```bash
bash install/install.sh --base-only
bash install/install.sh --all
```

Flags:

- `--base-only`: install only required packages.
- `--all`: install required + optional packages.
- `-h`, `--help`: show help.

Notes:

- The script checks `/etc/os-release` and exits unless `ID=ubuntu`.
- You will be prompted for sudo when needed.

## Runtime flow

`install/install.sh` runs these phases:

1. `PRIVILEGE CHECK` (`sudo -v`)
2. `APT UPDATE` (`sudo apt-get update`)
3. `BASE INSTALLATION` (scripts from `manifests/base.txt`)
4. `OPTIONAL INSTALLATION` (scripts from `manifests/optional.txt`, unless `--base-only`)
5. `INSTALLATION SUMMARY` (installed versions / availability)

Each manifest entry is executed sequentially and shown as:

```text
[INFO] [3/9] Running installers/apt/fd.sh
```

## Directory structure

```text
install/
  install.sh                 # Orchestrator
  INSTALLATION.md            # This guide
  manifests/
    base.txt                 # Required installers (one script path per line)
    optional.txt             # Optional installers
  installers/
    apt/                     # Apt-backed installers
    fallback/                # Non-apt fallback installers
  post/                      # Post-install fixups/linking/verification
  lib/
    common.sh                # Logging/helpers/apt wrapper
    version.sh               # Version comparison helper
    tool_versions.sh         # Central version pins
```

## Version management

Version pins are centralized in `install/lib/tool_versions.sh`.

Current active pins:

- `NEOVIM_REQUIRED_VERSION`
- `NEOVIM_FALLBACK_VERSION`

How Neovim install works:

- `install/installers/apt/neovim.sh` checks current `nvim` version.
- If apt can satisfy the requirement, apt install/upgrade is used.
- If not, `install/installers/fallback/neovim.sh` downloads pinned tarball release.
- `install/post/neovim.sh` links `/usr/local/bin/nvim` and verifies required version.

## Adding or changing tools

To add a new apt-installed tool:

1. Create installer script in `install/installers/apt/<tool>.sh`.
2. Source `install/lib/common.sh`.
3. Check whether tool already exists; exit early if present.
4. Install with `apt_install <package>`.
5. Add the script path to `manifests/base.txt` or `manifests/optional.txt`.
6. If version-gated, add a pin variable to `install/lib/tool_versions.sh`.
7. Optionally add a post-step in `install/post/` and call it from installer.

Minimal installer pattern:

```bash
#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/../../lib/common.sh"

main() {
  if command_exists mytool; then
    log_info "mytool already installed"
    exit 0
  fi

  apt_install mytool
}

main "$@"
```

## Logging and readability conventions

- Use `log_section` for major phases.
- Use `log_info`, `log_warn`, and `log_error` for messages.
- Keep one responsibility per installer script.
- Keep scripts idempotent (safe to run repeatedly).

## Installer artifacts and git hygiene

The repository ignores common installer artifacts via `.gitignore` entries:

- `install/.cache/`
- `install/.tmp/`
- `install/.artifacts/`
- `install/*.log`
- `install/*.tmp`

If you add new generated paths under `install/`, update `.gitignore` accordingly.

## Validation commands

Syntax-check installer scripts:

```bash
bash -n install/install.sh
bash -n install/installers/apt/neovim.sh
bash -n install/installers/fallback/neovim.sh
```

Optional formatting (if needed):

```bash
stylua --check lua/
```

## Troubleshooting

- **Not Ubuntu:** installer exits by design.
- **Neovim version still old:** check fallback download URL/version pins in `tool_versions.sh`.
- **`fd` missing after install:** verify `install/post/fd.sh` created `/usr/local/bin/fd` symlink.
- **Permission errors:** rerun with a user that can use sudo.
