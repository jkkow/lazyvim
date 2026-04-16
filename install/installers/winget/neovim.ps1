$ErrorActionPreference = "Stop"

$script_dir = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $script_dir "../../lib/common.ps1")
. (Join-Path $script_dir "../../lib/version.ps1")
. (Join-Path $script_dir "../../lib/version_requirements.ps1")

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
if ($current -and (Test-VersionGreaterOrEqual -Current $current -Required $NEOVIM_REQUIRED_VERSION)) {
  Write-LogInfo "nvim $current already satisfies $NEOVIM_REQUIRED_VERSION"
  exit 0
}

Install-WingetPackage -Id "Neovim.Neovim"

$current = Get-NvimVersion
if ($current -and (Test-VersionGreaterOrEqual -Current $current -Required $NEOVIM_REQUIRED_VERSION)) {
  Write-LogInfo "nvim installed via winget ($current)"
  exit 0
}

if (Test-WingetPackageInstalled -Id "Neovim.Neovim") {
  Write-LogInfo "Neovim package installed via winget (version check deferred to post step)"
  exit 0
}

Write-LogWarn "winget did not provide required nvim version, trying fallback"
& (Join-Path $script_dir "../fallback/neovim.ps1")
