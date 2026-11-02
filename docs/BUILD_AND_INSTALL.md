# Get LUDO onto your Android phone and iPhone

You do not need a Mac. GitHub builds both files for you in the cloud:

- **Android:** a ready-to-install `.apk`.
- **iPhone:** an **unsigned** `.ipa`. Apple only lets an app run on an iPhone
  after it has been signed with an Apple ID, so you sign it yourself in the
  last step (free, about five minutes, using Sideloadly on Windows).

Why not just hand over finished files? Building an iOS app requires Apple's
Xcode, which only runs on macOS, and the signature must belong to *your* Apple
ID and *your* iPhone. GitHub provides the Mac; you provide the Apple ID.

---

## Part 1 — Put the project on GitHub (once)

1. Create a free account at <https://github.com> if you don't have one.
2. Create a new repository named `ludo`. Make it **Public** — GitHub-hosted
   build machines, including the Mac, are free for public repositories.
   Private repositories get a monthly allowance of free minutes, and Mac
   minutes use it up faster; check GitHub's current billing page if you go
   private.
3. Upload this folder. The easiest ways on Windows:
   - **GitHub Desktop** (<https://desktop.github.com>): *File → Add local
     repository →* choose the `ludo` folder → *create a repository* → *Publish*.
   - **Git in a terminal** (from the `ludo` folder):

     ```powershell
     git init
     git add .
     git commit -m "LUDO offline Classic Ludo"
     git branch -M main
     git remote add origin https://github.com/YOUR-NAME/ludo.git
     git push -u origin main
     ```

   Make sure the hidden-looking `.github` folder is included — it holds the
   build instructions.

## Part 2 — Let GitHub build the files

1. Open your repository on github.com and click the **Actions** tab. If asked,
   click **I understand my workflows, go ahead and enable them**.
2. The **Build LUDO** workflow starts automatically after each push. You can
   also start it by hand: *Build LUDO → Run workflow*.
3. Wait for the green ticks (usually 10–20 minutes; the iPhone job is the
   slowest). The four jobs are:
   - **Analyze and test** — runs `flutter analyze` and the automated tests.
   - **Android APK** — builds the APK.
   - **iPhone IPA (unsigned)** — builds the IPA on a Mac.
   - **Publish release files** — only runs for version tags (below).
4. Open the finished run and scroll to **Artifacts**. Download
   `LUDO-android-apk` and `LUDO-ios-unsigned-ipa`. Each downloads as a `.zip`;
   extract it to get the `.apk` / `.ipa`.

**Phone-friendly downloads:** publish a release by pushing a version tag:

```powershell
git tag v1.0.0
git push origin v1.0.0
```

When the run finishes, the **Releases** section of your repository shows the
APK and IPA as direct downloads — open that page on your phone.

If a job fails, open it to read the log, and see `docs/TROUBLESHOOTING.md`.

## Part 3 — Install on Android

1. Get the `.apk` onto the phone: open the Release page in the phone's browser,
   or copy the file over USB.
2. Tap the file. Android asks you to allow installs from that app (browser or
   Files): *Settings → Install unknown apps → allow*.
3. Google Play Protect may warn about an unknown developer. Choose
   **Install anyway** — the app is yours and requests no permissions.

### Updating, and why you might want a signing key

Without extra setup, each cloud build is signed with a temporary key. Android
refuses to update an app signed with a different key, so **uninstall the old
LUDO before installing a new build** (this also clears local stats).

To get smooth updates (and to prepare for Google Play), add your own key once:

1. Create a key (keytool ships with Android Studio; adjust the path if needed):

   ```powershell
   & "C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe" -genkey -v `
     -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```

   Use passwords without backslashes. **Back this file up** and never commit
   it; losing it means you can no longer update the app.
2. Copy it as text:

   ```powershell
   [Convert]::ToBase64String([IO.File]::ReadAllBytes("upload-keystore.jks")) | Set-Clipboard
   ```

3. In GitHub: *Settings → Secrets and variables → Actions → New repository
   secret*. Add four secrets:
   - `ANDROID_KEYSTORE_BASE64` — the clipboard text
   - `ANDROID_KEYSTORE_PASSWORD` — the keystore password
   - `ANDROID_KEY_ALIAS` — `upload`
   - `ANDROID_KEY_PASSWORD` — the key password
4. Run the workflow again. From now on builds can update each other.

## Part 4 — Install on iPhone

You need: a Windows PC, a USB cable, and an Apple ID.

1. Install **Sideloadly** from <https://sideloadly.io> and follow its Windows
   requirements (it relies on Apple's iTunes and iCloud being installed —
   use the versions from apple.com).
2. Connect the iPhone, unlock it and tap **Trust This Computer**.
3. Open Sideloadly, drag in `LUDO-…-unsigned.ipa`, enter your Apple ID, and
   click **Start**. A secondary Apple ID works fine if you prefer.
4. On the iPhone:
   - *Settings → Privacy & Security → Developer Mode* → turn on and restart
     (required for apps signed this way on recent iOS versions).
   - *Settings → General → VPN & Device Management* → tap your Apple ID →
     **Trust**.
5. Open LUDO.

**Limits of a free Apple ID:** the signature lasts **7 days**, after which the
app won't open until you sign it again (repeat step 3; your data stays), and
only **3** sideloaded apps can be active at once. AltStore and SideStore are
alternatives that can refresh the signature over Wi-Fi.

**For permanent installs and TestFlight**, join the Apple Developer Program
(USD 99 per year). Signatures then last a year and you can distribute through
TestFlight and the App Store. That needs signing certificates set up on a Mac
or a cloud Mac service; see `docs/RELEASE_CHECKLIST.md`.

---

## Running and building on your Windows PC

Requirements: Flutter SDK (stable), VS Code with the Flutter and Dart
extensions, Git, and Android Studio (for the Android SDK and an emulator).
Check with `flutter doctor`.

```powershell
cd ludo
flutter create . --org com.arjunrijal --project-name ludo --platforms android,ios,web
python tool\configure_platforms.py     # optional: LUDO name, icons, launch screen
flutter pub get
flutter run                             # pick an emulator, a USB phone or Chrome
flutter test
flutter analyze
flutter build apk --release             # APK in build\app\outputs\flutter-apk\
```

`flutter create .` generates the `android/`, `ios/` and `web/` folders and does
not overwrite any existing file. Windows cannot build the iOS app; use the
cloud workflow above.
