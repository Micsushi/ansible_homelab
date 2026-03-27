# Services Explained (Simple Terms)

This guide explains what each service task is for, in plain language, and why you might want it in a homelab.

## Core setup tasks

These are not user-facing apps, but they are important.

- `docker.yml`: installs and configures Docker so most other services can run as containers.  
  Why have it: it gives you a consistent way to run, update, and isolate services.
- `essential.yml`: installs base packages and common tools.  
  Why have it: it makes the host predictable and easier to manage.
- `add_ownership.yml`: fixes file/folder ownership for your user.  
  Why have it: it prevents permission issues with mounted volumes and app data.

## Stage 2 home-server services

- `immich.yml`: self-hosted photo/video backup and gallery (similar to Google Photos).  
  Why have it: private photo backup with local control.
- `samba.yml`: SMB file sharing for Windows/macOS/Linux clients.  
  Why have it: simple network drives for shared files.
- `jellyfin.yml`: media server for movies, TV, and music.  
  Why have it: stream your own media without subscriptions.
- `pihole.yml`: DNS sinkhole that blocks ads/trackers.  
  Why have it: network-wide ad blocking and DNS visibility.

## Stage 3 monitoring, security, and access

- `traefik.yml`: reverse proxy that routes domains to internal services.  
  Why have it: one clean entry point for many apps.
- `authelia.yml`: authentication/SSO layer in front of services.  
  Why have it: centralized login and better security.
- `portainer.yml`: Docker web UI for containers, images, and stacks.  
  Why have it: easier container management than CLI only.
- `monitoring.yml`: Prometheus + Grafana stack for metrics and dashboards.  
  Why have it: see resource usage, trends, and failures quickly.
- `tailscale.yml`: private mesh VPN using WireGuard under the hood.  
  Why have it: easy secure remote access from anywhere.
- `wireguard.yml`: self-hosted WireGuard VPN server.  
  Why have it: full control over your own VPN endpoint.
- `nginx_proxy_manager.yml`: GUI-based reverse proxy and TLS manager.  
  Why have it: easier proxy setup if you prefer GUI over Traefik.
- `uptime_kuma.yml`: endpoint and service uptime monitoring.  
  Why have it: fast alerting when something goes down.
- `vaultwarden.yml`: lightweight Bitwarden-compatible password manager.  
  Why have it: keep passwords under your own control.
- `tigervnc.yml`: remote desktop access via VNC.  
  Why have it: remote GUI access for machines/apps that need desktop control.
- `coolify.yml`: self-hosted app/platform deployment tool.  
  Why have it: easier app deployments and management workflows.

## Stage 4 game services

- `minecraft.yml`: Minecraft dedicated server.  
  Why have it: persistent world under your control.
- `project_zomboid.yml`: Project Zomboid dedicated server.  
  Why have it: always-on multiplayer host for your group.
- `valheim.yml`: Valheim dedicated server.  
  Why have it: stable co-op server without relying on one player's PC.
- `discord_bot.yml`: container runtime for Discord bots.  
  Why have it: keep automation/moderation bots always online.

## Stage 5 botting workloads

- `poe_botting.yml`: Path of Exile botting/container instances with VNC access.  
  Why have it: isolate multi-instance workloads and manage them independently.

## Extra app tasks available in `playbooks/tasks`

These tasks exist in the repo and can be used as your stack grows.

- `nextcloud.yml`: self-hosted files, sync, and collaboration suite.  
  Why have it: private cloud storage and document workflows.
- `radarr.yml`: movie library automation.  
  Why have it: automates movie acquisition and organization.
- `jellyseerr.yml`: media request portal for users.  
  Why have it: lets family/friends request content cleanly.
- `guacamole.yml`: browser-based remote desktop gateway (RDP/VNC/SSH).  
  Why have it: remote access through a browser.
- `code_server.yml`: VS Code in the browser.  
  Why have it: remote development environment.
- `unmanic.yml`: media library optimizer/transcoder automation.  
  Why have it: reduces storage and improves playback compatibility.
- `filebrowser.yml`: web file manager for server files.  
  Why have it: quick file operations from browser.
- `watchtower.yml`: auto-update running containers.  
  Why have it: reduces manual patching work (use carefully).
- `sonarr.yml`: TV show automation.  
  Why have it: automates series tracking and organization.
- `dashdot.yml`: simple server stats dashboard.  
  Why have it: quick at-a-glance host health.
- `n8n.yml`: workflow automation platform.  
  Why have it: build automations between apps/services.
- `duplicati.yml`: encrypted backups to local/cloud targets.  
  Why have it: scheduled recoverable backups.
- `syncthing.yml`: peer-to-peer file sync across devices.  
  Why have it: private sync without central cloud.
- `heimdall.yml`: homelab start page/dashboard.  
  Why have it: one place to launch all services.
- `qbittorrent.yml`: torrent client service.  
  Why have it: managed downloads on the server.
- `requestrr.yml`: request content through Discord.  
  Why have it: simpler requests for Discord users.
- `homarr.yml`: modern dashboard/start page alternative.  
  Why have it: customizable service portal.
- `prowlarr.yml`: indexer manager for *arr apps.  
  Why have it: central indexer config for Radarr/Sonarr.

## Quick guidance

- Start minimal: Stage 2 + only one remote-access method (Tailscale or WireGuard).
- Add security early if exposing anything externally: `traefik` + `authelia` (or equivalent).
- Add monitoring before your stack gets large: `monitoring` + `uptime_kuma`.
- Keep backups in scope once data services are live: `duplicati`, plus tested restore steps.
