# LUDO

A board and card game platform for Android and iPhone, built with Flutter.
**Release 1 ships Classic Ludo, fully playable offline** — against the
computer at three levels, or pass-and-play with friends on one device. Snake
Ludo, Chess, Call Break, Teen Patti and Marriage are listed in the app as in
development and cannot be started yet.

## Get the APK and IPA

Builds run in the cloud on GitHub (free for public repositories), so you don't
need a Mac:

1. Push this folder to a GitHub repository.
2. Open **Actions → Build LUDO** and wait for it to finish.
3. Download the `LUDO-android-apk` and `LUDO-ios-unsigned-ipa` artifacts.
4. Install the APK on Android; sign and install the IPA on iPhone with
   Sideloadly and your Apple ID.

Step-by-step instructions, including updates and the free-Apple-ID limits:
**[docs/BUILD_AND_INSTALL.md](docs/BUILD_AND_INSTALL.md)**.

## What's in release 1

- Classic Ludo for 2, 3 or 4 seats; any mix of people and computers
- Computer opponents: Easy (random legal moves), Medium (priorities: finish,
  capture, enter, escape danger), Hard (scores every move for progress, safety
  and risk)
- Configurable house rules, documented default ruleset
  ([docs/LUDO_RULES.md](docs/LUDO_RULES.md))
- Flutter-drawn board and dice, hop-by-hop token animation, capture animation,
  legal-move highlights, move log, restart, results with placements
- Local profile with statistics, match history, achievements and personal bests
- Dark and light themes, reduced motion, vibration and sound toggles, game speed
- English and Nepali (Nepali is a first draft)
- No account, network access, ads, permissions or real money

## Run it on Windows

Requirements: Flutter (stable), VS Code with the Flutter and Dart extensions,
Git and Android Studio (Android SDK and emulator). Then:

```powershell
cd ludo
flutter create . --org com.arjunrijal --project-name ludo --platforms android,ios,web
python tool\configure_platforms.py      # optional: LUDO name, icons, launch screen
flutter pub get
flutter run
```

Checks:

```powershell
flutter analyze
flutter test
```

`flutter create .` generates the `android/`, `ios/` and `web/` folders from
your installed Flutter version and never overwrites existing files.

## Project layout

```
lib/
  app/                      app shell, routes, theme, services
  core/                     storage, localisation, feedback, shared widgets
  features/
    games/ludo/             models, engine (pure Dart), controller, widgets, screens
    games/game_catalog/     the six-game library and artwork
    bots/                   computer opponents
    game_setup/ home/ splash/ onboarding/ friends/ leaderboards/
    profile/ achievements/ settings/
test/                       engine, bot, controller and widget tests
tool/                       icon generator and platform configuration
branding/                   generated icons and launch images
.github/workflows/          cloud build for APK and IPA
docs/                       guides, rules, architecture, checklists
```

## Documentation

- [Build and install](docs/BUILD_AND_INSTALL.md)
- [Classic Ludo rules](docs/LUDO_RULES.md)
- [Architecture](docs/ARCHITECTURE.md)
- [Implementation status and roadmap](docs/IMPLEMENTATION_STATUS.md)
- [Troubleshooting](docs/TROUBLESHOOTING.md)
- [Security and privacy checklist](docs/SECURITY_PRIVACY_CHECKLIST.md)
- [Release checklist](docs/RELEASE_CHECKLIST.md)

## Next phases

Accounts and a Node.js/PostgreSQL backend, server-authoritative online rooms,
friends and matchmaking, then the five other games, an admin dashboard and
store releases. See [docs/IMPLEMENTATION_STATUS.md](docs/IMPLEMENTATION_STATUS.md).
