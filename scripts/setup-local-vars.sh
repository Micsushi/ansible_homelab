#!/usr/bin/env bash
# Interactive first-time setup for group_vars/all/vars_local.yml
# Run this once on the control node (WSL or Linux) before your first playbook run.
#
# What it does:
#   1. Generates random secrets (.generated-values.env) if not already done
#   2. Asks for your server's IP address
#   3. Asks for Immich admin email / name / password (used for auto-setup)
#   4. Asks for Jellyfin admin password (used for auto-setup)
#   5. Writes/merges everything into group_vars/all/vars_local.yml (gitignored)
#   6. Prints a summary (no passwords printed)
#
# Re-run to update individual values (it only overwrites what you answer; skip with Enter).
# To rotate generated secrets: bash scripts/generate-values.sh --overwrite
#                               then re-run this script.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
GEN_FILE="${REPO_ROOT}/.generated-values.env"
LOCAL="${REPO_ROOT}/group_vars/all/vars_local.yml"

# ── colours (off if not a TTY) ─────────────────────────────────────────────
if [[ -t 1 ]]; then
  BOLD=$'\e[1m'; RESET=$'\e[0m'; GRN=$'\e[32m'; YEL=$'\e[33m'; RED=$'\e[31m'
else
  BOLD=''; RESET=''; GRN=''; YEL=''; RED=''
fi

banner() { echo; echo "${BOLD}=== $* ===${RESET}"; echo; }
ok()     { echo "${GRN}  ✓ $*${RESET}"; }
warn()   { echo "${YEL}  ! $*${RESET}"; }
err()    { echo "${RED}  ✗ $*${RESET}"; }

# ── helpers ────────────────────────────────────────────────────────────────
# Read a non-empty value from stdin; show default in brackets.
# Usage: prompt_val "Label" "current_or_default" -> sets $REPLY_VAL
prompt_val() {
  local label="$1" default="$2"
  local disp; disp="${default:+(current: ${default:0:4}…)}"
  [[ -z "$default" ]] && disp="(currently empty — will be skipped if blank)"
  printf '%s %s\n> ' "${BOLD}${label}${RESET}" "$disp"
  read -r raw
  REPLY_VAL="${raw:-$default}"
}

# Read a password (hidden); show "set" or "empty" for current value.
# Usage: prompt_pass "Label" "current_value" -> sets $REPLY_VAL
prompt_pass() {
  local label="$1" cur="$2"
  local disp; [[ -n "$cur" ]] && disp="(currently set — press Enter to keep)" || disp="(currently empty)"
  printf '%s %s\n> ' "${BOLD}${label}${RESET}" "$disp"
  read -rs raw; echo
  REPLY_VAL="${raw:-$cur}"
}

# Write or update a key: value pair in $LOCAL
set_local_key() {
  local key="$1" val="$2"
  [[ -z "$val" ]] && return          # skip empty
  if grep -qE "^${key}:" "${LOCAL}" 2>/dev/null; then
    sed -i -E "s|^${key}:.*|${key}: \"${val}\"|" "${LOCAL}"
  else
    echo "${key}: \"${val}\"" >> "${LOCAL}"
  fi
}

# Read current value of a key from $LOCAL (strips quotes)
get_local_key() {
  local key="$1"
  grep -E "^${key}:" "${LOCAL}" 2>/dev/null | head -1 | sed -E 's/^[^:]+: *"?([^"]*)"?$/\1/'
}

# ── ensure vars_local.yml exists ───────────────────────────────────────────
mkdir -p "$(dirname "${LOCAL}")"
if [[ ! -f "${LOCAL}" ]]; then
  cat > "${LOCAL}" <<'HDR'
---
# Local secrets and private overrides — applied by scripts/setup-local-vars.sh
# This file is gitignored. Do not commit.
HDR
  ok "Created ${LOCAL}"
fi

# ── Step 1: generated secrets ──────────────────────────────────────────────
banner "Step 1 of 4 — Generated Secrets"

