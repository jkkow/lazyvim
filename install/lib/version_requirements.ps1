$ErrorActionPreference = "Stop"

$script:MIN_REQUIRED_VERSIONS = @{}

function Initialize-MinRequiredVersions {
  if ($script:MIN_REQUIRED_VERSIONS.Count -gt 0) {
    return
  }

  $installer_root = Split-Path -Parent $PSScriptRoot
  $requirements_path = Join-Path $installer_root "min-required-versions.txt"
  if (-not (Test-Path -LiteralPath $requirements_path)) {
    throw "Missing required versions file: $requirements_path"
  }

  $lines = Get-Content -LiteralPath $requirements_path
  foreach ($raw_line in $lines) {
    $line = $raw_line.Trim()
    if (-not $line -or $line.StartsWith("#")) {
      continue
    }

    if ($line -notmatch "^([a-z0-9][a-z0-9-]*)=(.+)$") {
      throw "Invalid version entry in ${requirements_path}: $line"
    }

    $tool = $matches[1].ToLowerInvariant()
    $version = $matches[2].Trim()
    if (-not $version) {
      throw "Empty version value for '$tool' in $requirements_path"
    }

    $script:MIN_REQUIRED_VERSIONS[$tool] = $version
  }
}

function Get-MinRequiredVersion {
  param([Parameter(Mandatory = $true)][string]$Tool)

  Initialize-MinRequiredVersions
  $key = $Tool.ToLowerInvariant()
  if ($script:MIN_REQUIRED_VERSIONS.ContainsKey($key)) {
    return $script:MIN_REQUIRED_VERSIONS[$key]
  }

  return ""
}

function Get-MinRequiredVersions {
  Initialize-MinRequiredVersions
  return $script:MIN_REQUIRED_VERSIONS.Clone()
}
