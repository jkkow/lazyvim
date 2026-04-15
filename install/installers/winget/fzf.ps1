$ErrorActionPreference = "Stop"

$script_dir = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $script_dir "../../lib/common.ps1")
. (Join-Path $script_dir "../../lib/version.ps1")
. (Join-Path $script_dir "../../lib/tool_versions.ps1")

function Get-FzfVersion {
  if (-not (Test-CommandExists "fzf")) {
    return ""
  }

  $line = Get-FirstOutputLine -Command "fzf" -Arguments @("--version")
  if ($line -match "^([^\s]+)") {
    return $matches[1]
  }

  return ""
}

$current = Get-FzfVersion
if ($current -and (Test-VersionGreaterOrEqual -Current $current -Required $FZF_REQUIRED_VERSION)) {
  Write-LogInfo "fzf $current already satisfies $FZF_REQUIRED_VERSION"
  exit 0
}

Install-WingetPackage -Id "junegunn.fzf"

$current = Get-FzfVersion
if ($current -and (Test-VersionGreaterOrEqual -Current $current -Required $FZF_REQUIRED_VERSION)) {
  Write-LogInfo "fzf installed via winget ($current)"
  exit 0
}

if (Test-WingetPackageInstalled -Id "junegunn.fzf") {
  Write-LogInfo "fzf package installed via winget (version check deferred to next shell)"
  exit 0
}

Write-LogWarn "winget did not provide required fzf version, trying fallback"
& (Join-Path $script_dir "../fallback/fzf.ps1")
