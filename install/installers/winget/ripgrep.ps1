$ErrorActionPreference = "Stop"

$script_dir = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $script_dir "../../lib/common.ps1")
. (Join-Path $script_dir "../../lib/version.ps1")
. (Join-Path $script_dir "../../lib/version_requirements.ps1")

function Get-RipgrepVersion {
  if (-not (Test-CommandExists "rg")) {
    return ""
  }

  $line = Get-FirstOutputLine -Command "rg" -Arguments @("--version")
  if ($line -match "ripgrep ([^\s]+)") {
    return $matches[1]
  }

  return ""
}

$required_version = Get-MinRequiredVersion -Tool "ripgrep"
if (-not $required_version) {
  throw "Missing required version for ripgrep in install/min-required-versions.txt"
}

$current = Get-RipgrepVersion
if ($current -and (Test-VersionGreaterOrEqual -Current $current -Required $required_version)) {
  Write-LogInfo "ripgrep $current already satisfies $required_version"
  exit 0
}

Install-WingetPackage -Id "BurntSushi.ripgrep.MSVC"

$current = Get-RipgrepVersion
if ($current -and (Test-VersionGreaterOrEqual -Current $current -Required $required_version)) {
  Write-LogInfo "ripgrep installed via winget ($current)"
  exit 0
}

if (Test-WingetPackageInstalled -Id "BurntSushi.ripgrep.MSVC") {
  Write-LogInfo "ripgrep package installed via winget (version check deferred to next shell)"
  exit 0
}

if (-not (Test-CommandExists "rg")) {
  throw "ripgrep installation could not be verified"
}

throw "ripgrep version does not satisfy required version $required_version"
