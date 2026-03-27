#!/usr/bin/env bash
# Sanity-check group_vars/all/vars_local.yml (does not print secret values).
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
F="${REPO_ROOT}/group_vars/all/vars_local.yml"

if [[ ! -f "${F}" ]]; then
  echo "Missing: ${F}"
  exit 1
fi

echo "File: ${F}"
echo ""

# YAML parse if PyYAML available
if python3 -c "import yaml" 2>/dev/null; then
  python3 -c "import yaml; yaml.safe_load(open('${F}')); print('YAML: OK')" || { echo "YAML: INVALID"; exit 1; }
else
  echo "YAML: skip (install python3-yaml to validate)"
fi

echo ""
echo "Keys present (values not shown):"
grep -E '^[a-zA-Z_][a-zA-Z0-9_]*:' "${F}" | cut -d: -f1 | sort -u

echo ""
echo "Stage 2 generated keys (expect non-empty quoted value):"
for k in immich_postgres_password immich_typesense_api_key samba_password pihole_password; do
  line="$(grep -E "^${k}:" "${F}" | head -1 || true)"
  if [[ -z "${line}" ]]; then
    echo "  ${k}: MISSING"
  else
    val="${line#*:}"
    val="${val//\"/}"
    val="${val// /}"
    len="${#val}"
    if [[ "${len}" -lt 8 ]]; then
      echo "  ${k}: TOO SHORT or empty (fix with apply-generated-values.sh)"
    else
      echo "  ${k}: OK"
    fi
  fi
done

echo ""
if grep -qE '<[^>]+>' "${F}" 2>/dev/null; then
  echo "Warning: angle-bracket placeholders found (replace with real values)."
else
  echo "No <placeholder> strings in file."
fi
