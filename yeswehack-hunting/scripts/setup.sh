#!/usr/bin/env bash
# Installs the standard open-source recon toolkit. Run once.
set -euo pipefail

echo "[*] Installing Go-based recon tools (requires Go >= 1.21)..."
if ! command -v go >/dev/null; then
  echo "Go not found. Install from https://go.dev/dl/ then re-run." >&2
  exit 1
fi

GO_TOOLS=(
  "github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest"
  "github.com/projectdiscovery/httpx/cmd/httpx@latest"
  "github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest"
  "github.com/projectdiscovery/katana/cmd/katana@latest"
  "github.com/projectdiscovery/dnsx/cmd/dnsx@latest"
  "github.com/lc/gau/v2/cmd/gau@latest"
  "github.com/tomnomnom/assetfinder@latest"
  "github.com/tomnomnom/waybackurls@latest"
)
for t in "${GO_TOOLS[@]}"; do
  echo "  -> go install $t"
  go install "$t"
done

echo "[*] Ensure \$(go env GOPATH)/bin is on your PATH."
echo "[*] Updating nuclei templates..."
nuclei -update-templates || true
echo "[*] Done."
