# Ansible Homelab

Ansible playbooks to quickly setup a multifunctional home server on Ubuntu/Debian or Fedora/CentOS/RedHat.

## 📘 Documentation

**👉 [Complete Guide](COMPLETE_GUIDE.md)** - Everything you need: setup instructions, configuration, troubleshooting, step-by-step value generation, and optional game servers.

## 🚀 Quick Start

1. **Clone the repository:**
   ```bash
   git clone <your-repo-url>
   cd ansible_homelab
   ```

2. **Configure:**
   - Edit `inventory` with your server details
   - Edit `group_vars/all/vars.yml` with your configuration
   - See [Complete Guide](COMPLETE_GUIDE.md) for detailed instructions

3. **Run:**
   ```bash
   ansible-playbook master.yml
   ```

## What's Included

**Step 1:** System packages, Docker, GUI apps  
**Step 2:** Immich, Samba, Jellyfin, Pi-hole  
**Step 3:** Traefik, Authelia, Portainer, Monitoring, VPN, etc.

**Optional Steps 4 & 5:** Game servers and botting (see [Complete Guide](COMPLETE_GUIDE.md))

## Requirements

- Linux server (Ubuntu/Debian or Fedora/CentOS/RedHat)
- Ansible installed
- Sudo/root privileges

See [Complete Guide](COMPLETE_GUIDE.md) for full prerequisites and setup instructions.

## License

WTFPL License - see [LICENSE.md](LICENSE.md) for details.
