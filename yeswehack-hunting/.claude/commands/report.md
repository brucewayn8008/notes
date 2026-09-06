Draft a YesWeHack report for target "$ARGUMENTS" from the finding I describe.

Use `reports/report-template.md`. Fill every section:
- Clear title (vuln class + affected asset)
- CVSS 3.1 vector + score, and a plain-language severity justification
- Exact, numbered steps to reproduce (minimal, benign PoC — no weaponization)
- Concrete impact for THIS program (what an attacker gains)
- Evidence (request/response, screenshots I provide)
- Remediation guidance
Save to `reports/<target>-<short-slug>.md`. Keep private-program details confidential.
