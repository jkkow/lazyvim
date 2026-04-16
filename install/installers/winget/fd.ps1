$ErrorActionPreference = "Stop"

$script_dir = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $script_dir "../../lib/common.ps1")
. (Join-Path $script_dir "../../lib/version.ps1")
. (Join-Path $script_dir "../../lib/version_requirements.ps1")

function Get-FdVersion {
  if (-not (Test-CommandExists "fd")) {
    return ""
  }

  $line = Get-FirstOutputLine -Command "fd" -Arguments @("--version")
  if ($line -match "fd ([^\s]+)") {
    return $matches[1]
  }

  return ""
}

$required_version = Get-MinRequiredVersion -Tool "fd"
if (-not $required_version) {
  throw "Missing required version for fd in install/min-required-versions.txt"
}

$current = Get-FdVersion
if ($current -and (Test-VersionGreaterOrEqual -Current $current -Required $required_version)) {
  Write-LogInfo "fd $current already satisfies $required_version"
  exit 0
}

Install-WingetPackage -Id "sharkdp.fd"

$current = Get-FdVersion
if ($current -and (Test-VersionGreaterOrEqual -Current $current -Required $required_version)) {
  Write-LogInfo "fd installed via winget ($current)"
  exit 0
}

if (Test-WingetPackageInstalled -Id "sharkdp.fd") {
  Write-LogInfo "fd package installed via winget (version check deferred to next shell)"
  exit 0
}

if (-not (Test-CommandExists "fd")) {
  throw "fd installation could not be verified"
}

throw "fd version does not satisfy required version $required_version"
