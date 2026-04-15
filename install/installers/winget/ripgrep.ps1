$ErrorActionPreference = "Stop"

$script_dir = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $script_dir "../../lib/common.ps1")

if (Test-CommandExists "rg") {
  Write-LogInfo "ripgrep already installed"
  exit 0
}

Install-WingetPackage -Id "BurntSushi.ripgrep.MSVC"

if (-not (Test-CommandExists "rg") -and -not (Test-WingetPackageInstalled -Id "BurntSushi.ripgrep.MSVC")) {
  throw "ripgrep installation could not be verified"
}

Write-LogInfo "ripgrep installed"
