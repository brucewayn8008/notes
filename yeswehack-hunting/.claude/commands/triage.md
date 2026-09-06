Triage recon output for target "$ARGUMENTS" and produce `targets/$ARGUMENTS/leads.md`.

Read: recon/live.txt, recon/httpx.jsonl, recon/urls.txt, recon/js_endpoints.txt,
recon/nuclei.txt, recon/js_secret_candidates.txt.

Rank the most promising leads for a MANUAL tester, highest-value first. Prioritize:
- Authentication / SSO / password-reset / account surfaces
- Admin / internal / staging / dev / debug hosts and panels
- API endpoints (REST/GraphQL), especially with object IDs → test for IDOR/BOLA
- File upload, import, export, SSRF-prone features (webhooks, url= params, PDF/render)
- Parameter-rich requests and old/unusual tech or CVEs from nuclei
- Business-logic-heavy flows (checkout, referral, subscription, wallet)

For each lead give: the asset/endpoint, why it's interesting, the specific
vuln-class hypothesis, and the single first test to try (reference the relevant
file in methodology/). Map each to the program's reward table where possible.
Keep everything in-scope. This is a plan to test — do not send exploit traffic.
