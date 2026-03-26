# Ansible Homelab

Ansible playbooks for setting up a home server in stages.

Supported OS families:
- Ubuntu / Debian
- Fedora / CentOS / RedHat

## What Each Stage Does

- `stage1` - host setup
  - updates OS packages
  - installs base tools and pip packages
  - installs/configures Docker and network `homelab`
  - creates base folders under `docker_dir` and `data_dir`
  - optional GUI app install flow

- `stage2` - core services
  - deploys Immich, Samba, Jellyfin, Pi-hole
  - creates required service folders
  - runs service health checks

- `stage3` - access/security/ops
  - deploys Traefik, Authelia, Portainer, monitoring stack
  - deploys VPN option (Tailscale or WireGuard)
  - optional NPM, Uptime Kuma, Vaultwarden, TigerVNC, Coolify
  - runs monitoring health checks

- `stage4` - optional game servers
  - deploys Minecraft, Project Zomboid, Valheim, Discord bot runner
  - runs game server health checks

- `stage5` - optional botting workloads
  - optional GPU helper setup
  - deploys POE bot instances + control script
  - runs botting health checks

## Requirements

- Linux machine
- sudo-capable user
- Ansible and Git installed

Ubuntu/Debian quick install:

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y ansible git
ansible-galaxy collection install community.docker
```

## Secrets Workflow (Generate + Apply)

These scripts manage generated secrets for `group_vars/all/vars.yml`.

1) Generate local secrets file:

```bash
bash scripts/generate-values.sh
```

Creates `.generated-values.env` (gitignored).
If the file already exists, generation is blocked.

2) Intentionally regenerate:

```bash
bash scripts/generate-values.sh --overwrite
```

3) Apply by stage:

```bash
bash scripts/apply-generated-values.sh --stage 2
bash scripts/apply-generated-values.sh --stage 3
```

4) Apply specific keys:

```bash
bash scripts/apply-generated-values.sh --key samba_password,pihole_password
```

5) Apply all generated keys:

```bash
bash scripts/apply-generated-values.sh --all
```

Backups:
- `scripts/apply-generated-values.sh` creates `group_vars/all/vars.yml.bak.<timestamp>` before edits.

Revert:

```bash
bash scripts/apply-generated-values.sh --revert-last
bash scripts/apply-generated-values.sh --revert group_vars/all/vars.yml.bak.20260327091530
```

Manual Stage 3 values are still required:
- `domain`, `cloudflare_email`, `cloudflare_api_key`
- `traefik_basic_auth_hash`
- `google_mail`, `google_insecure_app_pass`
- `authelia_admin_mail`, `authelia_admin_argon2id_pass`
- optional: `tailscale_auth_key`

## Quick Start (Local Linux Host)

1) Clone:

```bash
git clone https://github.com/Micsushi/ansible_homelab.git
cd ansible_homelab
```

2) Set local inventory:

```ini
[homeserver]
localhost ansible_connection=local
```

3) Edit base values in `group_vars/all/vars.yml`:

```yaml
username: "your_linux_user"
puid: "1000"
pgid: "1000"
ip_address: "127.0.0.1"
timezone: "America/Denver"
domain: "homelab.local"
```

Notes:
- `username` should match `whoami`
- `puid`/`pgid` should match `id -u` and `id -g`
- `domain` can stay a placeholder until Stage 3

4) Generate/apply secrets:

```bash
bash scripts/generate-values.sh
bash scripts/apply-generated-values.sh --stage 2
```

5) Validate:

```bash
ansible -i inventory homeserver -m ping
ansible-playbook -i inventory playbooks/master.yml --syntax-check
```

Expected:
- ping returns `SUCCESS` and `"ping": "pong"`
- syntax-check ends with `playbook: playbooks/master.yml`

6) Run Stage 1:

```bash
ansible-playbook -i inventory playbooks/master.yml --tags stage1
```

7) Verify Docker access:

```bash
docker ps
```

If permission denied:

```bash
newgrp docker
docker ps
```

## GUI Apps (Optional, Stage 1)

1) Edit unsplit list in `group_vars/all/gui_apps.yml`:

```yaml
requested_gui_apps:
  - discord
  - steam
  - brave-browser
  - cursor
```

2) Auto-classify + enable GUI install:

```bash
bash scripts/prepare-gui-apps.sh
```

What it does:
- sets `install_gui_apps: true` in `group_vars/all/vars.yml`
- classifies apps to Snap or apt/dnf lists
- prints warnings for app names it cannot find
- creates a backup of `group_vars/all/gui_apps.yml`

3) Run Stage 1 again:

```bash
ansible-playbook -i inventory playbooks/master.yml --tags stage1
```

## Run Individual Stages

```bash
ansible-playbook -i inventory playbooks/master.yml --tags stage1
ansible-playbook -i inventory playbooks/master.yml --tags stage2
ansible-playbook -i inventory playbooks/master.yml --tags stage3
ansible-playbook -i inventory playbooks/master.yml --tags stage4
ansible-playbook -i inventory playbooks/master.yml --tags stage5
```

## Minimum Variables By Stage

Stage 1:
- `username`, `puid`, `pgid`, `timezone`, `docker_dir`, `data_dir`

Stage 2:
- `immich_postgres_password`
- `immich_typesense_api_key`
- `samba_password`
- `pihole_password`

Stage 3 (if enabled):
- `domain`
- `cloudflare_email`
- `cloudflare_api_key`
- `traefik_basic_auth_hash`
- `jwt_secret`
- `authelia_sqlite_encryption_key`
- `google_mail`
- `google_insecure_app_pass`
- `authelia_admin_mail`
- `authelia_admin_argon2id_pass`

Optional:
- `tailscale_auth_key`
- game/botting variables for Stages 4/5

## WSL2 Testing

1) Install WSL2 Ubuntu (PowerShell as Admin):

```powershell
wsl --install -d Ubuntu
```

2) Reboot if prompted, then launch:

```powershell
wsl -d Ubuntu
```

3) Confirm WSL:

```powershell
wsl --status
wsl -l -v
```

Expected:
- default version 2
- Ubuntu shows version 2

4) In Ubuntu, install prerequisites:

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y ansible git
ansible-galaxy collection install community.docker
```

5) Check systemd:

```bash
ps --no-headers -o comm 1
```

Expected: `systemd`

6) Use Linux-home repo copy (recommended):

```bash
cp -r /mnt/c/Users/<windows_user>/Documents/Github/ansible_homelab ~/ansible_homelab
cd ~/ansible_homelab
```

This avoids `/mnt/c/...` world-writable config warnings.

## Troubleshooting

- `--tags stage1` appears to do nothing:
  - ensure `playbooks/master.yml` uses `include_tasks` with `apply.tags`
- Docker permission denied:
  - run `newgrp docker`
- WSL line endings (`$'\r': command not found`):

```bash
sed -i 's/\r$//' scripts/generate-values.sh scripts/apply-generated-values.sh scripts/prepare-gui-apps.sh
```

- Dry run preview:

```bash
ansible-playbook -i inventory playbooks/master.yml --check
```

## License

WTFPL License - see `LICENSE.md`.

