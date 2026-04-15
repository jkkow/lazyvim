$ErrorActionPreference = "Stop"

function Write-LogSection {
  param([Parameter(Mandatory = $true)][string]$Message)
  Write-Output ""
  Write-Output "========== $Message =========="
}

function Write-LogInfo {
  param([Parameter(Mandatory = $true)][string]$Message)
  Write-Output "[INFO] $Message"
}

function Write-LogWarn {
  param([Parameter(Mandatory = $true)][string]$Message)
  Write-Warning $Message
}

function Write-LogError {
  param([Parameter(Mandatory = $true)][string]$Message)
  Write-Error $Message
}

function Test-CommandExists {
  param([Parameter(Mandatory = $true)][string]$CommandName)
  return [bool](Get-Command $CommandName -ErrorAction SilentlyContinue)
}

function Get-FirstOutputLine {
  param(
    [Parameter(Mandatory = $true)][string]$Command,
    [string[]]$Arguments = @()
  )

  try {
    $lines = & $Command @Arguments 2>$null
    if ($null -eq $lines) {
      return ""
    }
    return ($lines | Select-Object -First 1)
  } catch {
    return ""
  }
}

function Install-WingetPackage {
  param(
    [Parameter(Mandatory = $true)][string]$Id,
    [string]$Scope = "machine"
  )

  $args = @(
    "install",
    "--id", $Id,
    "-e",
    "--scope", $Scope,
    "--accept-package-agreements",
    "--accept-source-agreements",
    "--disable-interactivity"
  )

  Write-LogInfo "Installing $Id via winget (scope=$Scope)"
  & winget @args
  if ($LASTEXITCODE -ne 0) {
    throw "winget install failed for $Id (exit=$LASTEXITCODE)"
  }
}

function Test-WingetPackageInstalled {
  param([Parameter(Mandatory = $true)][string]$Id)

  $args = @(
    "list",
    "--id", $Id,
    "-e",
    "--accept-source-agreements"
  )

  $output = & winget @args 2>$null
  if ($LASTEXITCODE -ne 0) {
    return $false
  }

  return [bool]($output -match [Regex]::Escape($Id))
}

function Add-UserPathEntry {
  param([Parameter(Mandatory = $true)][string]$PathEntry)

  if (-not (Test-Path -LiteralPath $PathEntry)) {
    throw "Path does not exist: $PathEntry"
  }

  $normalized = [IO.Path]::GetFullPath($PathEntry).TrimEnd("\\")

  $user_path = [Environment]::GetEnvironmentVariable("Path", "User")
  if ([string]::IsNullOrWhiteSpace($user_path)) {
    $user_entries = @()
  } else {
    $user_entries = $user_path.Split(";", [System.StringSplitOptions]::RemoveEmptyEntries)
  }

  $already_present = $false
  foreach ($entry in $user_entries) {
    if ([string]::Equals($entry.TrimEnd("\\"), $normalized, [System.StringComparison]::OrdinalIgnoreCase)) {
      $already_present = $true
      break
    }
  }

  if (-not $already_present) {
    $new_user_path = if ([string]::IsNullOrWhiteSpace($user_path)) {
      $normalized
    } else {
      "$user_path;$normalized"
    }
    [Environment]::SetEnvironmentVariable("Path", $new_user_path, "User")
    Write-LogInfo "Added to user PATH: $normalized"
  }

  $process_entries = $env:Path.Split(";", [System.StringSplitOptions]::RemoveEmptyEntries)
  if (-not ($process_entries | Where-Object { [string]::Equals($_.TrimEnd("\\"), $normalized, [System.StringComparison]::OrdinalIgnoreCase) })) {
    $env:Path = "$env:Path;$normalized"
  }
}
