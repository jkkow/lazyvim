param(
  [switch]$BaseOnly,
  [switch]$All,
  [ValidateSet("user", "machine")][string]$Scope = "machine",
  [switch]$MachineScope,
  [switch]$ElevatedRelaunch,
  [string]$RelaunchReportPath = "",
  [switch]$Help
)

$ErrorActionPreference = "Stop"

$script_dir = Split-Path -Parent $MyInvocation.MyCommand.Path

. (Join-Path $script_dir "lib/common.ps1")
. (Join-Path $script_dir "lib/version.ps1")
. (Join-Path $script_dir "lib/version_requirements.ps1")

function Write-RelaunchReport {
  param(
    [string]$Path,
    [string]$Mode,
    [string]$InstallError,
    [object[]]$InstallerResults = @()
  )

  if ([string]::IsNullOrWhiteSpace($Path)) {
    return
  }

  $report_dir = Split-Path -Parent $Path
  if (-not [string]::IsNullOrWhiteSpace($report_dir) -and -not (Test-Path -LiteralPath $report_dir)) {
    $null = New-Item -ItemType Directory -Path $report_dir -Force
  }

  $report = [PSCustomObject]@{
    Mode = $Mode
    InstallError = $InstallError
    InstallerResults = $InstallerResults
  }

  $json = $report | ConvertTo-Json -Depth 8
  Set-Content -LiteralPath $Path -Value $json -Encoding UTF8
}

function Read-RelaunchReport {
  param([string]$Path)

  if ([string]::IsNullOrWhiteSpace($Path) -or -not (Test-Path -LiteralPath $Path)) {
    return $null
  }

  $raw = Get-Content -LiteralPath $Path -Raw -ErrorAction SilentlyContinue
  if ([string]::IsNullOrWhiteSpace($raw)) {
    return $null
  }

  return $raw | ConvertFrom-Json
}

function Write-RelaunchSummaryReplay {
  param([Parameter(Mandatory = $true)]$Report)

  $mode = if ($Report.Mode) { [string]$Report.Mode } else { "unknown" }
  $results = if ($null -ne $Report.InstallerResults) { @($Report.InstallerResults) } else { @() }
  $install_error = if ($Report.InstallError) { [string]$Report.InstallError } else { "" }

  Write-LogSection "INSTALLATION SUMMARY (REPLAY)"
  Write-Output "Mode: $mode"

  if (-not [string]::IsNullOrWhiteSpace($install_error)) {
    Write-Output "Result: failed"
    Write-Output "Reason: $install_error"
  } else {
    Write-Output "Result: success"
  }

  Write-Output ""
  Write-Output "Installer execution results:"

  if (-not $results -or $results.Count -eq 0) {
    Write-Output "  (no installer scripts executed)"
    return
  }

  foreach ($result in $results) {
    $critical_tag = if ($result.Critical) { " critical" } else { "" }
    $line = "  [{0}] {1,-8} {2}{3}" -f $result.Phase, $result.Status, $result.Entry, $critical_tag
    Write-Output $line
    if ($result.Message) {
      Write-Output "    reason: $($result.Message)"
    }
  }
}

if ($Help) {
  @"
Usage: .\install\install.ps1 [-BaseOnly|-All] [-Scope user|machine] [-MachineScope] [-Help]

-BaseOnly  Install only required packages.
-All       Install required and optional packages.
-Scope     winget scope for package installs: machine (default) or user.
-MachineScope Shortcut for -Scope machine.
-Help      Show this help message.
"@ | Write-Output
  exit 0
}

if ($BaseOnly -and $All) {
  Write-LogError "Use either -BaseOnly or -All, not both."
  exit 1
}

$effective_scope = $Scope
if ($MachineScope) {
  $effective_scope = "machine"
}

if (-not $IsWindows) {
  Write-LogError "This installer supports Windows 11 only."
  exit 1
}

