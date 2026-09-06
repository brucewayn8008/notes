# Recon checklist (wide-scope programs)

- [ ] Enumerate ALL apex roots from scope.yaml before starting.
- [ ] Passive subs (subfinder/assetfinder) -> scope-check -> httpx liveness.
- [ ] Bucket live hosts by tech/title (httpx.jsonl). Flag: admin, staging, dev, api,
      legacy, vpn, jira, git, jenkins, grafana, kibana, s3, phpmyadmin.
- [ ] Historical URLs (gau/wayback) + crawl (katana) -> parameter inventory.
- [ ] JS analysis -> hidden endpoints, API routes, feature flags, secret candidates.
- [ ] Non-intrusive nuclei (exposure/misconfig/tech/cve) at a polite rate limit.
- [ ] Prioritize the ONE app with the richest authenticated surface; go deep, not wide.
- [ ] Re-run recon periodically — new subdomains = fresh, uncontested bugs.
