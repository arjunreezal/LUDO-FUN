"""Applies LUDO branding and settings to the Flutter-generated platform folders.

Run once after `flutter create` has generated android/, ios/ and web/ (the
build workflow does this automatically). Safe to run repeatedly.

    flutter create . --org com.arjunrijal --project-name ludo --platforms android,ios,web
    python tool/configure_platforms.py

It sets the display name to LUDO, locks iPhone to portrait, installs the app
icons and launch screens from branding/, and wires optional Android release
signing that is only used when android/key.properties exists.
"""
import json
import os
import plistlib
import re
import shutil
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
BRANDING = os.path.join(ROOT, 'branding')
APP_NAME = 'LUDO'
NAVY = '#101827'

changes = []


def path(*parts):
    return os.path.join(ROOT, *parts)


def read(p):
    with open(p, encoding='utf-8') as handle:
        return handle.read()


def write(p, text):
    os.makedirs(os.path.dirname(p), exist_ok=True)
    with open(p, 'w', encoding='utf-8', newline='\n') as handle:
        handle.write(text)


def copy(src, dst):
    os.makedirs(os.path.dirname(dst), exist_ok=True)
    shutil.copyfile(src, dst)


def note(message):
    changes.append(message)


# ---------------------------------------------------------------- Android
def configure_android():
    android = path('android')
    if not os.path.isdir(android):
        print('android/ not found - skipped (run flutter create first)')
        return
    res = path('android', 'app', 'src', 'main', 'res')

    manifest = path('android', 'app', 'src', 'main', 'AndroidManifest.xml')
    if os.path.exists(manifest):
        text = read(manifest)
        updated = re.sub(r'android:label="[^"]*"', f'android:label="{APP_NAME}"', text, count=1)
        if updated != text:
            write(manifest, updated)
            note('Android app name set to LUDO')

    for density in ('mdpi', 'hdpi', 'xhdpi', 'xxhdpi', 'xxxhdpi'):
        for name in ('ic_launcher.png', 'ic_launcher_foreground.png'):
            src = os.path.join(BRANDING, 'android', f'mipmap-{density}', name)
            if os.path.exists(src):
                copy(src, os.path.join(res, f'mipmap-{density}', name))
    write(os.path.join(res, 'mipmap-anydpi-v26', 'ic_launcher.xml'),
          '<?xml version="1.0" encoding="utf-8"?>\n'
          '<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">\n'
          '    <background android:drawable="@color/ic_launcher_background"/>\n'
          '    <foreground android:drawable="@mipmap/ic_launcher_foreground"/>\n'
          '</adaptive-icon>\n')
    write(os.path.join(res, 'values', 'ic_launcher_background.xml'),
          '<?xml version="1.0" encoding="utf-8"?>\n<resources>\n'
          f'    <color name="ic_launcher_background">{NAVY}</color>\n</resources>\n')
    note('Android launcher icons installed (legacy and adaptive)')

    logo = os.path.join(BRANDING, 'android', 'drawable-xxhdpi', 'launch_logo.png')
    if os.path.exists(logo):
        copy(logo, os.path.join(res, 'drawable-xxhdpi', 'launch_logo.png'))
    launch = ('<?xml version="1.0" encoding="utf-8"?>\n'
              '<layer-list xmlns:android="http://schemas.android.com/apk/res/android">\n'
              f'    <item><color android:color="{NAVY}" /></item>\n'
              '    <item>\n'
              '        <bitmap android:gravity="center" android:src="@drawable/launch_logo" />\n'
              '    </item>\n'
              '</layer-list>\n')
    for folder in ('drawable', 'drawable-v21'):
        write(os.path.join(res, folder, 'launch_background.xml'), launch)
    splash_styles = ('<?xml version="1.0" encoding="utf-8"?>\n<resources>\n'
                     '    <style name="LaunchTheme" parent="@android:style/Theme.Light.NoTitleBar">\n'
                     '        <item name="android:windowBackground">@drawable/launch_background</item>\n'
                     f'        <item name="android:windowSplashScreenBackground">{NAVY}</item>\n'
                     '    </style>\n'
                     '    <style name="NormalTheme" parent="@android:style/Theme.Light.NoTitleBar">\n'
                     f'        <item name="android:windowBackground">@color/ic_launcher_background</item>\n'
                     '    </style>\n</resources>\n')
    for folder in ('values-v31', 'values-night-v31'):
        write(os.path.join(res, folder, 'styles.xml'), splash_styles)
    note('Android launch screen set to navy with the LUDO mark')

    configure_android_signing()


SIGNING_IMPORTS = 'import java.io.FileInputStream\nimport java.util.Properties\n'
SIGNING_PROPERTIES = '''
// LUDO: release signing is used only when android/key.properties exists.
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}
'''
SIGNING_CONFIG = '''    signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists()) {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

'''


