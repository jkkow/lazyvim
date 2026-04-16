$ErrorActionPreference = "Stop"

$script_dir = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $script_dir "../../lib/common.ps1")
. (Join-Path $script_dir "../../lib/version.ps1")
. (Join-Path $script_dir "../../lib/version_requirements.ps1")

function Get-GsudoVersion {
  if (-not (Test-CommandExists "gsudo")) {
    return ""
  }

  $line = Get-FirstOutputLine -Command "gsudo" -Arguments @("--version")
  if ($line -match "([0-9]+(?:\.[0-9]+){1,3})") {
    return $matches[1]
  }

  return ""
}

$required_version = Get-MinRequiredVersion -Tool "gsudo"
if (-not $required_version) {
  throw "Missing required version for gsudo in install/min-required-versions.txt"
}

$current = Get-GsudoVersion
if ($current -and (Test-VersionGreaterOrEqual -Current $current -Required $required_version)) {
  Write-LogInfo "gsudo $current already satisfies $required_version"
  exit 0
}

Install-WingetPackage -Id "gerardog.gsudo" -Scope "machine"

$current = Get-GsudoVersion
if ($current -and (Test-VersionGreaterOrEqual -Current $current -Required $required_version)) {
  Write-LogInfo "gsudo installed via winget ($current)"
  exit 0
}

if (Test-WingetPackageInstalled -Id "gerardog.gsudo") {
  Write-LogInfo "gsudo package installed via winget (version check deferred to next shell)"
  exit 0
}

if (-not (Test-CommandExists "gsudo")) {
  throw "gsudo installation could not be verified"
}

throw "gsudo version does not satisfy required version $required_version"
