# Windows WSL2 -> Linux Orchestration

This is the single end-to-end workflow for your setup:

1. You edit playbooks on Windows.
2. You run Ansible from WSL2 (control node).
3. WSL2 connects over SSH to Linux target host(s) and executes the playbook tasks there.
4. Your Linux host(s) get updated by that playbook run.
5. You can re-run with one local command.

---

## Architecture 

- **Windows**: editing, git commits, launching a helper command.
- **WSL2 Ubuntu**: runs `ansible-playbook`.
- **Linux host(s)**: remote targets where changes are applied.

Ansible is push-based. Each time you run it, it applies desired state to target hosts.

---

## 1) Install WSL2 and Ubuntu on Windows

Run PowerShell as Administrator:

```powershell
wsl --install -d Ubuntu
```

Reboot if prompted, then verify:

```powershell
wsl --status
wsl -l -v
```

You want Ubuntu on **version 2**.

---

## 2) Install Ansible and tools in WSL2

Open Ubuntu (WSL) and run:

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y git ansible openssh-client
ansible-galaxy collection install community.docker
```

Verify:

```bash
ansible --version
ansible-playbook --version
```

---

## 3) Clone repo in Linux home (not /mnt/c)

Use Linux filesystem for reliability:

```bash
cd ~
git clone git@github.com:<your_user>/ansible_homelab.git
cd ansible_homelab
```

If you already had an older clone (from before the repo was restructured into `playbooks/` and `scripts/`), update it so paths in this guide work:

```bash
cd ~/ansible_homelab
git fetch --all
git reset --hard origin/main
```

---

## 4) Configure SSH from WSL2 -> Linux target

### 4.1 Find username and IP on the Linux target

On the **target Linux machine** (not WSL), run:

```bash
whoami
```

This prints the username you should use for SSH and in `inventory.local`.

Then get the LAN IP address (look for `inet 192.168.x.x` or similar):

```bash
ip addr show
```

Or a shorter filtered view:

```bash
ip -4 addr show | grep -E "inet (10\.|172\.16\.|192\.168\.)"
```

Use that username and IP/hostname in the steps below.

### 4.2 Generate SSH key in WSL

Generate SSH key in WSL:

```bash
ssh-keygen -t ed25519 -C "ansible-control-node"
```

### 4.3 Install key on target

Install key on the Linux target:

```bash
ssh-copy-id <linux_user>@<linux_host_or_ip>
```

### 4.4 Test SSH

Test from WSL:

```bash
ssh <linux_user>@<linux_host_or_ip>
```

---

## 5) Use a private inventory file

Keep tracked `inventory` as template, and put real hosts in `inventory.local`.

Example `inventory.local`:

```ini
[homeserver]
home-laptop ansible_host=192.168.1.50 ansible_user=sushi ansible_ssh_private_key_file=~/.ssh/id_ed25519

[homeserver:vars]
ansible_python_interpreter=/usr/bin/python3
```

Multi-host example:

```ini
[homeserver]
home-laptop ansible_host=192.168.1.50 ansible_user=sushi ansible_ssh_private_key_file=~/.ssh/id_ed25519
mini-pc ansible_host=192.168.1.51 ansible_user=sushi ansible_ssh_private_key_file=~/.ssh/id_ed25519
nas ansible_host=192.168.1.52 ansible_user=admin ansible_ssh_private_key_file=~/.ssh/id_ed25519
```

---

## 6) Configure variables and secrets

Edit:

- `group_vars/all/vars.yml`

Usually set manually:

- `username`
- `puid`
- `pgid`
- `timezone`
- `ip_address` (when needed)
- `domain` (for stage3 proxy/auth flows)

Generate and apply script-managed secrets:

```bash
bash scripts/generate-values.sh
bash scripts/apply-generated-values.sh --stage 2
bash scripts/apply-generated-values.sh --stage 3
```

Still manual for stage3:

- `cloudflare_email`
- `cloudflare_api_key`
- `traefik_basic_auth_hash`
- `google_mail`
- `google_insecure_app_pass`
- `authelia_admin_mail`
- `authelia_admin_argon2id_pass`

---

## 7) Validate before first real run

From WSL repo root:

```bash
ansible -i inventory.local all -m ping
ansible-playbook -i inventory.local playbooks/master.yml --syntax-check
```

---

## 8) Run playbooks from WSL2 manually

```bash
ansible-playbook -i inventory.local playbooks/master.yml --tags stage1
ansible-playbook -i inventory.local playbooks/master.yml --tags stage2
ansible-playbook -i inventory.local playbooks/master.yml --tags stage3
```

Or:

```bash
ansible-playbook -i inventory.local playbooks/master.yml --tags stage1,stage2,stage3
```
---

## 9) One-command launcher from Windows

This repo includes:

- `scripts/run-orchestration.ps1`

It launches WSL2, optionally pulls latest repo, and runs the playbook.

### Basic usage (PowerShell, from repo root)

```powershell
.\scripts\run-orchestration.ps1
```

Defaults:

- distro: `Ubuntu`
- repo path in WSL: `~/ansible_homelab`
- inventory: `inventory.local`
- tags: `stage1,stage2,stage3`
- always runs `ansible-playbook` with `-K` (asks for sudo password on the target host)

### Common examples

Only stage2:

```powershell
.\scripts\run-orchestration.ps1 -Tags stage2
```

Dry run:

```powershell
.\scripts\run-orchestration.ps1 -Tags stage2 -Check
```

Skip git pull:

```powershell
.\scripts\run-orchestration.ps1 -SkipPull
```

Custom distro/repo path:

```powershell
.\scripts\run-orchestration.ps1 -Distro Ubuntu -RepoPath ~/ansible_homelab -Inventory inventory.local
```

---

## 10) Daily update flow

1) Edit on Windows  
2) Commit + push  
3) Run one local command:

```powershell
.\scripts\run-orchestration.ps1 -Tags stage2
```

That command executes in WSL:

- `git pull --ff-only` (unless `-SkipPull`)
- `ansible-playbook -i inventory.local playbooks/master.yml --tags ...`

---

## 11) Optional automation on the Linux host itself

If you want periodic unattended apply, use `ansible-pull` + a systemd timer on the Linux host.
Keep this optional; many homelab setups prefer manual runs for safety.

---

## 12) Inventory and gitignore guidance

Recommended:

- Track `inventory` (template only)
- Ignore `inventory.local` (real host details)

`inventory.local` is already ignored in `.gitignore`.

---

## 13) Troubleshooting

- `UNREACHABLE!`:
  - Test `ssh user@host` manually from WSL.
- `ansible-playbook` missing:
  - Install Ansible in WSL Ubuntu.
- Docker permission denied on target:
  - `sudo usermod -aG docker <user>` and relogin.
- Wrong hosts being targeted:
  - Ensure command uses `-i inventory.local`.

