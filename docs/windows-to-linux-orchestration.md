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

- `group_vars/all/vars.yml` — tracked defaults and placeholders (safe to commit)
- `group_vars/all/vars_local.yml` — **local secrets** (gitignored). Ansible loads both; `vars_local.yml` overrides matching keys. See `vars_local.yml.example`.

Usually set manually:

- `username`
- `puid`
- `pgid`
- `timezone`
- `ip_address` (when needed)
- `domain` (for stage3 proxy/auth flows)

Generate and apply script-managed secrets (writes **`group_vars/all/vars_local.yml`**, not `vars.yml`):

```bash
bash scripts/generate-values.sh
bash scripts/apply-generated-values.sh --stage 2
bash scripts/apply-generated-values.sh --stage 3
```

Optional/manual secrets you type yourself (put them in **`vars_local.yml`** so they stay out of git, or use placeholders in `vars.yml` only if you accept the risk):

- `immich_admin_password`, `jellyfin_admin_password` (if using auto-setup), etc.

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

## 8b) Sync Windows repo copy into WSL (mirror)

If you edit on Windows and want the WSL clone under `~/ansible_homelab` to match, run **from repo root** (PowerShell):

```powershell
.\scripts\sync-to-wsl.ps1
```

This uses `rsync` inside WSL. It **preserves** WSL-only files: `group_vars/all/vars_local.yml`, `.generated-values.env`, and `inventory.local` (so secrets on the control node are not wiped).

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