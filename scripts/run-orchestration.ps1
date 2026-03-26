param(
  [string]$Distro = "Ubuntu",
  [string]$RepoPath = "~/ansible_homelab",
  [string]$Inventory = "inventory.local",
  [string]$Tags = "stage1,stage2,stage3",
  [switch]$SkipPull,
  [switch]$Check
)

$ErrorActionPreference = "Stop"

$pullCmd = if ($SkipPull) { "echo 'Skipping git pull'" } else { "git pull --ff-only" }
$checkFlag = if ($Check) { "--check" } else { "" }

$bashCommand = @"
set -euo pipefail
cd $RepoPath
$pullCmd
ansible-playbook -i $Inventory playbooks/master.yml --tags $Tags $checkFlag
"@

wsl -d $Distro -- bash -lc $bashCommand
