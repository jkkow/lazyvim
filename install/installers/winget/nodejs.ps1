$ErrorActionPreference = "Stop"

$script_dir = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $script_dir "../../lib/common.ps1")
. (Join-Path $script_dir "../../lib/version.ps1")
. (Join-Path $script_dir "../../lib/version_requirements.ps1")

function Get-NodejsVersion {
  if (-not (Test-CommandExists "node")) {
    return ""
  }

  $line = Get-FirstOutputLine -Command "node" -Arguments @("--version")
  if ($line -match "^v([0-9]+(?:\.[0-9]+){1,3})") {
    return $matches[1]
  }

  return ""
}

$required_version = Get-MinRequiredVersion -Tool "nodejs"
if (-not $required_version) {
  throw "Missing required version for nodejs in install/min-required-versions.txt"
}

$current = Get-NodejsVersion
if ($current -and (Test-VersionGreaterOrEqual -Current $current -Required $required_version)) {
  Write-LogInfo "nodejs $current already satisfies $required_version"
  exit 0
}

Install-WingetPackage -Id "OpenJS.NodeJS.LTS"

$current = Get-NodejsVersion
if ($current -and (Test-VersionGreaterOrEqual -Current $current -Required $required_version)) {
  Write-LogInfo "nodejs installed via winget ($current)"
  exit 0
}

if (Test-WingetPackageInstalled -Id "OpenJS.NodeJS.LTS") {
  Write-LogInfo "nodejs package installed via winget (version check deferred to next shell)"
  exit 0
}

if (-not (Test-CommandExists "node")) {
  throw "nodejs installation could not be verified"
}

throw "nodejs version does not satisfy required version $required_version"
