#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
# Secrets live here (gitignored). Ansible merges group_vars/all/*.yml; vars_local.yml sorts after vars.yml and overrides.
VARS_LOCAL="${REPO_ROOT}/group_vars/all/vars_local.yml"
GEN_FILE="${REPO_ROOT}/.generated-values.env"

usage() {
  cat <<'EOF'
Usage:
  bash scripts/apply-generated-values.sh --stage 2
  bash scripts/apply-generated-values.sh --stage 3
  bash scripts/apply-generated-values.sh --stage 2 --stage 3
  bash scripts/apply-generated-values.sh --key samba_password,pihole_password
  bash scripts/apply-generated-values.sh --all
  bash scripts/apply-generated-values.sh --revert-last
  bash scripts/apply-generated-values.sh --revert group_vars/all/vars_local.yml.bak.<timestamp>

Secrets are written to group_vars/all/vars_local.yml (gitignored), not vars.yml.

Options:
  --stage <2|3>      Apply all generated keys for a stage (repeatable)
  --key <csv>        Apply specific key(s), comma separated
  --all              Apply all generated keys
  --revert-last      Restore the most recent vars_local backup
  --revert <file>    Restore a specific vars_local backup file
EOF
}

if [[ ! -f "${GEN_FILE}" ]]; then
  echo "Error: generated values file not found at ${GEN_FILE}"
  echo "Run: bash scripts/generate-values.sh"
  exit 1
fi

declare -a STAGE2_KEYS=(
  immich_postgres_password
  immich_typesense_api_key
  samba_password
  pihole_password
)

declare -a STAGE3_KEYS=(
  jwt_secret
  authelia_sqlite_encryption_key
  vnc_password
  coolify_postgres_password
)

declare -a SELECTED_KEYS=()
APPLY_ALL=false
REVERT_LAST=false
REVERT_FILE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --stage)
      shift
      [[ $# -gt 0 ]] || { echo "Missing value for --stage"; usage; exit 1; }
      case "$1" in
        2) SELECTED_KEYS+=("${STAGE2_KEYS[@]}") ;;
        3) SELECTED_KEYS+=("${STAGE3_KEYS[@]}") ;;
        *) echo "Unsupported stage: $1 (use 2 or 3)"; exit 1 ;;
      esac
      ;;
    --key)
      shift
      [[ $# -gt 0 ]] || { echo "Missing value for --key"; usage; exit 1; }
      IFS=',' read -r -a _keys <<< "$1"
      for k in "${_keys[@]}"; do
        SELECTED_KEYS+=("$(echo "${k}" | xargs)")
      done
      ;;
    --all)
      APPLY_ALL=true
      ;;
    --revert-last)
      REVERT_LAST=true
      ;;
    --revert)
      shift
      [[ $# -gt 0 ]] || { echo "Missing value for --revert"; usage; exit 1; }
      REVERT_FILE="$1"
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      usage
      exit 1
      ;;
  esac
  shift
done

if [[ "${REVERT_LAST}" == "true" || -n "${REVERT_FILE}" ]]; then
  if [[ "${REVERT_LAST}" == "true" && -n "${REVERT_FILE}" ]]; then
    echo "Use either --revert-last or --revert <file>, not both."
    exit 1
  fi

  if [[ "${REVERT_LAST}" == "true" ]]; then
    latest_backup="$(ls -1t "${VARS_LOCAL}.bak."* 2>/dev/null | head -n 1 || true)"
    if [[ -z "${latest_backup}" ]]; then
      echo "No backup files found matching ${VARS_LOCAL}.bak.*"
      exit 1
    fi
    cp "${latest_backup}" "${VARS_LOCAL}"
    echo "Reverted ${VARS_LOCAL} from latest backup:"
    echo "  ${latest_backup}"
    exit 0
  fi

  if [[ ! -f "${REVERT_FILE}" ]]; then
    echo "Backup file not found: ${REVERT_FILE}"
    exit 1
  fi
  cp "${REVERT_FILE}" "${VARS_LOCAL}"
  echo "Reverted ${VARS_LOCAL} from backup:"
  echo "  ${REVERT_FILE}"
  exit 0
fi

if [[ "${APPLY_ALL}" == "true" ]]; then
  SELECTED_KEYS=("${STAGE2_KEYS[@]}" "${STAGE3_KEYS[@]}")
fi

if [[ ${#SELECTED_KEYS[@]} -eq 0 ]]; then
  echo "No keys selected."
  usage
  exit 1
fi

# Deduplicate selected keys
declare -A seen=()
declare -a keys=()
for k in "${SELECTED_KEYS[@]}"; do
  if [[ -n "${k}" && -z "${seen[$k]+x}" ]]; then
    seen[$k]=1
    keys+=("${k}")
  fi
done

mkdir -p "$(dirname "${VARS_LOCAL}")"

if [[ ! -f "${VARS_LOCAL}" ]]; then
  cat > "${VARS_LOCAL}" <<'HEADER'
---
# Local secrets — applied by scripts/apply-generated-values.sh
# This file is gitignored. Do not commit.
HEADER
fi

backup_file="${VARS_LOCAL}.bak.$(date +%Y%m%d%H%M%S)"
cp "${VARS_LOCAL}" "${backup_file}"

escape_sed() {
  printf '%s' "$1" | sed -e 's/[\/&]/\\&/g'
}

updated=0
for key in "${keys[@]}"; do
  value="$(
    awk -F'=' -v k="${key}" '
      $1==k {
        gsub(/^"/, "", $2);
        gsub(/"$/, "", $2);
        print $2;
      }
    ' "${GEN_FILE}" | head -n 1
  )"
  if [[ -z "${value}" ]]; then
    echo "Warning: key not found in generated file: ${key}"
    continue
  fi

  escaped_value="$(escape_sed "${value}")"

  if grep -qE "^${key}:" "${VARS_LOCAL}"; then
    sed -i -E "s|^(${key}: ).*$|\1\"${escaped_value}\"|" "${VARS_LOCAL}"
  else
    echo "${key}: \"${value}\"" >> "${VARS_LOCAL}"
  fi
  updated=$((updated + 1))
done

echo "Updated ${updated} values in ${VARS_LOCAL}"
echo "Backup created at ${backup_file}"
echo "Source file: ${GEN_FILE}"
