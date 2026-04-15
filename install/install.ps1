param(
  [switch]$BaseOnly,
  [switch]$All,
  [switch]$Help
)

$ErrorActionPreference = "Stop"

$script_dir = Split-Path -Parent $MyInvocation.MyCommand.Path

. (Join-Path $script_dir "lib/common.ps1")

if ($Help) {
  @"
Usage: .\install\install.ps1 [-BaseOnly|-All] [-Help]

-BaseOnly  Install only required packages.
-All       Install required and optional packages.
-Help      Show this help message.
"@ | Write-Output
  exit 0
}

if ($BaseOnly -and $All) {
  Write-LogError "Use either -BaseOnly or -All, not both."
  exit 1
}

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

  Write-LogSection "INSTALLATION SUMMARY"
  Write-Output "Mode: $Mode"

  $tools = @(
    @{ Name = "nvim"; Cmd = "nvim"; VersionArgs = @("--version"); Pattern = "NVIM v(.+)" },
    @{ Name = "git"; Cmd = "git"; VersionArgs = @("--version"); Pattern = "git version (.+)" },
    @{ Name = "fd"; Cmd = "fd"; VersionArgs = @("--version"); Pattern = "fd ([^\s]+)" },
    @{ Name = "fzf"; Cmd = "fzf"; VersionArgs = @("--version"); Pattern = "([^\s]+)" },
    @{ Name = "ripgrep"; Cmd = "rg"; VersionArgs = @("--version"); Pattern = "ripgrep ([^\s]+)" },
    @{ Name = "python"; Cmd = "python"; VersionArgs = @("--version"); Pattern = "Python (.+)" }
  )

  foreach ($tool in $tools) {
    if (Test-CommandExists $tool.Cmd) {
      $line = Get-FirstOutputLine -Command $tool.Cmd -Arguments $tool.VersionArgs
      $version = "found"
      if ($line -and ($line -match $tool.Pattern)) {
        $version = $matches[1]
      }
      Write-Output ("  {0,-10} {1}" -f $tool.Name, $version)
    } else {
      Write-Output ("  {0,-10} not found" -f $tool.Name)
    }
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
