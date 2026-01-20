# Ansible Homelab - Multifunctional Home Server Setup

Ansible playbooks to quickly setup a multifunctional home server. These playbooks are designed to be run on a fresh install of Ubuntu/Debian or RedHat based distros (Fedora, CentOS).

The setup is organized into 5 modular steps that can be run independently or together:

- **Step 1**: Initial Setup (System packages, Docker, GUI apps)
- **Step 2**: Home Server Setup (Immich, Samba, Jellyfin, Pi-hole)
- **Step 3**: Monitoring and Security (Portainer, Prometheus, Grafana, VPN, etc.)
- **Step 4**: Game Servers (Minecraft, Project Zomboid, Valheim, Discord Bots)
- **Step 5**: Botting Server (Path of Exile instances with VNC control)

## 📖 Documentation

**For complete setup instructions, configuration details, and troubleshooting, see: [SETUP_GUIDE.md](SETUP_GUIDE.md)**

## 🚀 Quick Start

1. **Clone the repository:**
   ```bash
   git clone https://github.com/rishavnandi/ansible_homelab.git
   cd ansible_homelab
   ```

2. **Configure files:**
   - Edit `inventory` with your server details
   - Edit `group_vars/all/vars.yml` with your configuration

3. **Run the playbook:**
   ```bash
   # Run all steps
   ansible-playbook master.yml
   
   # Or run individual steps
   ansible-playbook master.yml --tags "step1"
   ```

**For detailed configuration instructions, see [SETUP_GUIDE.md](SETUP_GUIDE.md)**

## 📋 What's Included

### Step 1: Initial Setup
- System package updates
- Base tools (git, curl, python, pip, etc.)
- Docker and Docker Compose
- Optional GUI apps (Discord, Steam, Brave, Cursor)

### Step 2: Home Server
- **Immich** - Photo and video backup
- **Samba** - File sharing
- **Jellyfin** - Media server
- **Pi-hole** - DNS and ad blocker

### Step 3: Monitoring and Security
- **Traefik** - Reverse proxy with SSL
- **Authelia** - Two-factor authentication
- **Portainer** - Container management
- **Prometheus + Grafana** - Monitoring
- **Tailscale/Wireguard** - VPN
- **Uptime Kuma** - Uptime monitoring
- **Vaultwarden** - Password manager
- **TigerVNC** - Remote desktop
- **Coolify** - Deployment platform

### Step 4: Game Servers
- **Minecraft** - Java Edition server
- **Project Zomboid** - Dedicated server
- **Valheim** - Dedicated server
- **Discord Bot Runner** - Container for hosting Discord bots

### Step 5: Botting Server
- **Path of Exile Instances** - Multiple game instances with VNC remote control
- **Script Execution** - Run automation scripts in containers
- **GPU Passthrough** - Optional NVIDIA GPU support

**For detailed configuration and access information, see [SETUP_GUIDE.md](SETUP_GUIDE.md)**

## 📚 Documentation

**All configuration details, testing instructions, and troubleshooting are in [SETUP_GUIDE.md](SETUP_GUIDE.md)**

## 📝 Original Repository Features

This repository is based on the original [ansible_homelab](https://github.com/rishavnandi/ansible_homelab) with enhancements:

- ✅ Modular 5-step structure
- ✅ GUI app support
- ✅ Additional services (Immich, Samba, Pi-hole, Coolify, etc.)
- ✅ Improved documentation
- ✅ Better testing support

## 🤝 Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## 📄 License

This project is licensed under the WTFPL License - see [LICENSE.md](LICENSE.md) for details.

## 🙏 Credits

- [Jeff Geerling](https://www.jeffgeerling.com/) for awesome Ansible content
- [linuxserver.io](https://linuxserver.io/) for Docker containers
- [Ansible docs](https://docs.ansible.com/ansible/latest/) for documentation
- Original repository: [rishavnandi/ansible_homelab](https://github.com/rishavnandi/ansible_homelab)
