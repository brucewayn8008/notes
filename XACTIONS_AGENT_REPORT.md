# XActions Growth Agent — Full Report

_Account: **@GarvSanwariya** · Report date: 2026-09-06 · Server: `adminhermes@136.108.110.31` (`~/xactions`)_

---

## 1. Twitter Profile (live)

| Field | Value |
|---|---|
| **Name** | Garv Sanwariya |
| **Handle** | @GarvSanwariya |
| **Bio** | "Building with AI so you don't have to guess. daily tips on Claude Code, Cursor & MCP. i ship fast and show you exactly how." |
| **Tagline** | follow for the workflow → |
| **Link** | saranik.in |
| **Joined** | December 2018 |
| **Followers** | **203** |
| **Following** | 356 |

> ⚠️ **Signals:** following (356) > followers (203) reads as a small/new account to buyers. The only off-Twitter link is `saranik.in`, but no content or CTA drives people there with a reason to click. **That is the funnel gap.**

---

## 2. What the Agent Does & How It Works

Two independent engines run off one X session cookie (`data/session.json`), plus supporting "brain" modules.

### Engine A — Growth Daemon (reply/engagement bot)
`src/agents/growthDaemon.js` — runs 24/7 under PM2 as `xactions-agent`.

- **Loop:** every **4–8 min** it wakes, picks one weighted action, drives a headless Chromium browser (recycled fresh each cycle as of the 2026-09-06 fix), writes a reply with an LLM, logs it, sleeps.
- **Daily caps (config):** 10 posts / 100 replies / 250 likes. _(Note: it has been exceeding the intended ~40 reply cap — see §6.)_

**Actions it rotates through:**

| Action | What it does |
|---|---|
| `reply_niche` | Searches niche keywords (Claude Code, MCP, vibe coding…), replies to fresh tweets |
| `engage_buildinpublic` | Searches "build in public" / "shipped an mvp", replies + likes |
| `like_feed` | Likes relevant tweets from the home feed |
| `self_reply_pass` | Replies to people who replied to you in the last 60 min (keeps threads alive) |
| `check_mentions` | Reads mentions tab and responds |
| `post_original` / `quote_tweet` / `thread` | Occasionally posts its own content |

**How replies are written:** target tweet + persona (tone, opinions, example tweets) → LLM.
- Cheap models (Gemini / Claude Haiku via the `agy` CLI) handle the 100+/day replies + relevance scoring (0–100, low scores skipped).
- **Opus** (`contentBrain.js`) is reserved for original tweets/threads only.

### Engine B — Calendar Publisher (scheduled original posts)
`scripts/calendar-publisher.js` — run by **cron** 3×/day. Posts from **hardcoded** `SHORT_TWEETS` (15) + `THREADS` (9) arrays. _(It does NOT read `data/content-calendar.json` — that 151KB file is orphaned/unused.)_

### Supporting brains
- **`newsBrain.js`** — daily; drafts AI-news reaction posts into the calendar for review
- **`influencerScraper.js`** — scrapes @PrajwalTomar_, @akshay_pachaar, etc. to mirror what works
- **`managerBrain.js` / `memoryStore.js`** — session memory (Mem0 + JSON)
- **`surveillanceAgent.js`** — competitor/keyword monitoring

### Tech stack
Node.js (ESM) · Puppeteer + stealth (headless Chromium) · Gemini + `agy` CLI (Claude) for content · PM2 for process management · cron for scheduled posts · No paid Twitter API (browser automation).

---

## 3. What You Post About (Content Pillars)

Persona: **"AI Content Creator — vibe coding & AI dev tools"**, fixed content mix:

| Pillar | Weight | What it is |
|---|---|---|
| **Tips & Tricks** | 30% | Actionable CLAUDE.md / Cursor / prompt tips people save |
| **Tool Tutorials** | 25% | "how I do X with AI" workflows + stack breakdowns |
| **AI News** | 20% | Fast takes on new tool/model drops |
| **Preference Questions** | 15% | "Claude vs Codex", "mac vs windows" engagement bait |
| **Build in Public** | 10% | Honest shipping updates (no revenue claims) |

**Voice:** casual, lowercase-friendly, builder energy, practical-not-hypey.
**Explicitly bans:** em-dashes, hashtags, corporate jargon, rage-bait, revenue claims, and (currently) security/hacking framing — _the last one is being blended ~30% back in for client acquisition._

