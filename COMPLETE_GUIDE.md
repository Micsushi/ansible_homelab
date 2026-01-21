# Complete Ansible Homelab Setup Guide

**Everything you need to set up your multifunctional home server with Ansible.**

This comprehensive guide combines all documentation into one place with step-by-step instructions, configuration details, troubleshooting, and more.

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [Quick Start](#quick-start)
3. [Prerequisites](#prerequisites)
4. [How to Get All Configuration Values](#how-to-get-all-configuration-values)
5. [Requirements Checklist](#requirements-checklist)
6. [Complete Setup Guide](#complete-setup-guide)
   - [Configuration](#configuration)
   - [Running the Steps](#running-the-steps)
   - [Testing Each Step](#testing-each-step)
   - [Service Details](#service-details)
   - [Troubleshooting](#troubleshooting)
   - [Advanced Configuration](#advanced-configuration)
7. [Step 4: Game Servers (Optional)](#step-4-game-servers-optional)
8. [Step 5: Botting Server (Optional)](#step-5-botting-server-optional)
9. [Quick Reference](#quick-reference)

---

## Overview

Ansible playbooks to quickly setup a multifunctional home server. These playbooks are designed to be run on a fresh install of Ubuntu/Debian or RedHat based distros (Fedora, CentOS).

The setup is organized into **3 modular steps** that can be run independently or together:

- **Step 1**: Initial Setup (System packages, Docker, GUI apps)
- **Step 2**: Home Server Setup (Immich, Samba, Jellyfin, Pi-hole)
- **Step 3**: Monitoring and Security (Portainer, Prometheus, Grafana, VPN, etc.)

### What's Included

#### Step 1: Initial Setup
- System package updates
- Base tools (git, curl, python, pip, etc.)
- Docker and Docker Compose
- Optional GUI apps (Discord, Steam, Brave, Cursor)

#### Step 2: Home Server
- **Immich** - Photo and video backup
- **Samba** - File sharing
- **Jellyfin** - Media server
- **Pi-hole** - DNS and ad blocker

#### Step 3: Monitoring and Security
- **Traefik** - Reverse proxy with SSL
- **Authelia** - Two-factor authentication
- **Portainer** - Container management
- **Prometheus + Grafana** - Monitoring
- **Tailscale/Wireguard** - VPN
- **Uptime Kuma** - Uptime monitoring
- **Vaultwarden** - Password manager
- **TigerVNC** - Remote desktop
- **Coolify** - Deployment platform

### Features

- ✅ Modular 3-step structure
- ✅ GUI app support
- ✅ Comprehensive home server services
- ✅ Monitoring and security tools
- ✅ Detailed documentation

---

## Quick Start

### 1. Clone or Download the Repository

```bash
git clone <your-repo-url>
cd ansible_homelab
```

### 2. Configure Files

- Edit `inventory` with your server details (see [Configuration](#configuration))
- Edit `group_vars/all/vars.yml` with your configuration (see [How to Get All Configuration Values](#how-to-get-all-configuration-values))

### 3. Run the Playbook

```bash
# Run all steps
ansible-playbook master.yml

# Or run individual steps
ansible-playbook master.yml --tags "step1"
```

**For detailed configuration instructions, continue reading this guide.**

---

## Prerequisites

### System Requirements

- ✅ **Linux Server**: Ubuntu/Debian or Fedora/CentOS/RedHat
- ✅ **Sudo/Root Privileges**: User must have sudo access
- ✅ **Internet Connection**: Server needs internet access

### Ansible Installation

**Option A: Running Ansible directly on the server (Recommended if you have direct access)**

- ✅ **Ansible Installed**: On the same machine you're configuring
  ```bash
  # Ubuntu/Debian
  sudo apt update && sudo apt install ansible
  
  # Fedora/CentOS/RedHat
  sudo dnf install ansible
  
  # Or via pip
  pip3 install ansible
  ```
- ✅ **No SSH needed**: Use `ansible_connection=local` in inventory

**Option B: Running Ansible from a remote machine**

- ✅ **Ansible Installed**: On your local machine (not the server)
  ```bash
  # Ubuntu/Debian
  sudo apt update && sudo apt install ansible
  
  # macOS
  brew install ansible
  
  # Or via pip
  pip3 install ansible
  ```
- ✅ **SSH Access**: Must be able to SSH into the server
- ✅ **SSH Key Pair** (recommended) or password authentication

---

## How to Get All Configuration Values

This section provides **exact step-by-step instructions** with commands to obtain every value needed for your Ansible homelab setup.

### Basic System Values

#### 1. **username**

**What it is:** Your Linux username on the server

**How to get it:**
```bash
whoami
```

**Example output:** `ubuntu`, `admin`, `michael`, etc.

**What to do:** Copy the output exactly as shown

---

#### 2. **puid** (User ID)

**What it is:** Your numeric user ID - ensures Docker containers have correct file permissions

**How to get it:**
```bash
id -u
```

**Example output:** `1000`

**What to do:** Copy the number (usually `1000` for first user)

---

#### 3. **pgid** (Group ID)

**What it is:** Your numeric group ID

**How to get it:**
```bash
id -g
```

**Example output:** `1000`

**What to do:** Copy the number (usually same as PUID)

**Quick way to get both:**
```bash
echo "PUID: $(id -u)"
echo "PGID: $(id -g)"
```

---

#### 4. **ip_address**

**What it is:** Your server's IP address

**How to get it:**

**Option A - Using hostname:**
```bash
hostname -I | awk '{print $1}'
```

**Option B - Using ip command:**
```bash
ip addr show | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}' | cut -d/ -f1 | head -1
```

**Option C - Simple method:**
```bash
ip route get 8.8.8.8 | awk '{print $7}' | head -1
```

**Example output:** `192.168.1.100` or `10.0.0.5`

**What to do:** Copy the IP address shown

---

#### 5. **timezone**

**What it is:** Your server's timezone in TZ database format

**How to get it:**

**Option A - Using timedatectl:**
```bash
timedatectl | grep "Time zone" | awk '{print $3}'
```

**Option B - Reading file:**
```bash
cat /etc/timezone
```

**Option C - Using date:**
```bash
ls -la /etc/localtime | sed 's|.*/zoneinfo/||'
```

**Example output:** `America/New_York`, `Europe/London`, `Asia/Tokyo`

**What to do:** Copy the timezone exactly as shown

**If you need to find your timezone:**
```bash
timedatectl list-timezones | grep -i "your_city"
# Examples:
timedatectl list-timezones | grep -i "new_york"
timedatectl list-timezones | grep -i "london"
```

---

#### 6. **domain**

**What it is:** Your domain name (required ONLY if using Traefik/Nginx Proxy Manager in Step 3)

**How to get it:**

**Option A - If you already own a domain:**
- Use your existing domain (e.g., `example.com`, `mydomain.net`)

**Option B - If you need to buy a domain:**
1. **Namecheap:** https://www.namecheap.com/domains/
2. **Cloudflare Registrar:** https://www.cloudflare.com/products/registrar/
3. **Google Domains:** https://domains.google/
4. **Porkbun:** https://porkbun.com/ (often cheapest)

**Cost:** Usually $10-15/year for a `.com` domain

**What to do:** 
- If you have one: Use it
- If you don't: Buy one and add it to Cloudflare (see Cloudflare setup below)

**Note:** 
- Domain is **optional** for Steps 1-2 - you can use `localhost` or skip it
- Domain is **required** ONLY if you're deploying Traefik or Nginx Proxy Manager in Step 3
- If you skip Traefik/NPM, you can access services directly via `http://your.server.ip:port` (no SSL)

---

### Step 2: Home Server Services

#### 7. **immich_postgres_password**

**What it is:** Password for Immich's PostgreSQL database

**How to generate:**
```bash
openssl rand -base64 32
```

**Example output:** `xK9mP2qL8nR4tY7vW1zA3bC5dE6fG8hJ0kM2nO4pQ6rS8tU=`

**What to do:** Copy the entire output (it's a long random string)

**Alternative (shorter):**
```bash
openssl rand -hex 24
```

---

#### 8. **immich_typesense_api_key**

**What it is:** API key for Immich's Typesense search engine

**How to generate:**
```bash
openssl rand -base64 32
```

**Example output:** `yL0nQ3rT9uV2wX5zB7cD9eF1gH3iJ5kL7mN9oP1qR3sT5uV=`

**What to do:** Copy the entire output

**Note:** This is just a random secret key - Immich will use it internally

---

#### 9. **samba_password**

**What it is:** Password for Samba file sharing

**How to generate:**
```bash
openssl rand -base64 32
```

**Example output:** `zM1oR4sU0vW3xY6aC8dF0gI2jK4lM6nO8pQ0rS2tU4vW6xY=`

**What to do:** Copy the entire output

**Note:** You'll use this password when connecting to Samba shares from other devices

---

#### 10. **pihole_password**

**What it is:** Admin password for Pi-hole web interface

**How to generate:**
```bash
openssl rand -base64 32
```

**Example output:** `aN2pS5tV1wX4yZ7bD9eG1hI3jL5mN7oP9qR1sT3uV5wX7yZ=`

**What to do:** Copy the entire output

**Alternative:** Use a memorable password (you'll type this in the web UI)

---

### Step 3: Monitoring & Security

#### 11. **cloudflare_email**

**What it is:** Email address for your Cloudflare account

**How to get it:**
- Use the email you used to sign up for Cloudflare
- Or sign up at: https://dash.cloudflare.com/sign-up

**Example:** `your.email@example.com`

**What to do:** Use your Cloudflare account email

---

#### 12. **cloudflare_api_key**

**What it is:** API token that allows Traefik to automatically get SSL certificates from Let's Encrypt via Cloudflare DNS challenge

**How to get it:**

**Step-by-step:**

1. **Log into Cloudflare:**
   - Go to: https://dash.cloudflare.com/login
   - Sign in with your account

2. **Navigate to API Tokens:**
   - Click your profile icon (top right)
   - Click **"My Profile"**
   - Click **"API Tokens"** in the left sidebar
   - Or go directly to: https://dash.cloudflare.com/profile/api-tokens

3. **Create Token:**
   - Click **"Create Token"**
   - Click **"Edit zone DNS"** template (recommended)
   - Or use **"Create Custom Token"** with these permissions:
     - **Zone** → **DNS** → **Edit**
     - **Zone** → **Zone** → **Read**

4. **Configure Token:**
   - **Token name:** `Traefik Homelab` (or any name)
   - **Permissions:** `Zone.DNS.Edit` and `Zone.Zone.Read`
   - **Zone Resources:** 
     - Select **"Include"** → **"Specific zone"**
     - Choose your domain from dropdown
   - **Client IP Address Filtering:** Leave blank (or add your server IP)
   - **TTL:** Leave default

5. **Create and Copy:**
   - Click **"Continue to summary"**
   - Review settings
   - Click **"Create Token"**
   - **IMPORTANT:** Copy the token immediately (starts with `...`)
   - You won't be able to see it again!

**Example format:** `abc123def456ghi789jkl012mno345pqr678stu901vwx234yz`

**What to do:** Copy the entire token string

**Security tip:** Store this securely - it has access to modify your DNS

---

#### 13. **traefik_basic_auth_hash**

**What it is:** Hashed password for Traefik dashboard basic authentication (protects the Traefik admin interface)

**How to generate:**

**Step 1 - Install htpasswd (if not installed):**
```bash
# Ubuntu/Debian
sudo apt update && sudo apt install -y apache2-utils

# Fedora/CentOS/RedHat
sudo dnf install -y httpd-tools
```

**Step 2 - Generate hash:**
```bash
htpasswd -nB admin
```

**What happens:**
- It will prompt: `New password:`
- Type your desired password (e.g., `MySecurePassword123!`)
- Press Enter
- It will prompt: `Re-type new password:`
- Type the same password again
- Press Enter

**Example output:**
```
admin:$2y$10$abcdefghijklmnopqrstuvwxyz1234567890ABCDEFGHIJKLMNOPQRSTUV
```

**What to do:** Copy the **entire line** including `admin:` prefix

**Note:** The `admin` part is the username - you can change it:
```bash
htpasswd -nB myusername
```

**Verify it works:**
```bash
# Test the hash
echo 'admin:$2y$10$...' | htpasswd -v -B - admin
# Enter password when prompted
```

---

#### 14. **jwt_secret**

**What it is:** Secret key for Authelia's JWT tokens

**How to generate:**
```bash
openssl rand -base64 32
```

**Example output:** `bO3qT6uW2xY5zA8cE0fH2iJ4kM6lN8oP0qR2sT4uW6xY8zA=`

**What to do:** Copy the entire output

**Note:** Must be at least 32 characters (this generates 44)

---

#### 15. **authelia_sqlite_encryption_key**

**What it is:** Encryption key for Authelia's SQLite database

**How to generate:**
```bash
openssl rand -base64 32
```

**Example output:** `cP4rU7vX3yZ6aB9dF1gI3jK5lM7nO1pR3sT5uW7xY9zA1b=`

**What to do:** Copy the entire output

**Note:** Must be at least 20 characters (this generates 44)

---

#### 16. **google_mail**

**What it is:** Your Gmail address for Authelia SMTP (password resets)

**How to get it:**
- Use your Gmail address
- Example: `yourname@gmail.com`

**What to do:** Enter your Gmail address

---

#### 17. **google_insecure_app_pass**

**What it is:** Google App Password for Gmail SMTP (16 characters)

**How to get it:**

**Step-by-step:**

1. **Enable 2-Factor Authentication:**
   - Go to: https://myaccount.google.com/security
   - Under **"Signing in to Google"**
   - Click **"2-Step Verification"**
   - Follow prompts to enable 2FA (if not already enabled)

2. **Generate App Password:**
   - Go to: https://myaccount.google.com/apppasswords
   - Or: Google Account → Security → 2-Step Verification → App passwords
   - **Select app:** Choose **"Mail"**
   - **Select device:** Choose **"Other (Custom name)"**
   - **Name:** Type `Authelia` (or any name)
   - Click **"Generate"**

3. **Copy Password:**
   - A 16-character password will appear
   - Format: `abcd efgh ijkl mnop` (with spaces)
   - **Copy it immediately** - you won't see it again!

**Example output:** `abcd efgh ijkl mnop` (remove spaces: `abcdefghijklmnop`)

**What to do:** Copy the 16 characters (you can remove spaces)

**Note:** This is different from your regular Gmail password

---

#### 18. **authelia_admin_mail**

**What it is:** Email address for Authelia admin user

**How to get it:**
- Use an email you control
- Can be your domain email: `admin@yourdomain.com`
- Or use your Gmail: `yourname@gmail.com`

**Example:** `admin@example.com`

**What to do:** Enter the email address

---

#### 19. **authelia_admin_argon2id_pass**

**What it is:** Argon2id hashed password for Authelia admin user

**How to generate:**

**Method 1 - Using Docker (Recommended):**
```bash
docker run --rm authelia/authelia:latest authelia hash-password 'YourSecurePassword123!'
```

**What happens:**
- Replace `'YourSecurePassword123!'` with your desired password
- Docker will download the image (first time only)
- It will output the hash

**Example output:**
```
$2argon2id$v=19$m=65536,t=3,p=4$abcdefghijklmnopqrstuvwxyz123456$morecharactershere...
```

**What to do:** Copy the **entire hash** (it's very long, starts with `$2argon2id$`)

**Method 2 - Using online tool (if Docker not available):**
- Go to: https://www.authelia.com/reference/guides/passwords/
- Use the online hash generator
- Enter your password
- Copy the Argon2id hash

**Important:** 
- Use a strong password
- Store the hash securely
- You'll use the **plain password** to log into Authelia web UI

---

#### 20. **tailscale_auth_key** (if using Tailscale)

**What it is:** Authentication key for Tailscale VPN

**How to get it:**

**Step-by-step:**

1. **Sign up for Tailscale:**
   - Go to: https://tailscale.com/
   - Click **"Sign Up"** (free tier available)
   - Sign in with Google, Microsoft, or GitHub

2. **Get Auth Key:**
   - Go to: https://login.tailscale.com/admin/settings/keys
   - Click **"Generate auth key"**
   - **Key description:** `Homelab Server` (or any name)
   - **Reusable:** 
     - ✅ **Reusable** = Key works multiple times (good for testing)
     - ❌ **Ephemeral** = One-time use (more secure)
   - **Preauthorize:** Leave unchecked (or check to auto-approve)
   - Click **"Generate key"**

3. **Copy Key:**
   - Key will appear (starts with `tskey-auth-`)
   - **Copy it immediately** - you won't be able to see it again!

**Example format:** `tskey-auth-abc123def456ghi789jkl012mno345pqr678stu901`

**What to do:** Copy the entire key string

**Note:** Free tier allows up to 100 devices

---

#### 21. **vnc_password**

**What it is:** Password for TigerVNC remote desktop

**How to generate:**
```bash
openssl rand -base64 32
```

**Example output:** `dQ5sV8wX4yZ7aC0eF2gI4jK6lM8nO2pR4sT6uW8xY0zA2b=`

**What to do:** Copy the entire output

**Alternative:** Use a memorable password (you'll type this in VNC client)

**Note:** VNC passwords are limited to 8 characters, so you might want:
```bash
openssl rand -base64 6 | tr -d "=+/" | cut -c1-8
```

---

#### 22. **coolify_postgres_password**

**What it is:** Password for Coolify's PostgreSQL database

**How to generate:**
```bash
openssl rand -base64 32
```

**Example output:** `eR6tW9xY5zA8bD1fG3hI5jL7mN9oP3qR5sT7uW9xY1zA3b=`

**What to do:** Copy the entire output

---

### Quick Password Generator

You can use the included script to generate all passwords at once:

```bash
./generate-values.sh
```

Or manually generate all passwords:

```bash
#!/bin/bash
echo "=== Ansible Homelab Password Generator ==="
echo ""
echo "Basic System:"
echo "  Username: $(whoami)"
echo "  PUID: $(id -u)"
echo "  PGID: $(id -g)"
echo "  IP: $(hostname -I | awk '{print $1}')"
echo "  Timezone: $(timedatectl | grep 'Time zone' | awk '{print $3}')"
echo ""
echo "Step 2 Passwords:"
echo "  Immich PostgreSQL: $(openssl rand -base64 32)"
echo "  Immich Typesense: $(openssl rand -base64 32)"
echo "  Samba: $(openssl rand -base64 32)"
echo "  Pi-hole: $(openssl rand -base64 32)"
echo ""
echo "Step 3 Secrets:"
echo "  JWT Secret: $(openssl rand -base64 32)"
echo "  SQLite Encryption Key: $(openssl rand -base64 32)"
echo "  VNC Password: $(openssl rand -base64 32)"
echo "  Coolify PostgreSQL: $(openssl rand -base64 32)"
echo ""
echo "=== Manual Steps Required ==="
echo "1. Traefik Basic Auth Hash: htpasswd -nB admin"
echo "2. Cloudflare API Token: https://dash.cloudflare.com/profile/api-tokens"
echo "3. Google App Password: https://myaccount.google.com/apppasswords"
echo "4. Authelia Admin Hash: docker run --rm authelia/authelia:latest authelia hash-password 'YourPassword'"
echo "5. Tailscale Auth Key: https://login.tailscale.com/admin/settings/keys"
echo ""
```

---

## Requirements Checklist

### Quick Start: Local vs Remote Execution

**If you have direct access to the server** (you're sitting at it or have a console):
- ✅ **Use local execution** - No SSH needed!
- ✅ Set `inventory` to: `localhost ansible_connection=local`
- ✅ Install Ansible on the server itself
- ✅ Much simpler setup!

**If you're running Ansible from a different machine**:
- ✅ Use SSH connection
- ✅ Configure SSH keys or password in `inventory`
- ✅ Install Ansible on your local machine

### Step-by-Step Checklist

1. **✅ Prerequisites**
   - [ ] Linux server ready
   - [ ] Ansible installed (on server for local, or on local machine for remote)
   - [ ] SSH access configured (if running remotely)

2. **✅ Basic Configuration**
   - [ ] Edit `inventory` with server connection details
   - [ ] Get username (`whoami`)
   - [ ] Get PUID/PGID from server (`id -u` and `id -g`)
   - [ ] Get IP address
   - [ ] Get timezone
   - [ ] (Optional) Get domain name

3. **✅ Step 2 Passwords** (if deploying Step 2)
   - [ ] Immich PostgreSQL password
   - [ ] Immich Typesense API key
   - [ ] Samba password
   - [ ] Pi-hole password

4. **✅ Step 3 Setup** (if deploying Step 3)
   - [ ] Cloudflare account + domain added
   - [ ] Cloudflare API token
   - [ ] Traefik basic auth hash
   - [ ] Authelia secrets (JWT, encryption key)
   - [ ] Google app password
   - [ ] Authelia admin password hash
   - [ ] VPN choice (Tailscale auth key OR Wireguard password)
   - [ ] VNC password
   - [ ] Coolify PostgreSQL password

### Configuration Template

After gathering all information, edit `group_vars/all/vars.yml`:

```yaml
# Basic Configuration
username: "ubuntu"  # Your username
puid: "1000"        # From: id -u
pgid: "1000"        # From: id -g
ip_address: "192.168.1.100"  # Your server IP
timezone: "America/New_York"  # Your timezone
domain: "example.com"  # Your domain (required for Step 3)

# Step 2 Passwords
immich_postgres_password: "paste_generated_password"
immich_typesense_api_key: "paste_generated_key"
samba_password: "paste_generated_password"
pihole_password: "paste_generated_password"

# Step 3 Configuration
cloudflare_email: "your@email.com"
cloudflare_api_key: "your_cloudflare_api_token"
traefik_basic_auth_hash: "admin:$2y$10$..."  # From htpasswd command
jwt_secret: "paste_generated_secret"
authelia_sqlite_encryption_key: "paste_generated_key"
google_mail: "your@gmail.com"
google_insecure_app_pass: "your_16_char_app_password"
authelia_admin_mail: "admin@yourdomain.com"
authelia_admin_argon2id_pass: "paste_argon2id_hash"
tailscale_auth_key: "tskey-auth-..."  # OR use wireguard_password
vnc_password: "paste_generated_password"
coolify_postgres_password: "paste_generated_password"
```

### Summary

**Minimum Required (Step 1 only):**
- **If running locally**: Just username, PUID, PGID, timezone (no SSH needed!)
- **If running remotely**: Server IP, SSH access, username, PUID, PGID, timezone

**For Step 2:**
- All Step 1 requirements +
- Immich passwords
- Samba password
- Pi-hole password

**For Step 3:**
- All Step 2 requirements +
- **Domain name** (required ONLY if using Traefik/Nginx Proxy Manager)
- Cloudflare account + API token (required ONLY if using Traefik)
- Traefik basic auth hash (required ONLY if using Traefik)
- Authelia secrets + Google app password (required ONLY if using Traefik + Authelia)
- VPN choice (Tailscale OR Wireguard) - optional
- VNC password - optional
- Coolify password - optional

**Note:** You can skip Traefik entirely and access services via `http://your.server.ip:port` if you don't need SSL or domain-based access.

---

## Complete Setup Guide

### Configuration

#### Step 1: Configure Inventory

Edit the `inventory` file with your server connection details:

**Option A: Local Execution (Recommended if you have direct access)**

```ini
[homeserver]
localhost ansible_connection=local
```

**Option B: Remote Execution via SSH**

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

#### Step 2: Configure Variables

Edit `group_vars/all/vars.yml` with your settings:

**Required Variables (Minimum)**

```yaml
# Basic Configuration
username: "ubuntu"  # Your server username
domain: "example.com"  # Your domain name
timezone: "America/New_York"  # Your timezone

# User IDs (run 'id' command on server to get these)
puid: "1000"  # User ID
pgid: "1000"  # Group ID
```

**Optional: GUI Apps Configuration**

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

**Step 2 Services Configuration**

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

**Step 3 Services Configuration**

```yaml
# Enable/disable Step 3 services
deploy_traefik: true              # Reverse proxy with automatic SSL (OPTIONAL)
deploy_authelia: true             # Authentication (only needed if using Traefik)
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

**What is Traefik and Why Do You Need It?**

Traefik is a **reverse proxy** that:
- **Routes requests** to the correct service (e.g., `immich.yourdomain.com` → Immich container)
- **Automatically manages SSL certificates** from Let's Encrypt (free HTTPS)
- **Provides a single entry point** - access all services through one domain instead of remembering IP:port combinations
- **Adds security features** like authentication, rate limiting, etc.

**Do You Need Traefik?**

**You DON'T need Traefik if:**
- ✅ You're okay accessing services via `http://your.server.ip:port` (no SSL)
- ✅ You don't need domain-based access (e.g., `immich.yourdomain.com`)
- ✅ You're running Steps 1-2 only (Traefik is in Step 3)

**You DO need Traefik if:**
- ✅ You want HTTPS/SSL encryption (secure connections)
- ✅ You want to access services via nice URLs like `https://immich.yourdomain.com`
- ✅ You want automatic SSL certificate management (no manual certificate setup)

**Alternative:** You can use **Nginx Proxy Manager** instead, which has a web UI and is easier to configure manually. Set `deploy_traefik: false` and `deploy_nginx_proxy_manager: true`.

**Traefik Configuration (Only if using Traefik)**

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

**Authelia Configuration (Required for Step 3)**

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

**VPN Configuration**

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

**VNC Configuration**

```yaml
deploy_vnc: true
vnc_password: "your_vnc_password"
vnc_resolution: "1920x1080"  # Adjust as needed
```

---

### Running the Steps

#### Run All Steps (1-3)

```bash
ansible-playbook master.yml
```

This will run all three steps in sequence.

#### Run Individual Steps

```bash
# Step 1: Initial Setup (System packages, Docker, GUI apps)
ansible-playbook master.yml --tags "step1"

# Step 2: Home Server (Immich, Samba, Jellyfin, Pi-hole)
# Note: Requires Step 1 to be completed first
ansible-playbook master.yml --tags "step1,step2"

# Step 3: Monitoring and Security
# Note: Requires Steps 1 and 2 to be completed first
ansible-playbook master.yml --tags "step1,step2,step3"
```

#### Run Specific Steps Only

```bash
# Just Step 1
ansible-playbook master.yml --tags "step1"

# Steps 1 and 2 (skip Step 3)
ansible-playbook master.yml --tags "step1,step2"
```

---

### Testing Each Step

#### Test Before Running (Dry Run)

Always test with `--check` first to see what would change:

```bash
# Test Step 1
ansible-playbook master.yml --tags "step1" --check

# Test all steps
ansible-playbook master.yml --check
```

#### Verify Step 1

After running Step 1, verify:

```bash
# SSH into your server (if remote) or run locally
ssh user@your.server.ip  # Skip if running locally

# Check Docker
docker --version
docker ps

# Check GUI apps (if enabled)
snap list
which brave-browser
ls -la /opt/cursor.AppImage
```

#### Verify Step 2

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

#### Verify Step 3

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

#### Health Checks

The playbook includes automatic health checks. You can also manually verify:

```bash
# Check if ports are listening
sudo netstat -tulpn | grep -E "80|443|8080|9000"

# Check Docker network
docker network ls | grep homelab

# Check container status
docker ps -a
```

---

### Service Details

#### Step 1 Services

| Service | Description | Access |
|---------|-------------|--------|
| Docker | Container runtime | `docker --version` |
| GUI Apps | Discord, Steam, Brave, Cursor | Desktop applications |

#### Step 2 Services

| Service | Description | Default Port | Access URL |
|---------|-------------|--------------|------------|
| Immich | Photo and video backup | 2283 | `https://immich.{{ domain }}` |
| Samba | File sharing | 445 | `\\server.ip\shared` |
| Jellyfin | Media server | 8096 | `https://jellyfin.{{ domain }}` |
| Pi-hole | DNS/ad blocker | 53, 80 | `https://pihole.{{ domain }}` |

#### Step 3 Services

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

---

### Troubleshooting

#### Common Issues

**"snapd not found" or Snap apps not installing**

**Solution:**
```bash
# The playbook should install snapd automatically, but if it fails:
sudo apt install snapd  # Ubuntu/Debian
sudo dnf install snapd  # Fedora

# Enable and start snapd
sudo systemctl enable snapd
sudo systemctl start snapd
```

**"Docker network 'homelab' not found"**

**Solution:** Step 1 creates the network. Make sure Step 1 completed successfully:
```bash
# Check if network exists
docker network ls | grep homelab

# If missing, create it manually
docker network create homelab
```

**"Traefik can't get SSL certificates"**

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

**"Services not accessible via domain"**

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

**"Container keeps restarting"**

**Solution:**
```bash
# Check container logs
docker logs container_name

# Check container status
docker ps -a

# Restart container
docker restart container_name
```

**"Permission denied" errors**

**Solution:**
```bash
# Verify PUID and PGID are correct
id -u  # Should match puid in vars.yml
id -g  # Should match pgid in vars.yml

# Fix ownership
sudo chown -R $USER:$USER /home/$USER/docker_apps
sudo chown -R $USER:$USER /home/$USER/data
```

**"htpasswd: command not found"**
```bash
# Ubuntu/Debian
sudo apt install apache2-utils

# Fedora/CentOS
sudo dnf install httpd-tools
```

**"openssl: command not found"**
```bash
# Usually pre-installed, but if missing:
sudo apt install openssl  # Ubuntu/Debian
sudo dnf install openssl # Fedora/CentOS
```

**"docker: command not found" (for Authelia hash)**
- Install Docker first, or
- Use online tool: https://www.authelia.com/reference/guides/passwords/

**Can't find timezone**
```bash
# List all timezones
timedatectl list-timezones

# Search for your city
timedatectl list-timezones | grep -i "new_york"
timedatectl list-timezones | grep -i "london"
```

#### Getting Help

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

---

### Advanced Configuration

#### Using Nginx Proxy Manager Instead of Traefik

If you prefer Nginx Proxy Manager:

```yaml
# In group_vars/all/vars.yml
deploy_traefik: false
deploy_authelia: false  # NPM has built-in auth
deploy_nginx_proxy_manager: true
```

Access NPM at `http://your.server.ip:81` and configure manually.

#### Customizing Service Ports

Edit the task files in `tasks/` directory to change port mappings:

```yaml
# Example: tasks/jellyfin.yml
ports:
  - "8096:8096"  # Change first number to map different host port
```

#### Adding Additional Services

1. Create new task file in `tasks/` directory
2. Follow pattern from existing task files
3. Add to appropriate step playbook (`step2_home_server.yml` or `step3_monitoring_security.yml`)
4. Add directory creation in step playbook
5. Add variables to `group_vars/all/vars.yml`

#### Skipping Services

Set deploy variable to `false` in `group_vars/all/vars.yml`:

```yaml
deploy_immich: false
deploy_samba: false
# etc.
```

---

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
- **Step Playbooks:** `step1_initial_setup.yml`, `step2_home_server.yml`, `step3_monitoring_security.yml`
- **Task Files:** `tasks/*.yml`
- **Data Directory:** `/home/{{ username }}/data`
- **Docker Apps:** `/home/{{ username }}/docker_apps`

### Finding Details

- **All configuration variables:** `group_vars/all/vars.yml`
- **Service task files:** `tasks/` directory
- **Step definitions:** `step1_initial_setup.yml`, `step2_home_server.yml`, `step3_monitoring_security.yml`
- **Main orchestration:** `master.yml`

### Verification Checklist

After generating all values, verify:

- [ ] All passwords are unique (no duplicates)
- [ ] Cloudflare API token copied (can't retrieve later)
- [ ] Google App Password copied (can't retrieve later)
- [ ] Tailscale auth key copied (can't retrieve later)
- [ ] Traefik hash includes username prefix (e.g., `admin:$2y$...`)
- [ ] Authelia hash is complete (very long string starting with `$2argon2id$`)
- [ ] All values stored securely (password manager recommended)

---

---

## Step 4: Game Servers (Optional)

This section covers optional game servers. These steps are completely optional and can be skipped if you don't need game servers.

**Note:** Step 4 requires Steps 1-3 to be completed first.

### Minecraft Server

Minecraft Java Edition server with support for multiple server types (Vanilla, Forge, Spigot, Paper, etc.) and RCON for remote administration.

#### Configuration

Add to `group_vars/all/vars.yml`:

```yaml
# Enable/disable Minecraft server
deploy_minecraft: true

# Minecraft Configuration
minecraft_version: "LATEST"  # or specific version like "1.20.1"
minecraft_type: "VANILLA"  # VANILLA, FORGE, SPIGOT, PAPER, etc.
minecraft_port: "25565"
minecraft_rcon_port: "25575"
minecraft_rcon_password: "<minecraft_rcon_password>"
minecraft_memory: "2G"
minecraft_max_memory: "4G"
minecraft_motd: "A Minecraft Server"
minecraft_server_name: "Minecraft Server"
minecraft_max_players: "20"
minecraft_online_mode: "true"
minecraft_difficulty: "normal"
minecraft_gamemode: "survival"
minecraft_pvp: "true"
minecraft_enable_rcon: "true"
```

#### How to Get Values

**minecraft_rcon_password:**
```bash
openssl rand -base64 32
```

#### Access Information

- **Game Port:** `your.server.ip:25565`
- **RCON Port:** `your.server.ip:25575`
- **World Data:** `{{ data_dir }}/games/minecraft`

#### Managing the Server

**View logs:**
```bash
docker logs minecraft
```

**Execute commands via RCON:**
```bash
# Using rcon-cli (install: npm install -g rcon-cli)
rcon-cli -H your.server.ip -P 25575 -p your_rcon_password <command>

# Or via Docker
docker exec minecraft rcon-cli <command>
```

**Stop/start server:**
```bash
docker stop minecraft
docker start minecraft
```

---

### Project Zomboid Server

Dedicated Project Zomboid server with support for mods and Steam Workshop items.

#### Configuration

Add to `group_vars/all/vars.yml`:

```yaml
# Enable/disable Project Zomboid server
deploy_project_zomboid: true

# Project Zomboid Configuration
project_zomboid_port: "16261"
project_zomboid_steam_port: "8766"
project_zomboid_steam_query_port: "8767"
project_zomboid_server_name: "Server"
project_zomboid_admin_password: "<project_zomboid_admin_password>"
project_zomboid_password: ""  # Leave empty for no password
project_zomboid_max_players: "32"
project_zomboid_pvp: "false"
project_zomboid_public: "false"
project_zomboid_public_name: "Project Zomboid Server"
project_zomboid_description: "A Project Zomboid Server"
project_zomboid_mods: ""  # Comma-separated mod IDs
project_zomboid_workshop_items: ""  # Comma-separated workshop item IDs
```

#### How to Get Values

**project_zomboid_admin_password:**
```bash
openssl rand -base64 32
```

**project_zomboid_password:**
- Leave empty (`""`) for public server
- Or generate: `openssl rand -base64 32`

#### Access Information

- **Game Port:** `your.server.ip:16261`
- **Steam Port:** `your.server.ip:8766`
- **Query Port:** `your.server.ip:8767`
- **Server Data:** `{{ data_dir }}/games/project-zomboid`

#### Managing the Server

**View logs:**
```bash
docker logs project-zomboid
```

**Access server console:**
```bash
docker exec -it project-zomboid bash
```

**Adding Mods:**

1. Find mod IDs from Steam Workshop
2. Add to `project_zomboid_mods` in `vars.yml`:
   ```yaml
   project_zomboid_mods: "123456,789012,345678"
   ```
3. Add workshop items:
   ```yaml
   project_zomboid_workshop_items: "111111,222222"
   ```
4. Redeploy: `ansible-playbook master.yml --tags "step4"`

---

### Valheim Server

Dedicated Valheim server with world persistence and password protection.

#### Configuration

Add to `group_vars/all/vars.yml`:

```yaml
# Enable/disable Valheim server
deploy_valheim: true

# Valheim Configuration
valheim_port: "2456"
valheim_query_port: "2457"
valheim_server_name: "My Valheim Server"
valheim_world_name: "Dedicated"
valheim_password: "<valheim_password>"
valheim_public: "1"  # 1 for public, 0 for private
```

#### How to Get Values

**valheim_password:**
```bash
openssl rand -base64 32
```

**Note:** Use a memorable password - players will need this to join your server.

#### Access Information

- **Game Port:** `your.server.ip:2456`
- **Query Port:** `your.server.ip:2457`
- **World Data:** `{{ data_dir }}/games/valheim`

#### Managing the Server

**View logs:**
```bash
docker logs valheim
```

**Connecting to Server:**

Players connect via Valheim client:
1. Start Valheim
2. Click "Join Game"
3. Enter server IP: `your.server.ip:2456`
4. Enter password when prompted

---

### Discord Bot Runner

Container-based system for running Discord bots. Supports both Node.js and Python bots.

#### Configuration

Add to `group_vars/all/vars.yml`:

```yaml
# Enable/disable Discord Bot Runner
deploy_discord_bot: true
```

#### Setup

1. **Create Bot Directory:**
   ```bash
   mkdir -p {{ data_dir }}/games/discord-bots/bots/<bot_name>
   ```

2. **Place Bot Files:**
   ```
   {{ data_dir }}/games/discord-bots/bots/my-bot/
   ├── package.json  # For Node.js bots
   # OR
   ├── requirements.txt  # For Python bots
   ├── index.js  # or main.py
   ├── .env  # Bot token and config
   └── ...  # Other bot files
   ```

3. **Create `.env` file:**
   ```bash
   DISCORD_TOKEN=your_bot_token_here
   ```

#### Getting Discord Bot Token

1. Go to: https://discord.com/developers/applications
2. Click "New Application"
3. Name your application
4. Go to "Bot" section
5. Click "Reset Token" → Copy token
6. Enable "Message Content Intent" if needed
7. Copy OAuth2 URL to invite bot to server

#### Usage

**List available bots:**
```bash
{{ docker_dir }}/discord-bot/discord-bot-runner.sh list
```

**Start a bot:**
```bash
{{ docker_dir }}/discord-bot/discord-bot-runner.sh start <bot_name>
```

**Stop a bot:**
```bash
{{ docker_dir }}/discord-bot/discord-bot-runner.sh stop <bot_name>
```

**View bot logs:**
```bash
docker logs discord-bot-<bot_name>
```

---

### Running Step 4

```bash
# Run Step 4 (requires Steps 1-3)
ansible-playbook master.yml --tags "step1,step2,step3,step4"
```

### Verify Step 4

```bash
# Check game servers are running
docker ps | grep -E "minecraft|project-zomboid|valheim|discord-bot"

# Check specific service
docker logs minecraft
docker logs project-zomboid
docker logs valheim
```

---

## Step 5: Botting Server (Optional)

This section covers optional botting server setup. This step is completely optional.

**Note:** Step 5 requires Steps 1-4 to be completed first.

### Path of Exile Instances

Multiple isolated Path of Exile instances with VNC remote control, script execution capabilities, and optional GPU passthrough.

#### Configuration

Add to `group_vars/all/vars.yml`:

```yaml
# Enable/disable Step 5 services
deploy_poe_instance1: true
deploy_poe_instance2: true
enable_gpu_passthrough: false  # Set to true if you have NVIDIA GPU

# Path of Exile Instance 1 Configuration
poe_instance1_vnc_password: "<poe_instance1_vnc_password>"

# Path of Exile Instance 2 Configuration
poe_instance2_vnc_password: "<poe_instance2_vnc_password>"
```

#### How to Get Values

**VNC Passwords:**

**Option 1 - Full length (recommended for security):**
```bash
openssl rand -base64 32
```

**Option 2 - 8 characters (VNC limit):**
```bash
openssl rand -base64 6 | tr -d "=+/" | cut -c1-8
```

**Note:** Use different passwords for each instance.

#### GPU Passthrough Setup

If you have an NVIDIA GPU and want to enable GPU passthrough:

1. **Install NVIDIA Drivers on Host:**
   ```bash
   # Ubuntu/Debian
   sudo apt update
   sudo apt install nvidia-driver-535  # or latest version
   sudo reboot
   ```

2. **Verify GPU:**
   ```bash
   nvidia-smi
   ```

3. **Set in vars.yml:**
   ```yaml
   enable_gpu_passthrough: true
   ```

4. **Redeploy Step 5:**
   ```bash
   ansible-playbook master.yml --tags "step5"
   ```

#### Access Information

**Instance 1:**
- **VNC Web Interface:** `http://your.server.ip:5901` or `https://poe1.{{ domain }}`
- **VNC Direct:** `vnc://your.server.ip:6001`
- **Password:** Use `poe_instance1_vnc_password` from vars.yml

**Instance 2:**
- **VNC Web Interface:** `http://your.server.ip:5902` or `https://poe2.{{ domain }}`
- **VNC Direct:** `vnc://your.server.ip:6002`
- **Password:** Use `poe_instance2_vnc_password` from vars.yml

#### Installing Path of Exile

1. **Access VNC:**
   - Open `https://poe1.{{ domain }}` in browser
   - Or use VNC client: `vnc://your.server.ip:6001`

2. **Enter Container:**
   ```bash
   docker exec -it poe-instance-1 bash
   ```

3. **Run Installation Script:**
   ```bash
   cd /root/poe
   bash scripts/install-poe.sh
   ```

#### Managing Instances

**Using Control Script:**

```bash
# Start instance
{{ docker_dir }}/botting/scripts/botting-control.sh 1 start

# Stop instance
{{ docker_dir }}/botting/scripts/botting-control.sh 1 stop

# Restart instance
{{ docker_dir }}/botting/scripts/botting-control.sh 1 restart

# Check status
{{ docker_dir }}/botting/scripts/botting-control.sh 1 status

# Get VNC connection info
{{ docker_dir }}/botting/scripts/botting-control.sh 1 vnc

# Enter container shell
{{ docker_dir }}/botting/scripts/botting-control.sh 1 exec
```

### Running Step 5

```bash
# Run Step 5 (requires Steps 1-4)
ansible-playbook master.yml --tags "step1,step2,step3,step4,step5"
```

### Verify Step 5

```bash
# Check botting instances are running
docker ps | grep -E "poe-instance"

# Check specific instance
docker logs poe-instance-1
docker logs poe-instance-2
```

### Game Server Troubleshooting

#### "Minecraft server won't start"

**Solutions:**
1. Check logs: `docker logs minecraft`
2. Verify EULA accepted (should be automatic)
3. Check memory allocation
4. Verify port is available: `sudo netstat -tulpn | grep 25565`

#### "Project Zomboid server not showing in server list"

**Solutions:**
1. Check if server is public: `project_zomboid_public: "true"`
2. Verify ports are open:
   ```bash
   sudo ufw allow 16261/udp
   sudo ufw allow 8766/udp
   sudo ufw allow 8767/udp
   ```
3. Check server logs: `docker logs project-zomboid`

#### "Valheim server password not working"

**Solutions:**
1. Verify password in vars.yml matches what players are using
2. Check server logs: `docker logs valheim`
3. Restart server: `docker restart valheim`

#### "POE instance VNC not accessible"

**Solutions:**
1. Check if container is running: `docker ps | grep poe-instance`
2. Verify VNC password in vars.yml
3. Check firewall: `sudo ufw allow 5901/tcp`
4. Check Traefik labels (if using domain)

#### "GPU passthrough not working"

**Solutions:**
1. Verify NVIDIA drivers installed: `nvidia-smi`
2. Check Docker GPU support: `docker run --rm --gpus all nvidia/cuda:11.0-base nvidia-smi`
3. Verify `enable_gpu_passthrough: true` in vars.yml
4. Restart Docker: `sudo systemctl restart docker`

---

## Next Steps

After completing Steps 1-3, you'll have a fully functional home server with:
- ✅ System setup and GUI apps
- ✅ Home server services (photos, files, media, DNS)
- ✅ Monitoring and security

**Optional:** Steps 4 & 5 add game servers and botting capabilities (see sections above).

For questions or issues, check the logs and verify your configuration matches this guide.

---

## Contributing

Contributions are welcome! When contributing:

- Search for existing Issues and PRs before creating your own
- Follow the existing code style and patterns
- Include documentation for new features
- Test your changes before submitting
- Use descriptive commit messages

For major changes, it's best to open an Issue first to discuss your proposal.

## License

This project is licensed under the WTFPL License - see [LICENSE.md](LICENSE.md) for details.

## Credits

- [Jeff Geerling](https://www.jeffgeerling.com/) for awesome Ansible content
- [linuxserver.io](https://linuxserver.io/) for Docker containers
- [Ansible docs](https://docs.ansible.com/ansible/latest/) for documentation