if ($effective_scope -eq "machine" -and -not (Test-IsProcessElevated)) {
  if (Test-IsSshSession) {
    Write-LogError "Machine-scope install requires an elevated local session. SSH sessions cannot trigger UAC elevation."
    Write-LogError "Use -Scope user over SSH, or run this installer locally in an elevated terminal."
    exit 1
  }

  if ($ElevatedRelaunch) {
    Write-LogError "Installer relaunch completed without administrator elevation. Start PowerShell as Administrator and retry."
    exit 1
  }

  $report_path = if ([string]::IsNullOrWhiteSpace($RelaunchReportPath)) {
    Join-Path $env:TEMP ("nvim-installer-report-{0}.json" -f ([guid]::NewGuid().ToString("N")) )
  } else {
    $RelaunchReportPath
  }

  $ps_exe = if (Test-CommandExists "pwsh") { "pwsh" } else { "powershell" }
  $relaunch_args = @(
    "-NoProfile",
    "-ExecutionPolicy", "Bypass",
    "-File", $MyInvocation.MyCommand.Path,
    "-Scope", $effective_scope,
    "-ElevatedRelaunch",
    "-RelaunchReportPath", $report_path
  )

  if ($BaseOnly) {
    $relaunch_args += "-BaseOnly"
  }
  if ($All) {
    $relaunch_args += "-All"
  }
  if ($MachineScope) {
    $relaunch_args += "-MachineScope"
  }

  Write-LogInfo "Machine-scope install requires elevation. Relaunching installer with administrator rights."
  try {
    $elevated = Start-Process -FilePath $ps_exe -Verb RunAs -ArgumentList $relaunch_args -WorkingDirectory $PSScriptRoot -PassThru -Wait

    $replayed = $false
    try {
      $report = Read-RelaunchReport -Path $report_path
      if ($null -ne $report) {
        Write-RelaunchSummaryReplay -Report $report
        $replayed = $true
      }
    } catch {
      Write-LogWarn "Failed to read relaunch installation summary: $($_.Exception.Message)"
    } finally {
      if (-not [string]::IsNullOrWhiteSpace($report_path) -and (Test-Path -LiteralPath $report_path)) {
        Remove-Item -LiteralPath $report_path -Force -ErrorAction SilentlyContinue
      }
    }

    if (-not $replayed) {
      Write-LogWarn "Elevated installer finished, but summary replay data was unavailable."
    }

    exit $elevated.ExitCode
  } catch {
    throw "Administrator elevation was canceled or failed."
  }
}

$env:NVIM_INSTALL_SCOPE = $effective_scope
Write-LogInfo "Package installation scope: $effective_scope"

if (-not (Test-CommandExists "winget")) {
  Write-LogError "winget is required but not found. Install App Installer from Microsoft Store."
  exit 1
}

$install_optional = $true
if ($BaseOnly) {
  $install_optional = $false
}

$script:INSTALLER_RESULTS = @()
$critical_entries = @{}
foreach ($entry in @(
  "installers/winget/gsudo.ps1",
  "installers/winget/neovim.ps1"
)) {
  $critical_entries[$entry.ToLowerInvariant()] = $true
}

function Add-InstallerResult {
  param(
    [Parameter(Mandatory = $true)][string]$Phase,
    [Parameter(Mandatory = $true)][string]$Entry,
    [Parameter(Mandatory = $true)][string]$Status,
    [bool]$Critical = $false,
    [string]$Message = ""
  )

  $script:INSTALLER_RESULTS += [PSCustomObject]@{
    Phase = $Phase
    Entry = $Entry
    Status = $Status
    Critical = $Critical
    Message = $Message
  }
}

function Get-ManifestEntries {
  param([Parameter(Mandatory = $true)][string]$ManifestPath)

  if (-not (Test-Path -LiteralPath $ManifestPath)) {
    throw "Missing manifest: $ManifestPath"
  }

  Get-Content -LiteralPath $ManifestPath |
    ForEach-Object { $_.Trim() } |
    Where-Object { $_ -and -not $_.StartsWith("#") }
}

