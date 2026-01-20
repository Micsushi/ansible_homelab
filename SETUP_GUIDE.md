# Complete Setup Guide - Multifunctional Home Server

This guide covers everything you need to configure, start, and test your home server setup using the modular 5-step Ansible playbooks.

## 📋 Table of Contents

1. [Prerequisites](#prerequisites)
2. [Configuration](#configuration)
3. [Running the Steps](#running-the-steps)
4. [Testing Each Step](#testing-each-step)
5. [Service Details](#service-details)
6. [Troubleshooting](#troubleshooting)
7. [Advanced Configuration](#advanced-configuration)

## Prerequisites

### System Requirements
- Ubuntu/Debian or Fedora/CentOS/RedHat Linux
- SSH access to the server
- Sudo/root privileges
- Ansible installed on your local machine

### Install Ansible (if not already installed)
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install ansible

# macOS
brew install ansible

# Or via pip
pip3 install ansible
```

## Configuration

### Step 1: Configure Inventory

Edit the `inventory` file with your server connection details:

```ini
[homeserver]
192.168.1.100  # Your server IP address

[homeserver:vars]
ansible_user = ubuntu  # Your SSH username
ansible_ssh_private_key_file = ~/.ssh/id_rsa  # Path to your SSH key
```

**If using password instead of SSH key:**
```ini
[homeserver:vars]
ansible_user = ubuntu
ansible_ssh_pass = your_password
```

### Step 2: Configure Variables

Edit `group_vars/all/vars.yml` with your settings:

#### Required Variables (Minimum)

```yaml
# Basic Configuration
username: "ubuntu"  # Your server username
domain: "example.com"  # Your domain name
timezone: "America/New_York"  # Your timezone

# User IDs (run 'id' command on server to get these)
puid: "1000"  # User ID
pgid: "1000"  # Group ID
```

#### Optional: GUI Apps Configuration

```yaml
# Enable GUI app installation (Step 1)
install_gui_apps: true  # Set to false for headless servers

# Snap packages (Discord, Steam)
gui_snap_packages:
  - discord
  - steam

# APT/DNF packages (Brave, Cursor)
gui_packages:
  - brave-browser
  - cursor
```

**Note:** GUI apps require a desktop environment. For headless servers, set `install_gui_apps: false`.

#### Step 2 Services Configuration

```yaml
# Enable/disable Step 2 services
deploy_immich: true      # Photo storage
deploy_samba: true       # File sharing
deploy_jellyfin: true    # Media server
deploy_pihole: true      # DNS/ad blocker

# Service passwords
immich_postgres_password: "your_secure_password"
samba_password: "your_secure_password"
pihole_password: "your_secure_password"
```

#### Step 3 Services Configuration

```yaml
# Enable/disable Step 3 services
deploy_traefik: true              # Reverse proxy (REQUIRED)
deploy_authelia: true             # Authentication (REQUIRED for Traefik)
deploy_portainer: true            # Container management
deploy_monitoring: true            # Prometheus + Grafana
deploy_uptime_kuma: true          # Uptime monitoring
deploy_vaultwarden: true          # Password manager
deploy_vnc: true                  # Remote desktop
deploy_coolify: true              # Deployment platform

# VPN - Choose ONE
deploy_tailscale: false           # Tailscale VPN
deploy_wireguard: false           # Wireguard VPN

# Reverse Proxy - Choose ONE
deploy_nginx_proxy_manager: false # Nginx Proxy Manager (alternative to Traefik)
```

#### Traefik Configuration (Required for Step 3)

If using Traefik (recommended), you need:

1. **Cloudflare Account:**
   - Create account at https://dash.cloudflare.com
   - Add your domain
   - Create API token with "Edit zone DNS" permissions
   - Get token from: https://dash.cloudflare.com/profile/api-tokens

2. **Add to `group_vars/all/vars.yml`:**
```yaml
cloudflare_email: "your@email.com"
cloudflare_api_key: "your_cloudflare_api_token"
```

3. **Generate Traefik Basic Auth Hash:**
```bash
# Install htpasswd if needed
sudo apt install apache2-utils  # Ubuntu/Debian
sudo dnf install httpd-tools   # Fedora

# Generate hash
htpasswd -nB admin
# Enter password when prompted, copy the output
```

4. **Add to `group_vars/all/vars.yml`:**
```yaml
traefik_basic_auth_hash: "admin:$2y$10$..."  # Paste the output here
```

#### Authelia Configuration (Required for Step 3)

If using Authelia (recommended with Traefik):

1. **Generate Secrets:**
```bash
# JWT Secret (random string, up to 64 characters)
openssl rand -base64 32

# SQLite Encryption Key (at least 20 characters)
openssl rand -base64 32
```

2. **Generate Admin Password Hash:**
```bash
# Using Docker (easiest method)
docker run --rm authelia/authelia:latest authelia hash-password 'YourPassword'
# Copy the output
```

Or follow: https://www.authelia.com/reference/guides/passwords/

3. **Set up Google SMTP (for password resets):**
   - Enable 2FA on your Google account
   - Generate app password: https://myaccount.google.com/apppasswords
   - Copy the 16-character password

4. **Add to `group_vars/all/vars.yml`:**
```yaml
jwt_secret: "your_jwt_secret_here"
authelia_sqlite_encryption_key: "your_encryption_key_here"
google_mail: "your@gmail.com"
google_insecure_app_pass: "your_16_char_app_password"
authelia_admin_mail: "admin@yourdomain.com"
authelia_admin_argon2id_pass: "your_argon2id_hash_here"
```

#### VPN Configuration

**For Tailscale:**
1. Create account at https://tailscale.com
2. Get auth key from: https://login.tailscale.com/admin/settings/keys
3. Add to `group_vars/all/vars.yml`:
```yaml
deploy_tailscale: true
tailscale_auth_key: "tskey-auth-..."
```

**For Wireguard:**
```yaml
deploy_wireguard: true
wg_password: "your_wireguard_password"
```

#### VNC Configuration

```yaml
deploy_vnc: true
vnc_password: "your_vnc_password"
vnc_resolution: "1920x1080"  # Adjust as needed
```

#### Step 4 Services Configuration (Game Servers)

```yaml
# Enable/disable Step 4 services
deploy_minecraft: true
deploy_project_zomboid: true
deploy_valheim: true
deploy_discord_bot: true

# Minecraft Configuration
minecraft_version: "LATEST"  # or specific version like "1.20.1"
minecraft_type: "VANILLA"  # VANILLA, FORGE, SPIGOT, PAPER, etc.
minecraft_port: "25565"
minecraft_rcon_port: "25575"
minecraft_rcon_password: "your_rcon_password"
minecraft_memory: "2G"
minecraft_max_memory: "4G"
minecraft_motd: "A Minecraft Server"
minecraft_max_players: "20"
minecraft_difficulty: "normal"
minecraft_gamemode: "survival"
minecraft_pvp: "true"

# Project Zomboid Configuration
project_zomboid_port: "16261"
project_zomboid_steam_port: "8766"
project_zomboid_steam_query_port: "8767"
project_zomboid_server_name: "Server"
project_zomboid_admin_password: "your_admin_password"
project_zomboid_password: ""  # Leave empty for no password
project_zomboid_max_players: "32"
project_zomboid_pvp: "false"
project_zomboid_public: "false"

# Valheim Configuration
valheim_port: "2456"
valheim_query_port: "2457"
valheim_server_name: "My Valheim Server"
valheim_world_name: "Dedicated"
valheim_password: "your_server_password"
valheim_public: "1"  # 1 for public, 0 for private
```

#### Step 5 Services Configuration (Botting Server)

```yaml
# Enable/disable Step 5 services
deploy_poe_instance1: true
deploy_poe_instance2: true
enable_gpu_passthrough: false  # Set to true if you have NVIDIA GPU

# Path of Exile Instance 1 Configuration
poe_instance1_vnc_password: "your_vnc_password"

# Path of Exile Instance 2 Configuration
poe_instance2_vnc_password: "your_vnc_password"
```

**Note:** For GPU passthrough, you need an NVIDIA GPU and must install NVIDIA drivers on the host system before running Step 5.

## Running the Steps

### Run All Steps (1-5)

```bash
ansible-playbook master.yml
```

This will run all five steps in sequence.

### Run Individual Steps

```bash
# Step 1: Initial Setup (System packages, Docker, GUI apps)
ansible-playbook master.yml --tags "step1"

# Step 2: Home Server (Immich, Samba, Jellyfin, Pi-hole)
# Note: Requires Step 1 to be completed first
ansible-playbook master.yml --tags "step1,step2"

# Step 3: Monitoring and Security
# Note: Requires Steps 1 and 2 to be completed first
ansible-playbook master.yml --tags "step1,step2,step3"

# Step 4: Game Servers
# Note: Requires Steps 1-3 to be completed first
ansible-playbook master.yml --tags "step1,step2,step3,step4"

# Step 5: Botting Server
# Note: Requires Steps 1-4 to be completed first
ansible-playbook master.yml --tags "step1,step2,step3,step4,step5"
```

### Run Specific Steps Only

```bash
# Just Step 1
ansible-playbook master.yml --tags "step1"

# Steps 1 and 2 (skip Step 3)
ansible-playbook master.yml --tags "step1,step2"

# Steps 1-4 (skip Step 5)
ansible-playbook master.yml --tags "step1,step2,step3,step4"
```

## Testing Each Step

### Test Before Running (Dry Run)

Always test with `--check` first to see what would change:

```bash
# Test Step 1
ansible-playbook master.yml --tags "step1" --check

# Test all steps
ansible-playbook master.yml --check
```

### Verify Step 1

After running Step 1, verify:

```bash
# SSH into your server
ssh user@your.server.ip

# Check Docker
docker --version
docker ps

# Check GUI apps (if enabled)
snap list
which brave-browser
ls -la /opt/cursor.AppImage
```

### Verify Step 2

```bash
# Check services are running
docker ps | grep -E "immich|samba|jellyfin|pihole"

# Check specific service
docker logs immich_server
docker logs samba
docker logs jellyfin
docker logs pihole
```

**Access URLs:**
- Immich: `https://immich.{{ domain }}`
- Jellyfin: `https://jellyfin.{{ domain }}`
- Pi-hole: `https://pihole.{{ domain }}`
- Samba: `\\your.server.ip\shared` (Windows) or `smb://your.server.ip/shared` (Mac/Linux)

### Verify Step 3

```bash
# Check services are running
docker ps | grep -E "traefik|authelia|portainer|prometheus|grafana|uptime|vaultwarden|coolify"

# Check specific service
docker logs traefik
docker logs authelia
docker logs portainer
```

**Access URLs:**
- Traefik Dashboard: `https://traefik.{{ domain }}`
- Authelia: `https://auth.{{ domain }}`
- Portainer: `https://portainer.{{ domain }}`
- Grafana: `https://grafana.{{ domain }}`
- Uptime Kuma: `https://uptime.{{ domain }}`
- Vaultwarden: `https://vault.{{ domain }}`
- Coolify: `https://coolify.{{ domain }}`

### Verify Step 4

```bash
# Check game servers are running
docker ps | grep -E "minecraft|project-zomboid|valheim|discord-bot"

# Check specific service
docker logs minecraft
docker logs project-zomboid
docker logs valheim
```

**Access Information:**
- **Minecraft:** Connect via Minecraft client to `your.server.ip:25565`
- **Project Zomboid:** Connect via game client to `your.server.ip:16261`
- **Valheim:** Connect via game client to `your.server.ip:2456`
- **Discord Bots:** Use the bot runner script (see Discord Bot section below)

**Discord Bot Runner:**
```bash
# List available bots
{{ docker_dir }}/discord-bot/discord-bot-runner.sh list

# Start a bot
{{ docker_dir }}/discord-bot/discord-bot-runner.sh start <bot_name>

# Stop a bot
{{ docker_dir }}/discord-bot/discord-bot-runner.sh stop <bot_name>
```

### Verify Step 5

```bash
# Check botting instances are running
docker ps | grep -E "poe-instance"

# Check specific instance
docker logs poe-instance-1
docker logs poe-instance-2

# Access VNC
# Instance 1: http://your.server.ip:5901 or https://poe1.{{ domain }}
# Instance 2: http://your.server.ip:5902 or https://poe2.{{ domain }}
```

**Access Information:**
- **VNC Web Interface:** `http://your.server.ip:5901` (Instance 1) or `http://your.server.ip:5902` (Instance 2)
- **VNC via Traefik:** `https://poe1.{{ domain }}` (Instance 1) or `https://poe2.{{ domain }}` (Instance 2)
- **Direct VNC:** Use VNC client to connect to `your.server.ip:6001` (Instance 1) or `your.server.ip:6002` (Instance 2)

**Botting Control Script:**
```bash
# Control instances
{{ docker_dir }}/botting/scripts/botting-control.sh 1 start
{{ docker_dir }}/botting/scripts/botting-control.sh 1 stop
{{ docker_dir }}/botting/scripts/botting-control.sh 1 status
{{ docker_dir }}/botting/scripts/botting-control.sh 1 vnc
{{ docker_dir }}/botting/scripts/botting-control.sh 1 exec  # Enter container shell
```

### Health Checks

The playbook includes automatic health checks. You can also manually verify:

```bash
# Check if ports are listening
sudo netstat -tulpn | grep -E "80|443|8080|9000"

# Check Docker network
docker network ls | grep homelab

# Check container status
docker ps -a
```

## Service Details

### Step 1 Services

| Service | Description | Access |
|---------|-------------|--------|
| Docker | Container runtime | `docker --version` |
| GUI Apps | Discord, Steam, Brave, Cursor | Desktop applications |

### Step 2 Services

| Service | Description | Default Port | Access URL |
|---------|-------------|--------------|------------|
| Immich | Photo and video backup | 2283 | `https://immich.{{ domain }}` |
| Samba | File sharing | 445 | `\\server.ip\shared` |
| Jellyfin | Media server | 8096 | `https://jellyfin.{{ domain }}` |
| Pi-hole | DNS/ad blocker | 53, 80 | `https://pihole.{{ domain }}` |

### Step 3 Services

| Service | Description | Default Port | Access URL |
|---------|-------------|--------------|------------|
| Traefik | Reverse proxy | 80, 443 | `https://traefik.{{ domain }}` |
| Authelia | Authentication | 9091 | `https://auth.{{ domain }}` |
| Portainer | Container management | 9000 | `https://portainer.{{ domain }}` |
| Prometheus | Metrics collection | 9090 | Internal only |
| Grafana | Metrics visualization | 3000 | `https://grafana.{{ domain }}` |
| Uptime Kuma | Uptime monitoring | 3001 | `https://uptime.{{ domain }}` |
| Vaultwarden | Password manager | 80 | `https://vault.{{ domain }}` |
| TigerVNC | Remote desktop | 5901 | VNC client |
| Coolify | Deployment platform | 8000 | `https://coolify.{{ domain }}` |
| Tailscale/Wireguard | VPN | Various | VPN client |

### Step 4 Services

| Service | Description | Default Port | Access Method |
|---------|-------------|--------------|---------------|
| **Minecraft** | Java Edition server | 25565 | Minecraft client |
| **Minecraft RCON** | Remote console | 25575 | RCON client |
| **Project Zomboid** | Dedicated server | 16261 | Game client |
| **Valheim** | Dedicated server | 2456 | Game client |
| **Discord Bot Runner** | Bot container manager | N/A | Script-based |

### Step 5 Services

| Service | Description | Default Port | Access Method |
|---------|-------------|--------------|---------------|
| **POE Instance 1 VNC** | Path of Exile instance 1 | 5901 (web), 6001 (direct) | VNC client or web browser |
| **POE Instance 2 VNC** | Path of Exile instance 2 | 5902 (web), 6002 (direct) | VNC client or web browser |

## Troubleshooting

### Common Issues

#### "snapd not found" or Snap apps not installing

**Solution:**
```bash
# The playbook should install snapd automatically, but if it fails:
sudo apt install snapd  # Ubuntu/Debian
sudo dnf install snapd  # Fedora

# Enable and start snapd
sudo systemctl enable snapd
sudo systemctl start snapd
```

#### "Docker network 'homelab' not found"

**Solution:** Step 1 creates the network. Make sure Step 1 completed successfully:
```bash
# Check if network exists
docker network ls | grep homelab

# If missing, create it manually
docker network create homelab
```

#### "Traefik can't get SSL certificates"

**Solutions:**
1. Verify Cloudflare API token has correct permissions (DNS Edit)
2. Check DNS records point to your server IP:
   ```bash
   dig yourdomain.com
   ```
3. Review Traefik logs:
   ```bash
   docker logs traefik
   ```
4. Verify Cloudflare email and API key in `group_vars/all/vars.yml`

#### "Services not accessible via domain"

**Solutions:**
1. Check if Traefik is running:
   ```bash
   docker ps | grep traefik
   ```
2. Verify DNS records:
   ```bash
   dig subdomain.yourdomain.com
   ```
3. Check firewall allows ports 80 and 443:
   ```bash
   sudo ufw status
   sudo ufw allow 80/tcp
   sudo ufw allow 443/tcp
   ```
4. Check Traefik labels on containers:
   ```bash
   docker inspect container_name | grep -A 20 Labels
   ```

#### "Container keeps restarting"

**Solution:**
```bash
# Check container logs
docker logs container_name

# Check container status
docker ps -a

# Restart container
docker restart container_name
```

#### "Permission denied" errors

**Solution:**
```bash
# Verify PUID and PGID are correct
id -u  # Should match puid in vars.yml
id -g  # Should match pgid in vars.yml

# Fix ownership
sudo chown -R $USER:$USER /home/$USER/docker_apps
sudo chown -R $USER:$USER /home/$USER/data
```

### Getting Help

1. **Check Logs:**
   ```bash
   docker logs <container_name>
   ```

2. **Verify Configuration:**
   ```bash
   ansible-playbook master.yml --check --tags "step1"
   ```

3. **Review Ansible Output:**
   Run with verbose mode:
   ```bash
   ansible-playbook master.yml -v  # -vv or -vvv for more detail
   ```

4. **Check Service Status:**
   ```bash
   docker ps -a
   systemctl status docker
   ```

## Advanced Configuration

### Using Nginx Proxy Manager Instead of Traefik

If you prefer Nginx Proxy Manager:

```yaml
# In group_vars/all/vars.yml
deploy_traefik: false
deploy_authelia: false  # NPM has built-in auth
deploy_nginx_proxy_manager: true
```

Access NPM at `http://your.server.ip:81` and configure manually.

### Customizing Service Ports

Edit the task files in `tasks/` directory to change port mappings:

```yaml
# Example: tasks/jellyfin.yml
ports:
  - "8096:8096"  # Change first number to map different host port
```

### Adding Additional Services

1. Create new task file in `tasks/` directory
2. Follow pattern from existing task files
3. Add to appropriate step playbook (`step2_home_server.yml` or `step3_monitoring_security.yml`)
4. Add directory creation in step playbook
5. Add variables to `group_vars/all/vars.yml`

### Skipping Services

Set deploy variable to `false` in `group_vars/all/vars.yml`:

```yaml
deploy_immich: false
deploy_samba: false
# etc.
```

## Quick Reference

### Essential Commands

```bash
# Run all steps
ansible-playbook master.yml

# Run specific step
ansible-playbook master.yml --tags "step1"

# Test without making changes
ansible-playbook master.yml --check

# Check Docker containers
docker ps

# Check container logs
docker logs <container_name>

# Restart container
docker restart <container_name>

# Check service status
systemctl status docker
```

### File Locations

- **Configuration:** `group_vars/all/vars.yml`
- **Inventory:** `inventory`
- **Main Playbook:** `master.yml`
- **Step Playbooks:** `step1_initial_setup.yml`, `step2_home_server.yml`, `step3_monitoring_security.yml`, `step4_game_servers.yml`, `step5_botting.yml`
- **Task Files:** `tasks/*.yml`
- **Data Directory:** `/home/{{ username }}/data`
- **Docker Apps:** `/home/{{ username }}/docker_apps`

### Finding Details

- **All configuration variables:** `group_vars/all/vars.yml`
- **Service task files:** `tasks/` directory
- **Step definitions:** `step1_initial_setup.yml`, `step2_home_server.yml`, `step3_monitoring_security.yml`, `step4_game_servers.yml`, `step5_botting.yml`
- **Main orchestration:** `master.yml`

## Step 4: Game Servers Details

### Minecraft Server

**Configuration:**
- Supports multiple server types: VANILLA, FORGE, SPIGOT, PAPER, etc.
- RCON enabled for remote administration
- Configurable memory allocation
- World data stored in `{{ data_dir }}/games/minecraft`

**Managing the Server:**
```bash
# View logs
docker logs minecraft

# Execute commands via RCON
# Use an RCON client or:
docker exec minecraft rcon-cli <command>

# Stop/start server
docker stop minecraft
docker start minecraft
```

### Project Zomboid Server

**Configuration:**
- Supports mods and workshop items
- Admin password required for server management
- Server data stored in `{{ data_dir }}/games/project-zomboid`

**Managing the Server:**
```bash
# View logs
docker logs project-zomboid

# Access server console
docker exec -it project-zomboid bash
```

### Valheim Server

**Configuration:**
- World name and server name configurable
- Password protection available
- Server data stored in `{{ data_dir }}/games/valheim`

**Managing the Server:**
```bash
# View logs
docker logs valheim

# Access server files
ls -la {{ data_dir }}/games/valheim
```

### Discord Bot Runner

**Setup:**
1. Place your bot files in `{{ data_dir }}/games/discord-bots/bots/<bot_name>/`
2. Bot should have either:
   - `package.json` (Node.js bot)
   - `requirements.txt` (Python bot)
3. Create `.env` file with `DISCORD_TOKEN=your_token`

**Usage:**
```bash
# List bots
{{ docker_dir }}/discord-bot/discord-bot-runner.sh list

# Start bot
{{ docker_dir }}/discord-bot/discord-bot-runner.sh start <bot_name>

# Stop bot
{{ docker_dir }}/discord-bot/discord-bot-runner.sh stop <bot_name>
```

## Step 5: Botting Server Details

### Path of Exile Instances

**Features:**
- Multiple isolated instances
- VNC remote control for each instance
- Script execution capabilities
- Optional GPU passthrough for better performance

**Accessing Instances:**
1. **Via Web Browser:** `https://poe1.{{ domain }}` or `https://poe2.{{ domain }}`
2. **Via VNC Client:** Connect to `your.server.ip:6001` (Instance 1) or `your.server.ip:6002` (Instance 2)
3. **Password:** Use the VNC password from `group_vars/all/vars.yml`

**Installing Path of Exile:**
```bash
# SSH into server, then:
docker exec -it poe-instance-1 bash
cd /root/poe
bash scripts/install-poe.sh
```

**Running Bot Scripts:**
1. Place your bot scripts in `{{ data_dir }}/botting/poe-instance-<number>/scripts/`
2. Make scripts executable: `chmod +x script.sh`
3. Run via control script:
```bash
{{ docker_dir }}/botting/scripts/botting-control.sh 1 exec
# Then inside container:
bash /root/scripts/your-bot-script.sh
```

**GPU Passthrough (Optional):**
If you have an NVIDIA GPU:
1. Install NVIDIA drivers on host system first
2. Set `enable_gpu_passthrough: true` in `group_vars/all/vars.yml`
3. Run Step 5 again

**Managing Instances:**
```bash
# Start instance
{{ docker_dir }}/botting/scripts/botting-control.sh 1 start

# Stop instance
{{ docker_dir }}/botting/scripts/botting-control.sh 1 stop

# Check status
{{ docker_dir }}/botting/scripts/botting-control.sh 1 status

# Access container shell
{{ docker_dir }}/botting/scripts/botting-control.sh 1 exec
```

## Next Steps

After completing all 5 steps, you'll have a fully functional multifunctional home server with:
- ✅ System setup and GUI apps
- ✅ Home server services (photos, files, media, DNS)
- ✅ Monitoring and security
- ✅ Game servers (Minecraft, Project Zomboid, Valheim)
- ✅ Discord bot hosting
- ✅ Game botting with remote control

For questions or issues, check the logs and verify your configuration matches this guide.
