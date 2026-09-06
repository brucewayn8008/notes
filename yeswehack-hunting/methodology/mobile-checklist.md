# Mobile testing checklist (Android/iOS)

## Static (start here — cheap wins)
- [ ] Pull APK/IPA; decompile (jadx / apktool). Grep for keys, endpoints, secrets.
- [ ] AndroidManifest: exported activities/services/receivers/providers; deep links.
- [ ] Hardcoded API keys/tokens — check if they're privileged (report exposure).
- [ ] Firebase/S3/GCS buckets referenced in the app — test for public read/write.
- [ ] Cleartext traffic / disabled cert checks; backup & debuggable flags.

## Dynamic
- [ ] Proxy the app (Burp + cert). Most bugs are in the API behind it — treat the
      backend with the whole web checklist (IDOR/BOLA is king on mobile APIs).
- [ ] Local storage: SharedPreferences / Keychain / sqlite for sensitive data at rest.
- [ ] Deep-link / intent handling: unvalidated params, webview loadUrl to attacker URL.
- [ ] Certificate pinning bypass (Frida/objection) only if program allows.

## Note
For most mobile programs the real bounty is the **API**. Enumerate the app's endpoints,
then hammer authz/authn logic between two test accounts.
