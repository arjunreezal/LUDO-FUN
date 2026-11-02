# Security and privacy checklist

## Release 1 (offline)
- [x] No network access, accounts, analytics, ads or in-app purchases
- [x] No runtime permissions requested on Android or iOS
- [x] Data stored only on the device (settings, profile, stats, history)
- [x] Players can erase stats and history (Profile → Reset statistics)
- [x] No real money, prizes or gambling; Teen Patti is planned with virtual
      points only
- [x] No secrets in source; Android signing values come from GitHub secrets
      and `android/key.properties` (git-ignored)
- [x] In-app privacy and terms page

## Before the online phase ships
- [ ] Password hashing with a modern algorithm (Argon2id or bcrypt)
- [ ] Authorisation on every API route and socket event; room membership checks
- [ ] Server-generated dice and cards; server-validated moves and results
- [ ] Idempotent result processing; reject stale versions and duplicate actions
- [ ] Rate limiting and input validation on the API and sockets
- [ ] Authenticated WebSocket connections
- [ ] Block and report tools, moderation queue, audit log for admin actions
- [ ] Account deletion and a documented data-retention policy
- [ ] Privacy policy hosted at a public URL and store privacy disclosures
- [ ] Secrets in environment variables only; `.env.example` with placeholders
- [ ] Security tests for the boundaries above (not just "auth exists")
