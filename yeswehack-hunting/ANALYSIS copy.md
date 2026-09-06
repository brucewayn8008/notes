# YesWeHack Program Analysis & Hunting Plan

Profile: intermediate hunter · web + mobile + recon · using Claude Code for
recon automation, triage, and a repeatable workflow.
Analyzed: the 42 most-recently-updated programs on your account (freshest = most worth hunting).

## How I scored them
The best target for *you* maximizes **fresh, under-tested surface you can reach**, not the
biggest logo. Four signals:
- **Access** — private programs you're already invited to = far less competition. Use them.
- **Scope breadth** — more scopes/subdomains = more recon surface = more room for your strengths.
- **Competition proxy** — cumulative report count. On a *mature* program a **low** count means
  the surface is under-tested; a huge count (e.g. 3000+) means it's picked over.
- **Fit** — web/mobile/recon-friendly over hardware/crypto/e-voting specialties.

Report count is lifetime and includes duplicates/informatives, so treat it as a rough
"how crowded" gauge, not gospel.

---

## TIER 1 — start here

### 1. Leclerc Drive (Infomil) — PRIVATE · 46 scopes · 81 reports · €50–5,000 · <1d response
**Why it's your #1:** 46 in-scope assets with only 81 lifetime reports on a *private*
program is a recon goldmine — a huge surface almost nobody has combed. This is exactly
where your recon skills + Claude Code automation win: enumerate the whole estate, find the
one forgotten staging/admin/API host, go deep.
**Approach:** Wide passive recon across all 46 roots → bucket live hosts by tech/title →
hunt for dev/staging/legacy panels and API endpoints → IDOR/BOLA and auth logic on the
drive/grocery ordering flows (accounts, orders, delivery slots, loyalty). French-language
app; keep everything confidential (private program).

### 2. Scopely — Monster Hunter Now (17 reports) & Pikmin Bloom (14 reports) — PRIVATE · mobile · 4 scopes · $25–2,000
**Why:** Almost no reports = brand-new, uncontested. They're **mobile** games, matching
your mobile focus, and private.
**Approach:** Static-analyze the APK/IPA (jadx/apktool) for endpoints, keys, Firebase/S3
buckets → proxy the app and attack the **game API**: IDOR/BOLA on player data, in-game
currency/inventory logic, anti-cheat/score submission tampering, purchase validation.
On mobile programs the money is almost always in the backend API, not the client.

---

## TIER 2 — public daily drivers (volume + practice)

### 3. MediaMarktSaturn — PUBLIC · 31 scopes · 567 reports · €100–4,000
Big European electronics e-commerce. Wide web surface + apps, moderate crowding, €100 floor
(no €0 informatives). Classic e-comm bugs: checkout/price logic, coupon abuse, IDOR on
orders/returns, account takeover.

### 4. ExpressVPN (Kape) — PUBLIC · 31 scopes · $50–2,500 · 854 reports
VPN clients = **mobile + desktop apps** plus wide web. Build a methodology once and it
largely reuses on **CyberGhost** and **Private Internet Access** (same owner, both on your
list) — three programs for one learning curve.

### 5. Telenor Sweden — PUBLIC · 24 scopes · €50–6,000
Telecom, wide scope, higher ceiling. More crowded (1807 reports) but big estates always
grow new subdomains — re-running recon catches fresh assets.

---

## TIER 3 — build toward these (high value, harder/more mature)

- **Desjardins** — PRIVATE · 28 scopes · **$75–20,000** · 690 reports. You already have
  access and the ceiling is huge. Finance = strict, mature, but a strong IDOR/authz bug pays
  enormously. Great "go deep" goal once you've warmed up.
- **Lucca** — PRIVATE · 30 scopes · €0–10,000. HR/SaaS multi-tenant → **IDOR/BOLA and
  tenant-isolation** are the whole game. If you like access-control bugs, this is a match.
- **GIE SESAM-Vitale** — PRIVATE · HealthTech · €50–**20,000** · 86 reports. Low competition,
  high value, but specialized (French health-card app).
- **FDJ United (gaming)** — PUBLIC · 33 scopes · €50–**15,000**. Betting/gaming logic + wide web.

## Skip / deprioritize for now
- **VFS Global** — $5–1,500 and 2593 reports: low pay, very crowded.
- **Infomaniak / Doctolib** — high ceilings but heavily picked over (3372 / 1745 reports).
- **Swiss Post E-Voting** (€230k) — specialist crypto/e-voting; not a web/mobile/recon fit.
- **YesWeHack Dojo** — no bounties, but *use it to practice* the exact bug classes above,
  risk-free, while your recon runs.

---

## The plan, concretely
1. **This week:** load **Leclerc Drive** into the workspace, paste its scope, run `/recon`
   then `/triage`. In parallel, static-analyze one **Scopely** mobile app.
2. **Daily driver:** keep **MediaMarktSaturn** (or ExpressVPN) open for steady web practice
   and dupes-are-cheaper volume.
3. **Goal target:** as findings land, invest in **Desjardins** or **Lucca** for the big payouts.
4. Re-run recon on the wide private programs every week — new assets = uncontested bugs.
