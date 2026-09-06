#!/usr/bin/env bash
# js-analysis.sh <target-name> — download in-scope JS and extract endpoints,
# parameters, and *candidate* secret patterns for a human to review.
# Read-only fetches of already-public assets. Does NOT validate/use any secret.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
NAME="${1:?usage: js-analysis.sh <target-name>}"
OUT="$ROOT/targets/$NAME/recon"
JS="$OUT/js.txt"; DL="$OUT/js_files"; mkdir -p "$DL"
[ -f "$JS" ] || { echo "Run recon.sh first (no js.txt)"; exit 1; }

echo "[*] Downloading $(wc -l < "$JS") JS files..."
i=0
while read -r u; do
  [ -z "$u" ] && continue
  i=$((i+1))
  curl -sL --max-time 20 -A "bugbounty-recon" "$u" -o "$DL/$i.js" || true
done < "$JS"

echo "[*] Extracting endpoint/path candidates..."
grep -rhoE '"(/[a-zA-Z0-9_?&=./-]{2,})"' "$DL" 2>/dev/null | tr -d '"' | sort -u > "$OUT/js_endpoints.txt" || true
grep -rhoE '(https?://[a-zA-Z0-9._/-]+)'  "$DL" 2>/dev/null | sort -u > "$OUT/js_urls.txt" || true

echo "[*] Flagging CANDIDATE secret patterns (review manually)..."
grep -rEno \
  -e 'AKIA[0-9A-Z]{16}' \
  -e 'AIza[0-9A-Za-z_-]{35}' \
  -e 'ghp_[0-9A-Za-z]{36}' \
  -e 'xox[baprs]-[0-9A-Za-z-]{10,}' \
  -e '(?i)(api[_-]?key|secret|token|password)["'\'' :=]{1,3}[0-9A-Za-z_-]{12,}' \
  "$DL" 2>/dev/null > "$OUT/js_secret_candidates.txt" || true

echo "[+] endpoints=$(wc -l < "$OUT/js_endpoints.txt" 2>/dev/null||echo 0)" \
     "urls=$(wc -l < "$OUT/js_urls.txt" 2>/dev/null||echo 0)" \
     "secret_candidates=$(wc -l < "$OUT/js_secret_candidates.txt" 2>/dev/null||echo 0)"
echo "    NOTE: secret candidates are leads only. Do not use any credential —"
echo "    report exposure per program rules if confirmed sensitive."