def configure_android_signing():
    gradle = path('android', 'app', 'build.gradle.kts')
    if not os.path.exists(gradle):
        if os.path.exists(path('android', 'app', 'build.gradle')):
            print('android/app/build.gradle (Groovy) found - release signing not patched; '
                  'see docs/ANDROID.md to add it by hand.')
        return
    text = read(gradle)
    if 'keystorePropertiesFile' in text:
        return
    if 'plugins {' not in text or 'buildTypes {' not in text:
        print('Unexpected build.gradle.kts layout - release signing not patched.')
        return
    text = SIGNING_IMPORTS + text
    plugins_end = text.index('}', text.index('plugins {')) + 1
    text = text[:plugins_end] + '\n' + SIGNING_PROPERTIES + text[plugins_end:]
    build_types = text.index('    buildTypes {')
    text = text[:build_types] + SIGNING_CONFIG + text[build_types:]
    text = re.sub(
        r'signingConfig\s*=\s*signingConfigs\.getByName\("debug"\)',
        'signingConfig = if (keystorePropertiesFile.exists()) '
        'signingConfigs.getByName("release") else signingConfigs.getByName("debug")',
        text, count=1)
    write(gradle, text)
    note('Android release signing wired to android/key.properties (falls back to debug keys)')


# -------------------------------------------------------------------- iOS
def configure_ios():
    runner = path('ios', 'Runner')
    if not os.path.isdir(runner):
        print('ios/ not found - skipped (run flutter create first)')
        return
    info_path = os.path.join(runner, 'Info.plist')
    if os.path.exists(info_path):
        with open(info_path, 'rb') as handle:
            info = plistlib.load(handle)
        info['CFBundleDisplayName'] = APP_NAME
        info['UISupportedInterfaceOrientations'] = ['UIInterfaceOrientationPortrait']
        info['ITSAppUsesNonExemptEncryption'] = False
        with open(info_path, 'wb') as handle:
            plistlib.dump(info, handle)
        note('iOS display name LUDO, iPhone locked to portrait, no export-compliance prompt')

    icon_set = os.path.join(runner, 'Assets.xcassets', 'AppIcon.appiconset')
    contents = os.path.join(icon_set, 'Contents.json')
    if os.path.exists(contents):
        wanted = {image.get('filename') for image in json.loads(read(contents)).get('images', [])}
        copied = 0
        for name in wanted:
            src = os.path.join(BRANDING, 'ios', 'AppIcon.appiconset', name or '')
            if name and os.path.exists(src):
                copy(src, os.path.join(icon_set, name))
                copied += 1
        note(f'iOS app icons installed ({copied} sizes)')

    launch_set = os.path.join(runner, 'Assets.xcassets', 'LaunchImage.imageset')
    if os.path.isdir(launch_set):
        for name in ('LaunchImage.png', 'LaunchImage@2x.png', 'LaunchImage@3x.png'):
            src = os.path.join(BRANDING, 'ios', 'LaunchImage.imageset', name)
            if os.path.exists(src):
                copy(src, os.path.join(launch_set, name))
    storyboard = os.path.join(runner, 'Base.lproj', 'LaunchScreen.storyboard')
    if os.path.exists(storyboard):
        text = read(storyboard)
        updated = re.sub(
            r'<color key="backgroundColor" red="1" green="1" blue="1" alpha="1"',
            '<color key="backgroundColor" red="0.0627" green="0.0941" blue="0.1529" alpha="1"',
            text)
        if updated != text:
            write(storyboard, updated)
        note('iOS launch screen set to navy with the LUDO mark')


# -------------------------------------------------------------------- Web
def configure_web():
    web = path('web')
    if not os.path.isdir(web):
        return
    for name in ('Icon-192.png', 'Icon-512.png', 'Icon-maskable-192.png', 'Icon-maskable-512.png'):
        src = os.path.join(BRANDING, 'web', 'icons', name)
        if os.path.exists(src):
            copy(src, os.path.join(web, 'icons', name))
    favicon = os.path.join(BRANDING, 'web', 'favicon.png')
    if os.path.exists(favicon):
        copy(favicon, os.path.join(web, 'favicon.png'))
    manifest_path = os.path.join(web, 'manifest.json')
    if os.path.exists(manifest_path):
        manifest = json.loads(read(manifest_path))
        manifest.update({
            'name': APP_NAME,
            'short_name': APP_NAME,
            'background_color': NAVY,
            'theme_color': NAVY,
            'description': 'Classic Ludo against the computer or friends.',
            'orientation': 'portrait-primary',
        })
        write(manifest_path, json.dumps(manifest, indent=4) + '\n')
    index = os.path.join(web, 'index.html')
    if os.path.exists(index):
        text = read(index)
        text = re.sub(r'<title>.*?</title>', f'<title>{APP_NAME}</title>', text, count=1)
        text = re.sub(r'(<meta name="apple-mobile-web-app-title" content=")[^"]*(")',
                      rf'\g<1>{APP_NAME}\g<2>', text)
        write(index, text)
    note('Web icons, title and manifest set')


def main():
    if not os.path.isdir(BRANDING):
        sys.exit('branding/ is missing. Run: python tool/generate_icons.py')
    configure_android()
    configure_ios()
    configure_web()
    for line in changes:
        print('  - ' + line)
    print('Platform configuration complete.')


if __name__ == '__main__':
    main()
