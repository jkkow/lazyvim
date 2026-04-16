$ErrorActionPreference = "Stop"

$script_dir = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $script_dir "../../lib/common.ps1")
. (Join-Path $script_dir "../../lib/version.ps1")
. (Join-Path $script_dir "../../lib/version_requirements.ps1")

$NERD_FONT_NAME = "JetBrainsMono"
$required_version = Get-MinRequiredVersion -Tool "nerd-font"
if (-not $required_version) {
  throw "Missing required version for nerd-font in install/min-required-versions.txt"
}

$version_state_dir = Join-Path $env:LOCALAPPDATA "nvim-installer"
$version_state_file = Join-Path $version_state_dir "nerd-font-version.txt"

function Get-InstalledNerdFontVersion {
  if (Test-Path -LiteralPath $version_state_file) {
    $value = (Get-Content -LiteralPath $version_state_file -ErrorAction SilentlyContinue | Select-Object -First 1)
    if ($value) {
      return $value.Trim()
    }
  }

  return ""
}

function Set-InstalledNerdFontVersion {
  param([Parameter(Mandatory = $true)][string]$Version)

  New-Item -ItemType Directory -Path $version_state_dir -Force | Out-Null
  Set-Content -LiteralPath $version_state_file -Value $Version -NoNewline
}

function Test-NerdFontInstalled {
  $font_dir = Join-Path $env:LOCALAPPDATA "Microsoft\Windows\Fonts"
  if (-not (Test-Path -LiteralPath $font_dir)) {
    return $false
  }

  $pattern = "$NERD_FONT_NAME`NerdFont-*.ttf"
  $files = Get-ChildItem -Path $font_dir -Filter $pattern -ErrorAction SilentlyContinue
  return $files.Count -gt 0
}

$installed_version = Get-InstalledNerdFontVersion
if ((Test-NerdFontInstalled) -and $installed_version -and (Test-VersionGreaterOrEqual -Current $installed_version -Required $required_version)) {
  Write-LogInfo "$NERD_FONT_NAME Nerd Font $installed_version already satisfies $required_version"
  exit 0
}

$font_version = $required_version.TrimStart("v")
$download_url = "https://github.com/ryanoasis/nerd-fonts/releases/download/v${font_version}/${NERD_FONT_NAME}.zip"

$tmp_dir = Join-Path ([IO.Path]::GetTempPath()) ("nerd-font-" + [Guid]::NewGuid().ToString("N"))
$archive_path = Join-Path $tmp_dir "$NERD_FONT_NAME.zip"
$extract_dir = Join-Path $tmp_dir "extract"
$font_dir = Join-Path $env:LOCALAPPDATA "Microsoft\Windows\Fonts"
$registry_path = "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Fonts"

New-Item -ItemType Directory -Path $tmp_dir -Force | Out-Null
New-Item -ItemType Directory -Path $extract_dir -Force | Out-Null
New-Item -ItemType Directory -Path $font_dir -Force | Out-Null

try {
  Write-LogInfo "Downloading $NERD_FONT_NAME Nerd Font v$font_version"
  Invoke-WebRequest -Uri $download_url -OutFile $archive_path

  Expand-Archive -Path $archive_path -DestinationPath $extract_dir -Force

  $ttf_files = Get-ChildItem -Path $extract_dir -Filter "*.ttf" -Recurse
  if ($ttf_files.Count -eq 0) {
    throw "No TTF files found in downloaded font archive"
  }

  foreach ($font_file in $ttf_files) {
    $destination = Join-Path $font_dir $font_file.Name
    Copy-Item -LiteralPath $font_file.FullName -Destination $destination -Force

    $font_name = [IO.Path]::GetFileNameWithoutExtension($font_file.Name)
    New-ItemProperty -Path $registry_path -Name "$font_name (TrueType)" -Value $destination -PropertyType String -Force | Out-Null
  }

  Set-InstalledNerdFontVersion -Version $font_version

  Write-LogInfo "$NERD_FONT_NAME Nerd Font installed for current user"
  Write-LogInfo "Set your terminal font to a Nerd Font variant, for example: JetBrainsMono Nerd Font"
} finally {
  if (Test-Path -LiteralPath $tmp_dir) {
    Remove-Item -LiteralPath $tmp_dir -Recurse -Force
  }
}
