# Release checklist

## Every build
- [ ] `flutter analyze` clean and `flutter test` passing (the Analyze and test job)
- [ ] Version bumped in `pubspec.yaml` and `appVersion` in
      `lib/features/settings/settings_screen.dart`
- [ ] Played a full match on a real Android phone and a real iPhone

## Android (Google Play)
- [ ] Own upload key added as GitHub secrets (`docs/BUILD_AND_INSTALL.md`)
- [ ] Build an app bundle: `flutter build appbundle --release`
- [ ] Play Console app created, internal testing track, content rating,
      data-safety form ("no data collected" for release 1)
- [ ] Store listing: icon (`branding/app_icon_1024.png` scaled to 512), feature
      graphic, phone and tablet screenshots, description

## iOS (TestFlight / App Store)
Native iOS release builds and signing need macOS with Xcode, or a cloud Mac
(the GitHub workflow's macOS job, Codemagic, Bitrise, etc.).
- [ ] Apple Developer Program membership
- [ ] App ID `com.arjunrijal.ludo` registered; distribution certificate and
      App Store provisioning profile
- [ ] Signing added to CI (for example with an App Store Connect API key) and
      `flutter build ipa` instead of `--no-codesign`
- [ ] App Store Connect record, privacy "nutrition label" (no data collected
      for release 1), age rating, screenshots for required device sizes
- [ ] Upload to TestFlight, test, then submit for review
- [ ] Sign in with Apple required only once third-party sign-in is added

## Before any online release
- [ ] Everything in `docs/SECURITY_PRIVACY_CHECKLIST.md`
- [ ] Load testing before stating any player capacity
