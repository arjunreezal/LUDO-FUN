# Troubleshooting

## Cloud build (GitHub Actions)

**The Actions tab shows no workflow.** The `.github/workflows/build.yml` file
was not uploaded. Hidden-looking folders that start with a dot are sometimes
skipped by drag-and-drop; use GitHub Desktop or `git add .`.

**"Analyze and test" fails but the APK/IPA jobs succeed.** The builds don't
depend on the checks, so you still get files. Open the failed step to see
which test or analyzer message failed, and fix it before publishing.

**Android job fails in "Build APK".** Open the log and search for the first
`error:` line. Common causes: a Gradle/AGP mismatch after a new Flutter
release (re-run once; if it persists, run `flutter create .` locally with the
newest Flutter and commit nothing but code fixes), or bad signing secrets
(remove them to fall back to the temporary key).

**iOS job fails in "Build the iOS app".** Usually CocoaPods or Xcode
versions. Re-run the job; GitHub updates its macOS images regularly.

## Android install

**"App not installed" / "package conflicts with an existing package".** The
installed copy was signed with a different key. Uninstall LUDO first, or set
up your own signing key so builds can update each other.

**Play Protect blocks the install.** Choose *More details → Install anyway*.

## iPhone install

**"Untrusted Developer".** *Settings → General → VPN & Device Management →*
your Apple ID → *Trust*.

**App asks for Developer Mode / won't open.** *Settings → Privacy & Security
→ Developer Mode* → on, then restart.

**App stopped opening after a week.** Free Apple ID signatures last 7 days.
Sign the same IPA again with Sideloadly; your data stays.

**Sideloadly can't see the phone.** Install Apple's iTunes and iCloud from
apple.com, reconnect the cable, unlock the phone and tap *Trust*.

## Local development on Windows

**`flutter` is not recognised.** Add Flutter's `bin` folder to `PATH`, open a
new terminal and run `flutter doctor`.

**Android licences.** Run `flutter doctor --android-licenses`.

**Missing `android/` or `ios/` folders.** Run
`flutter create . --org com.arjunrijal --project-name ludo --platforms android,ios,web`.
It only adds missing files.

**`python` is not recognised.** `tool/configure_platforms.py` is optional for
local runs (it only sets the name, icons and launch screen). Install Python
from python.org if you want it locally; the cloud build runs it for you.