function Run-Manifest {
  param(
    [Parameter(Mandatory = $true)][string]$ManifestPath,
    [Parameter(Mandatory = $true)][string]$PhaseName,
    [hashtable]$CriticalEntries = @{}
  )

  $entries = @(Get-ManifestEntries -ManifestPath $ManifestPath)
  $total = $entries.Count
  $index = 0

  foreach ($entry in $entries) {
    $index += 1
    $entry_key = $entry.ToLowerInvariant()
    $is_critical = $CriticalEntries.ContainsKey($entry_key)
    $script_path = Join-Path $script_dir $entry

    if (-not (Test-Path -LiteralPath $script_path)) {
      $message = "Missing installer script: $entry"
      Add-InstallerResult -Phase $PhaseName -Entry $entry -Status "failed" -Critical $is_critical -Message $message
      if ($is_critical) {
        throw $message
      }

      Write-LogWarn $message
      continue
    }

    $critical_suffix = if ($is_critical) { " (critical)" } else { "" }
    Write-LogInfo "[$index/$total] Running $entry$critical_suffix"

    try {
      & $script_path
      Add-InstallerResult -Phase $PhaseName -Entry $entry -Status "ok" -Critical $is_critical
    } catch {
      $message = $_.Exception.Message
      Add-InstallerResult -Phase $PhaseName -Entry $entry -Status "failed" -Critical $is_critical -Message $message
      if ($is_critical) {
        Write-LogError "Installer failed: $entry - $message"
        throw "Critical installer failed: $entry"
      }

      Write-LogWarn "Installer failed (continuing): $entry - $message"
    }
  }
}

function Write-InstallerExecutionSummary {
  param([object[]]$InstallerResults = @())

  Write-Output ""
  Write-Output "Installer execution results:"

  if (-not $InstallerResults -or $InstallerResults.Count -eq 0) {
    Write-Output "  (no installer scripts executed)"
    return
  }

  foreach ($result in $InstallerResults) {
    $critical_tag = if ($result.Critical) { " critical" } else { "" }
    $line = "  [{0}] {1,-8} {2}{3}" -f $result.Phase, $result.Status, $result.Entry, $critical_tag
    Write-Output $line
    if ($result.Message) {
      Write-Output "    reason: $($result.Message)"
    }
  }
}

