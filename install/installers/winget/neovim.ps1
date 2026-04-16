$ErrorActionPreference = "Stop"

$script_dir = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $script_dir "../../lib/common.ps1")
. (Join-Path $script_dir "../../lib/version.ps1")
. (Join-Path $script_dir "../../lib/version_requirements.ps1")

$required_version = Get-MinRequiredVersion -Tool "neovim"
if (-not $required_version) {
  throw "Missing required version for neovim in install/min-required-versions.txt"
}

function Get-NvimVersion {
  if (-not (Test-CommandExists "nvim")) {
    return ""
  }

  $line = Get-FirstOutputLine -Command "nvim" -Arguments @("--version")
  if ($line -match "NVIM v(.+)") {
    return $matches[1]
  }

  return ""
}

$current = Get-NvimVersion
if ($current -and (Test-VersionGreaterOrEqual -Current $current -Required $required_version)) {
  Write-LogInfo "nvim $current already satisfies $required_version"
  exit 0
}

try {
  Install-WingetPackage -Id "Neovim.Neovim"
} catch {
  Write-LogWarn "winget install for Neovim failed, trying fallback: $($_.Exception.Message)"
  & (Join-Path $script_dir "../fallback/neovim.ps1")
  exit 0
}

$current = Get-NvimVersion
if ($current -and (Test-VersionGreaterOrEqual -Current $current -Required $required_version)) {
  Write-LogInfo "nvim installed via winget ($current)"
  exit 0
}

if (Test-WingetPackageInstalled -Id "Neovim.Neovim") {
  Write-LogInfo "Neovim package installed via winget (version check deferred to post step)"
  exit 0
}

Write-LogWarn "winget did not provide required nvim version, trying fallback"
& (Join-Path $script_dir "../fallback/neovim.ps1")
