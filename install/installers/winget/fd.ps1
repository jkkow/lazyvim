$ErrorActionPreference = "Stop"

$script_dir = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $script_dir "../../lib/common.ps1")

if (Test-CommandExists "fd") {
  Write-LogInfo "fd already installed"
  exit 0
}

Install-WingetPackage -Id "sharkdp.fd"

if (-not (Test-CommandExists "fd") -and -not (Test-WingetPackageInstalled -Id "sharkdp.fd")) {
  throw "fd installation could not be verified"
}

Write-LogInfo "fd installed"