**Real examples it posts:**
- "add one line to your CLAUDE.md and claude stops repeating its mistakes…"
- "my ai stack for shipping an mvp in a weekend: claude code for backend, v0 for ui, supabase for db…"
- "Agencies charging ₹50L for a 'custom AI solution' that's just a Next.js frontend + an OpenAI call. Meanwhile we build ACTUAL intelligent agents for a fraction." ← client-leaning

---

## 4. Posting Structure

### Schedule (IST — tuned so IST-evening = US-morning)

| When | What | Engine |
|---|---|---|
| **8:00 AM** | Short tweet | Calendar cron |
| **2:00 PM** | Short tweet | Calendar cron |
| **10:00 PM (Tue/Wed/Thu)** | Thread (flagship) | Calendar cron |
| **Every 4–8 min, 24/7** | Replies + likes | Growth daemon |

### Post-format rules (baked into the persona `writingRules`)
1. **Line 1 is the whole game** — a specific number, a curiosity gap, or one debate-driving claim.
2. First-person framing: "i built", "i tested", "i replaced".
3. Short first sentence, then whitespace, **one idea per line**.
4. Single tweets: **under 100 chars** OR **240–259 value-dense** — nothing in between.
5. Threads: **5–12 tweets**, hook under 100 chars, payoff stated in tweet 1.
6. One strong opinion that forces agree/disagree (debate = reach).
7. CTA = a genuine question or "bookmark this" — **never** "like if you agree" (suppressed).
8. **Links never in a main post** — links go in the **first reply only** (~0% reach otherwise).
9. 0–2 functional emoji, sentence case, ALL-CAPS on one word max.
10. Optimize for **replies + bookmarks**, not likes (lowest-weighted).

### Reply style mix
Insight 45% · Agreement 25% · Question 10% · Humor 10% · Pushback 10%

### Thread structure (example: "I Tested 8 AI Coding Tools")
Hook → "how I tested" (credibility) → ranked countdown #8→#1 → TL;DR recap → CTA ("disagree? drop your ranking") → follow prompt.

---

## 5. Fixes Applied 2026-09-06

1. **Daemon outage (was posting 0 replies/day).** Root cause: `local-tools.js` reused ONE browser tab for the daemon's multi-day life; after ~2.5 days it got soft-throttled by X and every navigation timed out (a fresh browser with the same cookie worked instantly). **Fix:** added `recycleBrowser()` + `hardCloseBrowser()` (force-kills Chrome, no zombies), cached the session cookie and auto re-apply on each fresh browser, and the daemon now recycles the browser at the **start of every cycle**. Verified: replies + likes resumed immediately; 61 leaked Chromes → 1.
2. **Threads stuck on #2.** Cron always reposted thread #2 (`parseInt(args[1]||'2')`). **Fix:** now advances through unpublished threads, recycles when exhausted.
3. **Tweets ran dry after tweet-15.** **Fix:** now recycles the tweet queue instead of going silent.

_Server backups: `*.bak-20260906081406` (local-tools, growthDaemon), `calendar-publisher.js.bak-20260906075242`._

---

## 6. Gaps & Recommendations (to get CLIENTS, not just followers)

The system is a well-built **follower machine at 203 followers** — but it has **no funnel**. To convert to leads for AI-agent / app-web-dev / pentesting services:

- [ ] **Buyer-intent reply targeting** — add a search set for buying signals ("need a developer", "looking to build", "my app is broken", "anyone do a security audit", "hiring a freelancer") alongside the builder keywords. Currently it only talks to peers.
- [ ] **Lead funnel** — `data/leads.jsonl` logging + approval-gated DM outreach (the DM tool already exists) + a real destination (Cal.com / services page) in bio + pinned + first-reply.
- [ ] **Blend security/pentesting ~30%** — restore the free-audit lead magnet + "breaks vibe-coded apps" proof (the single strongest differentiator; was stripped in the Aug 31 persona rewrite).
- [ ] **Enforce ~40–50 replies/day cap** — the daemon was doing 150–220/day (its own config cap is 40), which is what got the session soft-throttled. Prevention > recycling.
- [ ] **Fresh content generation** — wire the publisher to `contentBrain.js` (Opus/agy) or `content-calendar.json` so it stops recycling old posts after a full cycle.
- [ ] **Fix the follower:following ratio** — trim/curate following; it reads as "small account" to buyers.

### One-line summary
> The daemon grows the audience 24/7 (replies/likes to builders + scheduled educational tweets/threads), tuned to the 2026 X-algorithm. It works. But it has no buyer-intent targeting, no lead capture, and no reason-to-click destination — the gap between "getting followers" (built) and "getting clients" (not yet).
