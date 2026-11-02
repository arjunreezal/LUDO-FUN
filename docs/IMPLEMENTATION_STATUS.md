# Implementation status

Last updated with release 1.0.0 (offline Classic Ludo MVP).

## Phase 1 — Workspace and architecture: done
- [x] Feature-based Flutter project, app id `com.arjunrijal.ludo`
- [x] Theme (dark default, light, system), navigation, splash, onboarding
- [x] Architecture documented (`docs/ARCHITECTURE.md`)

## Phase 2 — Classic Ludo engine: done
- [x] Seats, tokens, configurable ruleset, immutable versioned state
- [x] Entry, movement, captures, safe squares, exact finish, extra turns,
      three-sixes limit, no-move handling, turn order, placements, match end
- [x] Unit tests, including 90 full random games checked for invariants

## Phase 3 — Offline gameplay: done
- [x] Flutter-drawn board, tokens, legal-move highlights, hop animations
- [x] Animated dice, haptics and system click sounds (respecting settings)
- [x] Computer opponents: easy, medium, hard
- [x] Pass and play, mixed person/computer seats, 2–4 seats, house rules
- [x] Move log, restart, leave confirmation, results with placements
- [x] Local profile, statistics, history, achievements, personal bests
- [x] English and Nepali (Nepali is a first draft)

## Not done yet (honest list)
- [ ] Custom sound effects and background music (system click only for now)
- [ ] Nepali translation review by a native speaker
- [ ] Screen-reader friendly token selection (tokens are tap targets on the
      board only)
- [ ] Real-device performance profiling
- [ ] Saved, resumable matches

## Phase 4 — Accounts and backend: not started
Node.js/TypeScript API, PostgreSQL schema and migrations, authentication
(guest, email, Apple, Google), profiles, API docs, environment examples.

## Phase 5 — Online private rooms: not started
Room codes, server-authoritative matches, reconnection, match history.

## Phase 6 — Friends and matchmaking: not started

## Phase 7 — Snake Ludo, Chess, Call Break, Teen Patti, Marriage: not started
Shown as "In development" in the app and cannot be started. Marriage needs a
reviewed regional rules specification first.

## Phase 8 — Admin dashboard: not started

## Phase 9 — QA: partial
Unit, controller and widget tests exist. Integration, multiplayer, security
and accessibility testing come with the later phases.

## Phase 10 — Release preparation: partial
Icons, launch screens, app name and portrait lock are applied by
`tool/configure_platforms.py`. Store metadata, privacy policy hosting,
TestFlight and Play Console setup are outstanding (`docs/RELEASE_CHECKLIST.md`).
