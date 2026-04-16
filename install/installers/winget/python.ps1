$ErrorActionPreference = "Stop"

$script_dir = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $script_dir "../../lib/common.ps1")

if (Test-CommandExists "python") {
  $line = Get-FirstOutputLine -Command "python" -Arguments @("--version")
  if ($line -match "Python 3") {
    Write-LogInfo "python already available"
    exit 0
  }
}

Install-WingetPackage -Id "Python.Python.3.12"

if (-not (Test-CommandExists "python") -and -not (Test-WingetPackageInstalled -Id "Python.Python.3.12")) {
  throw "python installation could not be verified"
}

Write-LogInfo "python installed"