if [[ -f "${GEN_FILE}" ]]; then
  ok ".generated-values.env already exists. Skipping generation."
  echo "   To rotate secrets: bash scripts/generate-values.sh --overwrite"
else
  echo "Running scripts/generate-values.sh ..."
  bash "${SCRIPT_DIR}/generate-values.sh"
  ok "Secrets generated."
fi

echo ""
echo "Applying Stage 2 generated secrets to ${LOCAL} ..."
bash "${SCRIPT_DIR}/apply-generated-values.sh" --stage 2
ok "Stage 2 secrets written to vars_local.yml."

# ── Step 2: network / host identity ────────────────────────────────────────
banner "Step 2 of 4 — Network / Host Identity"

cur_ip="$(get_local_key ip_address)"
[[ -z "$cur_ip" ]] && cur_ip="$(get_local_key ip_address || true)"
# fallback: try to detect LAN IP automatically
detected_ip="$(hostname -I 2>/dev/null | awk '{print $1}' || true)"

echo "Your server's LAN IP (used by Jellyfin auto-discovery and Samba)."
[[ -n "$detected_ip" ]] && echo "  Detected: ${detected_ip}"
prompt_val "ip_address" "${cur_ip:-${detected_ip}}"
set_local_key "ip_address" "${REPLY_VAL}"
ok "ip_address set."

# ── Step 3: Immich admin account ───────────────────────────────────────────
banner "Step 3 of 4 — Immich Admin Account"
echo "Used by the auto-setup task to bootstrap the first Immich admin user."
echo "Leave blank to skip (you will complete setup manually in the Immich web UI)."
echo ""

cur_email="$(get_local_key immich_admin_email)"
cur_name="$(get_local_key immich_admin_name)"
cur_pass="$(get_local_key immich_admin_password)"

prompt_val "Immich admin email" "${cur_email}"
set_local_key "immich_admin_email" "${REPLY_VAL}"

prompt_val "Immich admin name (display name)" "${cur_name}"
set_local_key "immich_admin_name" "${REPLY_VAL}"

prompt_pass "Immich admin password" "${cur_pass}"
set_local_key "immich_admin_password" "${REPLY_VAL}"

if [[ -n "$(get_local_key immich_admin_email)" && -n "$(get_local_key immich_admin_password)" ]]; then
  ok "Immich admin credentials set."
else
  warn "Immich admin credentials incomplete — auto-setup will be skipped. Complete in the web UI at :2283."
fi

# ── Step 4: Jellyfin admin account ─────────────────────────────────────────
banner "Step 4 of 4 — Jellyfin Admin Account"
echo "Used by the auto-setup task to create the first Jellyfin admin."
echo "Leave blank to skip (you will complete setup manually in the Jellyfin web UI)."
echo ""

cur_jf_pass="$(get_local_key jellyfin_admin_password)"

prompt_pass "Jellyfin admin password" "${cur_jf_pass}"
set_local_key "jellyfin_admin_password" "${REPLY_VAL}"

if [[ -n "$(get_local_key jellyfin_admin_password)" ]]; then
  ok "Jellyfin admin password set."
else
  warn "Jellyfin admin password empty — auto-setup will be skipped. Complete in the web UI at :8096."
fi

# ── Summary ────────────────────────────────────────────────────────────────
banner "Summary"
echo "vars_local.yml keys:"
grep -E '^[a-zA-Z_][a-zA-Z0-9_]*:' "${LOCAL}" | cut -d: -f1 | sort -u | while read -r k; do
  val="$(get_local_key "$k")"
  if [[ -z "$val" ]]; then
    warn "$k  (empty)"
  else
    ok "$k  (set)"
  fi
done

echo ""
echo "File: ${LOCAL}"
echo ""
echo "${BOLD}Next step:${RESET}"
echo "  ansible-playbook -i inventory.local playbooks/master.yml --tags stage2 -K"
echo ""
echo "Dry run first:"
echo "  ansible-playbook -i inventory.local playbooks/master.yml --tags stage2 --check -K"