function Write-InstallationSummary {
  param(
    [Parameter(Mandatory = $true)][string]$Mode,
    [object[]]$InstallerResults = @()
  )

  function Refresh-ProcessPath {
    $sources = @(
      $env:Path,
      [Environment]::GetEnvironmentVariable("Path", "Machine"),
      [Environment]::GetEnvironmentVariable("Path", "User")
    )

    $seen = New-Object "System.Collections.Generic.HashSet[string]" ([System.StringComparer]::OrdinalIgnoreCase)
    $combined = New-Object System.Collections.Generic.List[string]

    foreach ($source in $sources) {
      if ([string]::IsNullOrWhiteSpace($source)) {
        continue
      }

      foreach ($entry in $source.Split(";", [System.StringSplitOptions]::RemoveEmptyEntries)) {
        $normalized = $entry.Trim()
        if (-not [string]::IsNullOrWhiteSpace($normalized) -and $seen.Add($normalized)) {
          [void]$combined.Add($normalized)
        }
      }
    }

    if ($combined.Count -gt 0) {
      $env:Path = [string]::Join(";", $combined)
    }
  }

  function Get-InstalledVersionFromCommand {
    param(
      [string]$Command,
      [string[]]$VersionArgs = @("--version"),
      [string]$Pattern = "([0-9]+(?:\.[0-9]+){1,3})"
    )

    if (-not $Command -or -not (Test-CommandExists $Command)) {
      return ""
    }

    $line = Get-FirstOutputLine -Command $Command -Arguments $VersionArgs
    if ($line -and ($line -match $Pattern)) {
      return $matches[1]
    }

    return ""
  }

  function Get-InstalledVersionFromCandidates {
    param(
      [string[]]$Candidates = @(),
      [string[]]$VersionArgs = @("--version"),
      [string]$Pattern = "([0-9]+(?:\.[0-9]+){1,3})"
    )

    foreach ($candidate in $Candidates) {
      if ([string]::IsNullOrWhiteSpace($candidate)) {
        continue
      }

      if (-not (Test-Path -LiteralPath $candidate)) {
        continue
      }

      $line = Get-FirstOutputLine -Command $candidate -Arguments $VersionArgs
      if ($line -and ($line -match $Pattern)) {
        return $matches[1]
      }
    }

    return ""
  }

  function Get-ToolExecutableCandidates {
    param([Parameter(Mandatory = $true)][string]$ToolKey)

    switch ($ToolKey) {
      "neovim" {
        return @(
          (Join-Path $env:LOCALAPPDATA "Microsoft\WinGet\Links\nvim.exe"),
          (Join-Path $env:LOCALAPPDATA "Programs\Neovim\nvim-win64\bin\nvim.exe"),
          (Join-Path $env:LOCALAPPDATA "Programs\Neovim\bin\nvim.exe"),
          (Join-Path $env:ProgramFiles "Neovim\bin\nvim.exe")
        )
      }
      "python" {
        return @(
          (Join-Path $env:LOCALAPPDATA "Microsoft\WinGet\Links\python.exe"),
          (Join-Path $env:LOCALAPPDATA "Programs\Python\Python312\python.exe"),
          (Join-Path $env:ProgramFiles "Python312\python.exe")
        )
      }
      "nodejs" {
        return @(
          (Join-Path $env:LOCALAPPDATA "Microsoft\WinGet\Links\node.exe"),
          (Join-Path $env:ProgramFiles "nodejs\node.exe"),
          (Join-Path $env:LOCALAPPDATA "Programs\nodejs\node.exe")
        )
      }
      default {
        return @()
      }
    }
  }

  function Get-ToolWingetId {
    param([Parameter(Mandatory = $true)][string]$ToolKey)

    switch ($ToolKey) {
      "neovim" { return "Neovim.Neovim" }
      "python" { return "Python.Python.3.12" }
      "nodejs" { return "OpenJS.NodeJS.LTS" }
      default { return "" }
    }
  }

  function Test-NerdFontInstalled {
    $font_dir = Join-Path $env:LOCALAPPDATA "Microsoft\Windows\Fonts"
    if (-not (Test-Path -LiteralPath $font_dir)) {
      return $false
    }

    $files = Get-ChildItem -Path $font_dir -Filter "JetBrainsMono`NerdFont-*.ttf" -ErrorAction SilentlyContinue
    return $files.Count -gt 0
  }

  function Get-NerdFontInstalledVersion {
    $version_file = Join-Path $env:LOCALAPPDATA "nvim-installer\nerd-font-version.txt"
    if (Test-Path -LiteralPath $version_file) {
      $value = Get-Content -LiteralPath $version_file -ErrorAction SilentlyContinue | Select-Object -First 1
      if ($value) {
        return $value.Trim()
      }
    }

    if (Test-NerdFontInstalled) {
      return "found"
    }

    return ""
  }

  Write-LogSection "INSTALLATION SUMMARY"
  Write-Output "Mode: $Mode"
  Write-Output ""

  $managed_tool_keys = @("fd", "fzf", "git", "gsudo", "lazygit", "neovim", "nerd-font", "nodejs", "python", "ripgrep")
  $tool_specs = @{
    "neovim" = @{ Name = "nvim"; Cmd = "nvim"; VersionArgs = @("--version"); Pattern = "NVIM v(.+)" }
    "git" = @{ Name = "git"; Cmd = "git"; VersionArgs = @("--version"); Pattern = "git version (.+)" }
    "gsudo" = @{ Name = "gsudo"; Cmd = "gsudo"; VersionArgs = @("--version"); Pattern = "([0-9]+(?:\.[0-9]+){1,3})" }
    "lazygit" = @{ Name = "lazygit"; Cmd = "lazygit"; VersionArgs = @("--version"); Pattern = "([0-9]+\.[0-9]+\.[0-9]+)" }
    "fd" = @{ Name = "fd"; Cmd = "fd"; VersionArgs = @("--version"); Pattern = "fd ([^\s]+)" }
    "fzf" = @{ Name = "fzf"; Cmd = "fzf"; VersionArgs = @("--version"); Pattern = "([^\s]+)" }
    "ripgrep" = @{ Name = "ripgrep"; Cmd = "rg"; VersionArgs = @("--version"); Pattern = "ripgrep ([^\s]+)" }
    "python" = @{ Name = "python"; Cmd = "python"; VersionArgs = @("--version"); Pattern = "Python ([0-9]+(?:\.[0-9]+){1,3})" }
    "nodejs" = @{ Name = "nodejs"; Cmd = "node"; VersionArgs = @("--version"); Pattern = "^v([0-9]+(?:\.[0-9]+){1,3})" }
    "nerd-font" = @{ Name = "nerd-font" }
  }

  $requirements = Get-MinRequiredVersions
  $all_keys = @($managed_tool_keys + $requirements.Keys) | Sort-Object -Unique
  $process_path_refreshed = $false

  foreach ($tool_key in $all_keys) {
    $required = Get-MinRequiredVersion -Tool $tool_key
    $is_managed = $managed_tool_keys -contains $tool_key

    $display_name = $tool_key
    $installed = ""
    $detected_after_refresh = $false
    $resolved_from_candidates = $false
    if ($tool_specs.ContainsKey($tool_key)) {
      $spec = $tool_specs[$tool_key]
      $display_name = $spec.Name
      if ($tool_key -eq "nerd-font") {
        $installed = Get-NerdFontInstalledVersion
      } else {
        $installed = Get-InstalledVersionFromCommand -Command $spec.Cmd -VersionArgs $spec.VersionArgs -Pattern $spec.Pattern
        if (-not $installed) {
          if (-not $process_path_refreshed) {
            Refresh-ProcessPath
            $process_path_refreshed = $true
          }

          $installed = Get-InstalledVersionFromCommand -Command $spec.Cmd -VersionArgs $spec.VersionArgs -Pattern $spec.Pattern
          if ($installed) {
            $detected_after_refresh = $true
          }
        }

        if (-not $installed) {
          $candidates = @(Get-ToolExecutableCandidates -ToolKey $tool_key)
          if ($candidates.Count -gt 0) {
            $installed = Get-InstalledVersionFromCandidates -Candidates $candidates -VersionArgs $spec.VersionArgs -Pattern $spec.Pattern
            if ($installed) {
              $resolved_from_candidates = $true
            }
          }
        }
      }
    } else {
      $display_name = $tool_key
      $installed = Get-InstalledVersionFromCommand -Command $tool_key
    }

    $required_out = if ($required) { $required } else { "-" }
    $installed_out = if ($installed) { $installed } else { "not found" }

    $status = "not-managed"
    if ($is_managed) {
      if (-not $required) {
        $status = "missing-required"
      } elseif (-not $installed) {
        $winget_id = Get-ToolWingetId -ToolKey $tool_key
        if ($winget_id -and (Test-WingetPackageInstalled -Id $winget_id)) {
          $status = "version-check-deferred"
          $installed_out = "installed"
        } else {
          $status = "not-found"
        }
      } else {
        try {
          if (Test-VersionGreaterOrEqual -Current $installed -Required $required) {
            if ($detected_after_refresh -or $resolved_from_candidates) {
              $status = "detected-after-refresh"
            } else {
              $status = "ok"
            }
          } else {
            $status = "upgrade-needed"
          }
        } catch {
          $status = "version-check-failed"
        }
      }
    }

    Write-Output ("  {0,-12} required: {1,-10} installed: {2,-12} status: {3}" -f $display_name, $required_out, $installed_out, $status)
  }

  Write-InstallerExecutionSummary -InstallerResults $InstallerResults
}

