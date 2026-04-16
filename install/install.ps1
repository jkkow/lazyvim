param(
  [switch]$BaseOnly,
  [switch]$All,
  [ValidateSet("user", "machine")][string]$Scope = "user",
  [switch]$MachineScope,
  [switch]$Help
)

$ErrorActionPreference = "Stop"

$script_dir = Split-Path -Parent $MyInvocation.MyCommand.Path

. (Join-Path $script_dir "lib/common.ps1")
. (Join-Path $script_dir "lib/version.ps1")
. (Join-Path $script_dir "lib/version_requirements.ps1")

if ($Help) {
  @"
Usage: .\install\install.ps1 [-BaseOnly|-All] [-Scope user|machine] [-MachineScope] [-Help]

-BaseOnly  Install only required packages.
-All       Install required and optional packages.
-Scope     winget scope for package installs: user (default) or machine.
-MachineScope Shortcut for -Scope machine.
-Help      Show this help message.
"@ | Write-Output
  exit 0
}

if ($BaseOnly -and $All) {
  Write-LogError "Use either -BaseOnly or -All, not both."
  exit 1
}

$effective_scope = $Scope
if ($MachineScope) {
  $effective_scope = "machine"
}

$env:NVIM_INSTALL_SCOPE = $effective_scope
Write-LogInfo "Package installation scope: $effective_scope"

if (-not $IsWindows) {
  Write-LogError "This installer supports Windows 11 only."
  exit 1
}

if (-not (Test-CommandExists "winget")) {
  Write-LogError "winget is required but not found. Install App Installer from Microsoft Store."
  exit 1
}

$install_optional = $true
if ($BaseOnly) {
  $install_optional = $false
}

function Get-ManifestEntries {
  param([Parameter(Mandatory = $true)][string]$ManifestPath)

  if (-not (Test-Path -LiteralPath $ManifestPath)) {
    throw "Missing manifest: $ManifestPath"
  }

  Get-Content -LiteralPath $ManifestPath |
    ForEach-Object { $_.Trim() } |
    Where-Object { $_ -and -not $_.StartsWith("#") }
}

function Run-Manifest {
  param([Parameter(Mandatory = $true)][string]$ManifestPath)

  $entries = @(Get-ManifestEntries -ManifestPath $ManifestPath)
  $total = $entries.Count
  $index = 0

  foreach ($entry in $entries) {
    $index += 1
    $script_path = Join-Path $script_dir $entry
    if (-not (Test-Path -LiteralPath $script_path)) {
      throw "Missing installer script: $entry"
    }

    Write-LogInfo "[$index/$total] Running $entry"
    & $script_path
  }
}

