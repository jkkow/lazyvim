$ErrorActionPreference = "Stop"

$script_dir = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $script_dir "../../lib/common.ps1")
. (Join-Path $script_dir "../../lib/version.ps1")
. (Join-Path $script_dir "../../lib/version_requirements.ps1")

function Get-GitVersion {
  if (-not (Test-CommandExists "git")) {
    return ""
  }

  $line = Get-FirstOutputLine -Command "git" -Arguments @("--version")
  if ($line -match "git version (.+)") {
    return $matches[1]
  }

  return ""
}

$required_version = Get-MinRequiredVersion -Tool "git"
if (-not $required_version) {
  throw "Missing required version for git in install/min-required-versions.txt"
}

$current = Get-GitVersion
if ($current -and (Test-VersionGreaterOrEqual -Current $current -Required $required_version)) {
  Write-LogInfo "git $current already satisfies $required_version"
  exit 0
}

Install-WingetPackage -Id "Git.Git"

$current = Get-GitVersion
if ($current -and (Test-VersionGreaterOrEqual -Current $current -Required $required_version)) {
  Write-LogInfo "git installed via winget ($current)"
  exit 0
}

if (Test-WingetPackageInstalled -Id "Git.Git") {
  Write-LogInfo "git package installed via winget (version check deferred to next shell)"
  exit 0
}

if (-not (Test-CommandExists "git")) {
  throw "git installation could not be verified"
}

throw "git version does not satisfy required version $required_version"
