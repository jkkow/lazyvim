$ErrorActionPreference = "Stop"

$script_dir = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $script_dir "../../lib/common.ps1")
. (Join-Path $script_dir "../../lib/version.ps1")
. (Join-Path $script_dir "../../lib/version_requirements.ps1")

function Get-LazygitVersion {
  if (-not (Test-CommandExists "lazygit")) {
    return ""
  }

  $line = Get-FirstOutputLine -Command "lazygit" -Arguments @("--version")
  if ($line -match "([0-9]+\.[0-9]+\.[0-9]+)") {
    return $matches[1]
  }

  return ""
}

$required_version = Get-MinRequiredVersion -Tool "lazygit"
if (-not $required_version) {
  throw "Missing required version for lazygit in install/min-required-versions.txt"
}

$current = Get-LazygitVersion
if ($current -and (Test-VersionGreaterOrEqual -Current $current -Required $required_version)) {
  Write-LogInfo "lazygit $current already satisfies $required_version"
  exit 0
}

Install-WingetPackage -Id "JesseDuffield.lazygit"

$current = Get-LazygitVersion
if ($current -and (Test-VersionGreaterOrEqual -Current $current -Required $required_version)) {
  Write-LogInfo "lazygit installed via winget ($current)"
  exit 0
}

if (Test-WingetPackageInstalled -Id "JesseDuffield.lazygit") {
  Write-LogInfo "lazygit package installed via winget (version check deferred to next shell)"
  exit 0
}

if (-not (Test-CommandExists "lazygit")) {
  throw "lazygit installation could not be verified"
}

throw "lazygit version does not satisfy required version $required_version"
