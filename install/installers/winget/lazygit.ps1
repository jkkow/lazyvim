$ErrorActionPreference = "Stop"

$script_dir = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $script_dir "../../lib/common.ps1")

if (Test-CommandExists "lazygit") {
  Write-LogInfo "lazygit already installed"
  exit 0
}

Install-WingetPackage -Id "JesseDuffield.lazygit"

if (-not (Test-CommandExists "lazygit") -and -not (Test-WingetPackageInstalled -Id "JesseDuffield.lazygit")) {
  throw "lazygit installation could not be verified"
}

Write-LogInfo "lazygit installed"
