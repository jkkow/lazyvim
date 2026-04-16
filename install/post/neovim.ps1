$ErrorActionPreference = "Stop"

$script_dir = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $script_dir "../lib/common.ps1")

function Resolve-NvimExe {
  if (Test-CommandExists "nvim") {
    $cmd = Get-Command "nvim" -ErrorAction SilentlyContinue
    if ($cmd) {
      return $cmd.Source
    }
  }

  $candidates = @(
    (Join-Path $env:LOCALAPPDATA "Programs\Neovim\nvim-win64\bin\nvim.exe"),
    (Join-Path $env:LOCALAPPDATA "Programs\Neovim\bin\nvim.exe"),
    (Join-Path $env:ProgramFiles "Neovim\bin\nvim.exe")
  )

  foreach ($candidate in $candidates) {
    if (Test-Path -LiteralPath $candidate) {
      return $candidate
    }
  }

  return ""
}

$source = Join-Path $HOME ".config\nvim"
$target = Join-Path $env:LOCALAPPDATA "nvim"

if (-not (Test-Path -LiteralPath $source)) {
  throw "Expected source config directory not found: $source"
}

if (Test-Path -LiteralPath $target) {
  $item = Get-Item -LiteralPath $target -Force
  if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) {
    try {
      $resolved_target = (Resolve-Path -LiteralPath $target).Path
      $resolved_source = (Resolve-Path -LiteralPath $source).Path
      if ([string]::Equals($resolved_target, $resolved_source, [System.StringComparison]::OrdinalIgnoreCase)) {
        Write-LogInfo "$target already points to $source"
      } else {
        Remove-Item -LiteralPath $target -Force
      }
    } catch {
      Remove-Item -LiteralPath $target -Force
    }
  } else {
    $stamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $backup = "$target.bak.$stamp"
    Move-Item -LiteralPath $target -Destination $backup
    Write-LogInfo "Backed up existing $target to $backup"
  }
}

if (-not (Test-Path -LiteralPath $target)) {
  try {
    New-Item -ItemType Junction -Path $target -Target $source | Out-Null
    Write-LogInfo "Created junction: $target -> $source"
  } catch {
    New-Item -ItemType SymbolicLink -Path $target -Target $source | Out-Null
    Write-LogInfo "Created symbolic link: $target -> $source"
  }
}

$init_path = Join-Path $target "init.lua"
if (-not (Test-Path -LiteralPath $init_path)) {
  throw "Config link validation failed: $init_path not found"
}

$nvim_exe = Resolve-NvimExe
if (-not $nvim_exe) {
  throw "nvim executable not found after installation"
}

& $nvim_exe --headless --clean -u NONE "+qa"
if ($LASTEXITCODE -ne 0) {
  throw "Neovim headless startup failed (exit=$LASTEXITCODE)"
}

Write-LogInfo "Neovim post-install smoke checks passed"
