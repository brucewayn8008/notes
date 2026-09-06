#!/usr/bin/env bash
# recon.sh <target-name> — in-scope recon pipeline.
# Reads roots from targets/<name>/scope.yaml (in_scope.wildcards + hosts),
# enumerates subdomains, then FILTERS everything back through scope-check.py
# before any host is probed. Output lands in targets/<name>/recon/.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
NAME="${1:?usage: recon.sh <target-name>}"
TDIR="$ROOT/targets/$NAME"
SCOPE="$TDIR/scope.yaml"
OUT="$TDIR/recon"
[ -f "$SCOPE" ] || { echo "No scope.yaml at $SCOPE" >&2; exit 1; }
mkdir -p "$OUT"
SC="python3 $ROOT/scripts/scope-check.py $SCOPE"

echo "[*] Extracting apex roots from scope..."
python3 - "$SCOPE" > "$OUT/roots.txt" <<'PY'
import sys, yaml
d = yaml.safe_load(open(sys.argv[1])) or {}
inc = d.get("in_scope", {}) or {}
roots = set()
for w in inc.get("wildcards", []) or []:
    roots.add(w.lstrip("*."))
for h in inc.get("hosts", []) or []:
    roots.add(h)
print("\n".join(sorted(roots)))
PY
echo "    roots: $(wc -l < "$OUT/roots.txt")"

echo "[*] Passive subdomain enumeration (subfinder + assetfinder)..."
: > "$OUT/subs_raw.txt"
while read -r r; do
  [ -z "$r" ] && continue
  subfinder -silent -d "$r"        >> "$OUT/subs_raw.txt" 2>/dev/null || true
  assetfinder --subs-only "$r"     >> "$OUT/subs_raw.txt" 2>/dev/null || true
done < "$OUT/roots.txt"
sort -u "$OUT/subs_raw.txt" | $SC > "$OUT/subs_inscope.txt" 2>>"$OUT/scope.log"
echo "    in-scope subs: $(wc -l < "$OUT/subs_inscope.txt")"

echo "[*] Probing liveness (httpx)..."
httpx -silent -l "$OUT/subs_inscope.txt" \
      -status-code -title -tech-detect -web-server -ip \
      -json -o "$OUT/httpx.jsonl" 2>/dev/null || true
httpx -silent -l "$OUT/subs_inscope.txt" > "$OUT/live.txt" 2>/dev/null || true
echo "    live hosts: $(wc -l < "$OUT/live.txt" 2>/dev/null || echo 0)"

echo "[*] Historical URLs (gau + waybackurls), scope-filtered..."
{ cat "$OUT/live.txt" | gau 2>/dev/null; cat "$OUT/subs_inscope.txt" | waybackurls 2>/dev/null; } \
  | sort -u | $SC > "$OUT/urls.txt" 2>>"$OUT/scope.log" || true
echo "    urls: $(wc -l < "$OUT/urls.txt" 2>/dev/null || echo 0)"

echo "[*] Crawling live hosts (katana, in-scope only)..."
katana -silent -list "$OUT/live.txt" -jc -d 3 2>/dev/null \
  | $SC >> "$OUT/urls.txt" 2>>"$OUT/scope.log" || true
sort -u -o "$OUT/urls.txt" "$OUT/urls.txt"

echo "[*] Collecting JS files for analysis..."
grep -Ei '\.js(\?|$)' "$OUT/urls.txt" | sort -u > "$OUT/js.txt" || true
echo "    js files: $(wc -l < "$OUT/js.txt" 2>/dev/null || echo 0)"

echo "[*] Non-intrusive nuclei pass (exposures/misconfig/tech; NO fuzzing)..."
nuclei -silent -l "$OUT/live.txt" \
       -tags exposure,misconfiguration,tech,cve \
       -severity low,medium,high,critical \
       -rl 30 -c 20 \
       -o "$OUT/nuclei.txt" 2>/dev/null || true
echo "    nuclei hits: $(wc -l < "$OUT/nuclei.txt" 2>/dev/null || echo 0)"

echo "[+] Recon complete -> $OUT"
echo "    Next: run /triage to rank leads."
