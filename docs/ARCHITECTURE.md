# Architecture

## Principles

- **Rules live in one place.** `LudoEngine` decides every rule question. The
  UI, the computer opponents and (later) the online server only call it.
- **The engine is pure Dart.** No Flutter imports, no clock, no randomness:
  dice values are passed in. This keeps it deterministic and unit-testable,
  and lets the future Node.js server port or mirror it.
- **Immutable state.** Each action returns a new `GameState` with an
  increasing `version`, so stale or duplicated actions can be detected.
- **Animations never change state.** The engine state is updated first; the
  board only animates the transition from the old position to the new one.
- **Features are folders.** Each game is its own module; nothing is shared
  between unrelated games except app-level services.

## Layers

```
lib/
  main.dart                     entry point, phone portrait lock
  app/                          MaterialApp, routes, theme, service container
  core/                         storage, localisation, feedback, shared widgets
  features/
    games/ludo/
      models/                   seats, ruleset, state, moves, events (pure)
      engine/                   rules engine, track maths, board geometry, dice (pure)
      controllers/              LudoMatchController: pacing, bots, animations
      widgets/                  board painter, token layout/painter, dice, pods
      screens/                  match and results
    games/game_catalog/         the six-game library and original artwork
    bots/                       LudoBot (easy / medium / hard)
    game_setup/                 setup screen, remembered setups, seat planning
    home/ splash/ onboarding/ friends/ leaderboards/ profile/ achievements/ settings/
```

## Match flow

1. `GameSetupScreen` (or Quick play) builds a `MatchSetup`: seats, colours,
   who controls each seat, difficulty and `LudoRuleset`.
2. `LudoMatchScreen` creates a `LudoMatchController`, which calls
   `LudoEngine.newGame`.
3. A roll: the controller shows the tumbling dice, then calls
   `engine.roll(state, value)`. The result says whether a move is needed.
4. A move: the controller asks `engine.legalMoves`; people tap a highlighted
   token, computers ask `LudoBot`. The controller calls `engine.move` and hands
   the board a `TokenAnimation` (path, captured tokens) to draw the transition.
5. Engine `LudoEvent`s drive the move log, notices, sound and haptics.
6. When the engine reports `TurnPhase.finished`, the controller produces a
   `MatchSummary`; the profile records it and the results screen opens.

`TokenLayout` computes every token's on-screen position from the engine state
plus the current animation. Both the painter and tap hit-testing use it, so
what you see is what you tap.

## State management and navigation

The MVP uses Flutter's built-in `ChangeNotifier` + `ListenableBuilder`, an
`InheritedWidget` (`AppScope`) for app services, and named routes. This keeps
dependencies to one package (`shared_preferences`). Riverpod and GoRouter
remain good fits for the online phase, where authentication, sessions and deep
links add asynchronous state; adopting them then is a contained change because
screens only depend on the controllers.

## Persistence

`KeyValueStore` wraps `shared_preferences` (with an in-memory fallback if the
platform store fails). Stored locally: settings, onboarding flag, the local
profile (name, avatar colour, device player ID), Classic Ludo statistics, the
last 30 match records and the last setup per mode.

## Localisation

`AppStrings` holds every interface string in English and Nepali, chosen in
Settings. Screens read strings through `context.strings`; none are hardcoded.

## Adding the next games

Each new game gets its own `features/games/<game>/` module with its own
models, pure rules engine, tests, controller and screens, and flips
`available` in `GameId`. Ludo movement code is not reused for unrelated games.
Snake Ludo gets a separate engine and ruleset rather than options on Classic
Ludo. Card games will need server-dealt hands online.

## Online phase (planned, not built)

- Node.js + TypeScript server with Socket.IO, PostgreSQL, Redis only if needed.
- The server is authoritative: it generates dice, validates every action
  against its copy of the engine, rejects stale `version`s and duplicate
  actions, and saves results once.
- Clients send intents (roll, move token N) and render server state.
