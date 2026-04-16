$ErrorActionPreference = "Stop"

$script_dir = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $script_dir "../../lib/common.ps1")
. (Join-Path $script_dir "../../lib/version.ps1")
. (Join-Path $script_dir "../../lib/version_requirements.ps1")

$required_version = Get-MinRequiredVersion -Tool "neovim"
if (-not $required_version) {
  throw "Missing required version for neovim in install/min-required-versions.txt"
}

$fallback_version = Normalize-Version $required_version
$download_url = "https://github.com/neovim/neovim/releases/download/v${fallback_version}/nvim-win64.zip"

$tmp_dir = Join-Path ([IO.Path]::GetTempPath()) ("nvim-fallback-" + [Guid]::NewGuid().ToString("N"))
$archive_path = Join-Path $tmp_dir "nvim-win64.zip"
$extract_root = Join-Path $tmp_dir "extract"
$install_root = Join-Path $env:LOCALAPPDATA "Programs\Neovim"
$install_dir = Join-Path $install_root "nvim-win64"

New-Item -ItemType Directory -Path $tmp_dir -Force | Out-Null
New-Item -ItemType Directory -Path $extract_root -Force | Out-Null
New-Item -ItemType Directory -Path $install_root -Force | Out-Null

try {
  Write-LogInfo "Downloading Neovim v$fallback_version"
  Invoke-WebRequest -Uri $download_url -OutFile $archive_path

  Expand-Archive -Path $archive_path -DestinationPath $extract_root -Force

  $extracted = Join-Path $extract_root "nvim-win64"
  if (-not (Test-Path -LiteralPath $extracted)) {
    throw "Extracted nvim-win64 directory not found"
  }

  if (Test-Path -LiteralPath $install_dir) {
    Remove-Item -LiteralPath $install_dir -Recurse -Force
  }

  Move-Item -LiteralPath $extracted -Destination $install_dir

  $bin_path = Join-Path $install_dir "bin"
  Add-UserPathEntry -PathEntry $bin_path

  $nvim_exe = Join-Path $bin_path "nvim.exe"
  if (-not (Test-Path -LiteralPath $nvim_exe)) {
    throw "nvim.exe not found after fallback install"
  }

  $line = (& $nvim_exe --version | Select-Object -First 1)
  if (-not $line -or -not ($line -match "NVIM v(.+)")) {
    throw "Unable to read nvim version after fallback install"
  }

  $installed = $matches[1]
  if (-not (Test-VersionGreaterOrEqual -Current $installed -Required $required_version)) {
    throw "Installed nvim version $installed does not satisfy $required_version"
  }

  Write-LogInfo "nvim installed via fallback ($installed)"
} finally {
  if (Test-Path -LiteralPath $tmp_dir) {
    Remove-Item -LiteralPath $tmp_dir -Recurse -Force
  }
}
