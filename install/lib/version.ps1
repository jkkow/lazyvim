function Normalize-Version {
  param([Parameter(Mandatory = $true)][string]$Version)

  $normalized = $Version.Trim()
  if ($normalized.StartsWith("v", [System.StringComparison]::OrdinalIgnoreCase)) {
    $normalized = $normalized.Substring(1)
  }

  if ($normalized -match "^([0-9]+(?:\.[0-9]+){0,3})") {
    return $matches[1]
  }

  throw "Invalid version format: $Version"
}

function Test-VersionGreaterOrEqual {
  param(
    [Parameter(Mandatory = $true)][string]$Current,
    [Parameter(Mandatory = $true)][string]$Required
  )

  $current_version = [Version](Normalize-Version $Current)
  $required_version = [Version](Normalize-Version $Required)
  return $current_version -ge $required_version
}
