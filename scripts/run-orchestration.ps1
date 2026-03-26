param(
  [string]$Distro = "Ubuntu",
  # Use an explicit path to avoid tilde/expansion issues in quoted bash -lc commands
  [string]$RepoPath = "/home/sushi/ansible_homelab",
  [string]$Inventory = "inventory.local",
  [string]$Tags = "stage1,stage2,stage3",
  [switch]$SkipPull,
  [switch]$Check
)

$ErrorActionPreference = "Stop"

$pullCmd = if ($SkipPull) { "echo 'Skipping git pull'" } else { "git pull --ff-only" }
$checkFlag = if ($Check) { "--check" } else { "" }

# Build a single-line bash command to avoid heredoc/quoting issues
$bashCommand = "set -euo pipefail; cd $RepoPath; $pullCmd; ansible-playbook -i $Inventory playbooks/master.yml --tags $Tags $checkFlag -K"
wsl -d $Distro -- bash -lc "$bashCommand"
