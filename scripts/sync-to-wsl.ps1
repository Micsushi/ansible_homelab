# Mirror Windows repo -> WSL ~/ansible_homelab. Preserves WSL-only secrets:
#   group_vars/all/vars_local.yml, .generated-values.env, inventory.local
param(
  [string]$Distro = "Ubuntu",
  [string]$WindowsRepo = "",
  [string]$WslDest = "~/ansible_homelab",
  [switch]$WhatIf
)

$ErrorActionPreference = "Stop"

if (-not $WindowsRepo) {
  $WindowsRepo = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
}

$wslpathOut = (wsl -d $Distro -- wslpath -a $WindowsRepo 2>&1)
if ($LASTEXITCODE -ne 0) {
  Write-Error "wslpath failed: $wslpathOut"
}
$WslSrc = $wslpathOut.Trim()

# Keep WSL-only secrets when mirroring Windows -> WSL (--delete would remove them otherwise)
$bashCmd = "set -euo pipefail; mkdir -p $WslDest; rsync -a --delete --exclude='group_vars/all/vars_local.yml' --exclude='group_vars/all/vars_local.yml.bak.*' --exclude='.generated-values.env' --exclude='inventory.local' '$WslSrc/' '$WslDest/'"

if ($WhatIf) {
  Write-Host "Would run in WSL ($Distro):"
  Write-Host $bashCmd
  exit 0
}

wsl -d $Distro -- bash -lc $bashCmd
Write-Host "Synced to WSL: $WslDest (vars_local.yml, .generated-values.env, inventory.local excluded)"
