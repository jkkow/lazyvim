$ErrorActionPreference = "Stop"

$script_dir = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $script_dir "../../lib/common.ps1")
. (Join-Path $script_dir "../../lib/version_requirements.ps1")

function Test-NerdFontInstalled {
  $font_dir = Join-Path $env:LOCALAPPDATA "Microsoft\Windows\Fonts"
  if (-not (Test-Path -LiteralPath $font_dir)) {
    return $false
  }

  $pattern = "$NERD_FONT_NAME`NerdFont-*.ttf"
  $files = Get-ChildItem -Path $font_dir -Filter $pattern -ErrorAction SilentlyContinue
  return $files.Count -gt 0
}

if (Test-NerdFontInstalled) {
  Write-LogInfo "$NERD_FONT_NAME Nerd Font already installed"
  exit 0
}

$font_version = $NERD_FONT_VERSION.TrimStart("v")
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

  Write-LogInfo "$NERD_FONT_NAME Nerd Font installed for current user"
  Write-LogInfo "Set your terminal font to a Nerd Font variant, for example: JetBrainsMono Nerd Font"
} finally {
  if (Test-Path -LiteralPath $tmp_dir) {
    Remove-Item -LiteralPath $tmp_dir -Recurse -Force
  }
}