function Write-InstallationSummary {
  param([Parameter(Mandatory = $true)][string]$Mode)

  function Get-InstalledVersion {
    param(
      [string]$Command,
      [string[]]$VersionArgs = @("--version"),
      [string]$Pattern = "([0-9]+(?:\.[0-9]+){1,3})"
    )

    if (-not $Command -or -not (Test-CommandExists $Command)) {
      return ""
    }

    $line = Get-FirstOutputLine -Command $Command -Arguments $VersionArgs
    if ($line -and ($line -match $Pattern)) {
      return $matches[1]
    }

    return ""
  }

  function Test-NerdFontInstalled {
    $font_dir = Join-Path $env:LOCALAPPDATA "Microsoft\Windows\Fonts"
    if (-not (Test-Path -LiteralPath $font_dir)) {
      return $false
    }

    $files = Get-ChildItem -Path $font_dir -Filter "JetBrainsMono`NerdFont-*.ttf" -ErrorAction SilentlyContinue
    return $files.Count -gt 0
  }

  function Get-NerdFontInstalledVersion {
    $version_file = Join-Path $env:LOCALAPPDATA "nvim-installer\nerd-font-version.txt"
    if (Test-Path -LiteralPath $version_file) {
      $value = Get-Content -LiteralPath $version_file -ErrorAction SilentlyContinue | Select-Object -First 1
      if ($value) {
        return $value.Trim()
      }
    }

    if (Test-NerdFontInstalled) {
      return "found"
    }

    return ""
  }

  Write-LogSection "INSTALLATION SUMMARY"
  Write-Output "Mode: $Mode"
  Write-Output ""

  $managed_tool_keys = @("fd", "fzf", "git", "lazygit", "neovim", "nerd-font", "nodejs", "python", "ripgrep")
  $tool_specs = @{
    "neovim" = @{ Name = "nvim"; Cmd = "nvim"; VersionArgs = @("--version"); Pattern = "NVIM v(.+)" }
    "git" = @{ Name = "git"; Cmd = "git"; VersionArgs = @("--version"); Pattern = "git version (.+)" }
    "lazygit" = @{ Name = "lazygit"; Cmd = "lazygit"; VersionArgs = @("--version"); Pattern = "([0-9]+\.[0-9]+\.[0-9]+)" }
    "fd" = @{ Name = "fd"; Cmd = "fd"; VersionArgs = @("--version"); Pattern = "fd ([^\s]+)" }
    "fzf" = @{ Name = "fzf"; Cmd = "fzf"; VersionArgs = @("--version"); Pattern = "([^\s]+)" }
    "ripgrep" = @{ Name = "ripgrep"; Cmd = "rg"; VersionArgs = @("--version"); Pattern = "ripgrep ([^\s]+)" }
    "python" = @{ Name = "python"; Cmd = "python"; VersionArgs = @("--version"); Pattern = "Python ([0-9]+(?:\.[0-9]+){1,3})" }
    "nodejs" = @{ Name = "nodejs"; Cmd = "node"; VersionArgs = @("--version"); Pattern = "^v([0-9]+(?:\.[0-9]+){1,3})" }
    "nerd-font" = @{ Name = "nerd-font" }
  }

  $requirements = Get-MinRequiredVersions
  $all_keys = @($managed_tool_keys + $requirements.Keys) | Sort-Object -Unique

  foreach ($tool_key in $all_keys) {
    $required = Get-MinRequiredVersion -Tool $tool_key
    $is_managed = $managed_tool_keys -contains $tool_key

    $display_name = $tool_key
    $installed = ""
    if ($tool_specs.ContainsKey($tool_key)) {
      $spec = $tool_specs[$tool_key]
      $display_name = $spec.Name
      if ($tool_key -eq "nerd-font") {
        $installed = Get-NerdFontInstalledVersion
      } else {
        $installed = Get-InstalledVersion -Command $spec.Cmd -VersionArgs $spec.VersionArgs -Pattern $spec.Pattern
      }
    } else {
      $display_name = $tool_key
      $installed = Get-InstalledVersion -Command $tool_key
    }

    $required_out = if ($required) { $required } else { "-" }
    $installed_out = if ($installed) { $installed } else { "not found" }

    $status = "not-managed"
    if ($is_managed) {
      if (-not $required) {
        $status = "missing-required"
      } elseif (-not $installed) {
        $status = "not-found"
      } else {
        try {
          if (Test-VersionGreaterOrEqual -Current $installed -Required $required) {
            $status = "ok"
          } else {
            $status = "upgrade-needed"
          }
        } catch {
          $status = "version-check-failed"
        }
      }
    }

    Write-Output ("  {0,-12} required: {1,-10} installed: {2,-12} status: {3}" -f $display_name, $required_out, $installed_out, $status)
  }
}

Write-LogSection "BASE INSTALLATION"
Run-Manifest -ManifestPath (Join-Path $script_dir "manifests/windows-base.txt")

if ($install_optional) {
  Write-LogSection "OPTIONAL INSTALLATION"
  Run-Manifest -ManifestPath (Join-Path $script_dir "manifests/windows-optional.txt")
} else {
  Write-LogInfo "Optional package installation skipped (-BaseOnly)"
}

Write-LogSection "POST INSTALLATION"
& (Join-Path $script_dir "post/neovim.ps1")

$mode = if ($install_optional) { "base + optional" } else { "base only" }
Write-InstallationSummary -Mode $mode
Write-LogInfo "Installation complete"
