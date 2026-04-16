$ErrorActionPreference = "Stop"

$script_dir = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $script_dir "../../lib/common.ps1")
. (Join-Path $script_dir "../../lib/version.ps1")
. (Join-Path $script_dir "../../lib/version_requirements.ps1")

function Get-PythonVersion {
  if (-not (Test-CommandExists "python")) {
    return ""
  }

  $line = Get-FirstOutputLine -Command "python" -Arguments @("--version")
  if ($line -match "Python ([0-9]+(?:\.[0-9]+){1,3})") {
    return $matches[1]
  }

  return ""
}

$required_version = Get-MinRequiredVersion -Tool "python"
if (-not $required_version) {
  throw "Missing required version for python in install/min-required-versions.txt"
}

$current = Get-PythonVersion
if ($current -and (Test-VersionGreaterOrEqual -Current $current -Required $required_version)) {
  Write-LogInfo "python $current already satisfies $required_version"
  exit 0
}

Install-WingetPackage -Id "Python.Python.3.12"

$current = Get-PythonVersion
if ($current -and (Test-VersionGreaterOrEqual -Current $current -Required $required_version)) {
  Write-LogInfo "python installed via winget ($current)"
  exit 0
}

if (Test-WingetPackageInstalled -Id "Python.Python.3.12") {
  Write-LogInfo "python package installed via winget (version check deferred to next shell)"
  exit 0
}

if (-not (Test-CommandExists "python")) {
  throw "python installation could not be verified"
}

throw "python version does not satisfy required version $required_version"