$mode = if ($install_optional) { "base + optional" } else { "base only" }
$install_error = ""

try {
  Write-LogSection "BASE INSTALLATION"
  Run-Manifest -ManifestPath (Join-Path $script_dir "manifests/windows-base.txt") -PhaseName "base" -CriticalEntries $critical_entries

  if ($install_optional) {
    Write-LogSection "OPTIONAL INSTALLATION"
    Run-Manifest -ManifestPath (Join-Path $script_dir "manifests/windows-optional.txt") -PhaseName "optional"
  } else {
    Write-LogInfo "Optional package installation skipped (-BaseOnly)"
  }

  Write-LogSection "POST INSTALLATION"
  $post_entry = "post/neovim.ps1"
  try {
    & (Join-Path $script_dir $post_entry)
    Add-InstallerResult -Phase "post" -Entry $post_entry -Status "ok" -Critical $true
  } catch {
    $message = $_.Exception.Message
    Add-InstallerResult -Phase "post" -Entry $post_entry -Status "failed" -Critical $true -Message $message
    throw "Critical installer failed: $post_entry"
  }
} catch {
  $install_error = $_.Exception.Message
  Write-LogWarn "Installation stopped due to critical failure: $install_error"
}

Write-InstallationSummary -Mode $mode -InstallerResults $script:INSTALLER_RESULTS
Write-RelaunchReport -Path $RelaunchReportPath -Mode $mode -InstallError $install_error -InstallerResults $script:INSTALLER_RESULTS

if ($install_error) {
  throw $install_error
}

Write-LogInfo "Installation complete"
