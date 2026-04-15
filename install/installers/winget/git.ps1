$ErrorActionPreference = "Stop"

$script_dir = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $script_dir "../../lib/common.ps1")

if (Test-CommandExists "git") {
  Write-LogInfo "git already installed"
  exit 0
}

Install-WingetPackage -Id "Git.Git"

if (-not (Test-CommandExists "git") -and -not (Test-WingetPackageInstalled -Id "Git.Git")) {
  throw "git installation could not be verified"
}

Write-LogInfo "git installed"
