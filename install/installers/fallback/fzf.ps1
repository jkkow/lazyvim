$ErrorActionPreference = "Stop"

$script_dir = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $script_dir "../../lib/common.ps1")
. (Join-Path $script_dir "../../lib/version.ps1")
. (Join-Path $script_dir "../../lib/version_requirements.ps1")

$fallback_version = Normalize-Version $FZF_FALLBACK_VERSION
$download_url = "https://github.com/junegunn/fzf/releases/download/v${fallback_version}/fzf-${fallback_version}-windows_amd64.zip"

$tmp_dir = Join-Path ([IO.Path]::GetTempPath()) ("fzf-fallback-" + [Guid]::NewGuid().ToString("N"))
$archive_path = Join-Path $tmp_dir "fzf.zip"
$extract_root = Join-Path $tmp_dir "extract"
$install_dir = Join-Path $env:LOCALAPPDATA "Programs\fzf"

New-Item -ItemType Directory -Path $tmp_dir -Force | Out-Null
New-Item -ItemType Directory -Path $extract_root -Force | Out-Null
New-Item -ItemType Directory -Path $install_dir -Force | Out-Null

try {
  Write-LogInfo "Downloading fzf v$fallback_version"
  Invoke-WebRequest -Uri $download_url -OutFile $archive_path

  Expand-Archive -Path $archive_path -DestinationPath $extract_root -Force

  $fzf_exe = Get-ChildItem -Path $extract_root -Filter "fzf.exe" -Recurse | Select-Object -First 1
  if ($null -eq $fzf_exe) {
    throw "fzf.exe not found in fallback archive"
  }

  $target_exe = Join-Path $install_dir "fzf.exe"
  Copy-Item -LiteralPath $fzf_exe.FullName -Destination $target_exe -Force
  Add-UserPathEntry -PathEntry $install_dir

  $line = (& $target_exe --version | Select-Object -First 1)
  if (-not $line -or -not ($line -match "^([^\s]+)")) {
    throw "Unable to read fzf version after fallback install"
  }

  $installed = $matches[1]
  if (-not (Test-VersionGreaterOrEqual -Current $installed -Required $FZF_REQUIRED_VERSION)) {
    throw "Installed fzf version $installed does not satisfy $FZF_REQUIRED_VERSION"
  }

  Write-LogInfo "fzf installed via fallback ($installed)"
} finally {
  if (Test-Path -LiteralPath $tmp_dir) {
    Remove-Item -LiteralPath $tmp_dir -Recurse -Force
  }
}
