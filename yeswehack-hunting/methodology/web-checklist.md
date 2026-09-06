# Web testing checklist (intermediate)

## Access control (highest ROI on these programs)
- [ ] IDOR/BOLA: swap object IDs, UUIDs, filenames across two accounts. Test numeric,
      base64, and hashed IDs. Check PATCH/PUT/DELETE, not just GET.
- [ ] Function-level auth: call admin/privileged endpoints as a low-priv user.
- [ ] Tenant isolation (multi-org apps): access org B's data with org A token.
- [ ] Mass assignment: add `role`, `isAdmin`, `verified`, `price` to JSON bodies.

## Authentication & session
- [ ] Password reset: token leakage, host-header poisoning, token not invalidated,
      reset for other users, response reflecting the token.
- [ ] OAuth/SSO: redirect_uri validation, state fixation, code/token leakage via Referer.
- [ ] JWT: alg=none, weak secret, kid injection, unverified signature.
- [ ] 2FA: bypass by skipping step, brute forcing, or re-using pre-2FA session.

## Injection / server-side
- [ ] SSRF: any url=, image=, webhook, import-from-URL, PDF/HTML render, thumbnail.
- [ ] SQLi/NoSQLi on parameter-rich endpoints (time-based first, non-destructive).
- [ ] Template injection (SSTI) in name/profile/preview fields.
- [ ] Path traversal / LFI on file/download/export params.

## Client-side
- [ ] Stored/reflected/DOM XSS — prefer contexts that hit other users.
- [ ] CSRF on state-changing actions lacking tokens/SameSite.
- [ ] postMessage & CORS misconfig (ACAO reflects Origin + credentials).

## Business logic
- [ ] Price/quantity tampering, negative values, currency swap at checkout.
- [ ] Coupon/referral/loyalty abuse, race conditions on redeem/withdraw.
- [ ] Workflow step skipping (pay-after-confirm, verify-after-use).
