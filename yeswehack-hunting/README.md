# YesWeHack Hunting Workspace (Claude Code)

A scope-safe, repeatable bug-bounty workflow driven by Claude Code.

## Setup
1. Install Claude Code, `cd` into this folder, run `claude`.
2. `bash scripts/setup.sh` to install the recon toolkit (Go tools + nuclei).
3. `pip install pyyaml --break-system-packages`.

## Add a target
1. Make `targets/<name>/` (copy `targets/_template/`).
2. Paste the **exact** scope from the program's YesWeHack "Scopes" tab into
   `scope.yaml`, and the rules/reward table into `rules.md`. This is the safety
   source of truth — nothing outside it gets touched.

## Hunt loop (inside Claude Code)
- `/recon <name>`   — enumerate + probe in-scope surface, summarize.
- `/triage <name>`  — rank the best leads into `leads.md`.
- Test manually with Burp; ask Claude to build test cases from `methodology/`.
- `/report <name>`  — draft a YesWeHack report from a confirmed finding.

## Safety
`CLAUDE.md` holds the rules Claude Code follows. Every host is filtered through
`scripts/scope-check.py` before traffic is sent. Private programs stay confidential.
Recon here is passive/non-intrusive by default; you drive active exploitation manually.
