# Shipping Tarkeez to Android (and iOS)

## ✅ Android is set up and BUILDS on this machine
Already done: Godot 4.7 export templates installed, JDK 17 +Android SDK detected,
debug keystore wired (`~/.android/debug.keystore`), ETC2 compression on,
`export_presets.cfg` Android preset (`org.tarkeez.app`, landscape, arm64).

**Rebuild the APK:** double-click `BUILD_APK.bat` (or run the command below).
Output: `build/Tarkeez.apk` (~33 MB).
```
godot --headless --path . --export-debug "Android" build/Tarkeez.apk
```
**Install on your phone:**
- USB: enable Developer Options → USB debugging, connect, then
  `"%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe" install -r build\Tarkeez.apk`
- Or copy `Tarkeez.apk` to the phone and tap it (allow "install unknown apps").

The rest below (release signing, Play Store) is for going live.

---

## One-time setup (Android)
1. **Editor → install export templates:** Godot → Editor → *Manage Export
   Templates* → Download & Install (matches 4.7-stable).
2. **JDK 17** + **Android SDK** (Android Studio is easiest). In Godot:
   *Editor → Editor Settings → Export → Android* — set the Android SDK path and
   `adb`/`apksigner`/`zipalign` paths (or let Godot use the bundled Gradle).
3. **Debug keystore** (for test installs): Godot can auto-generate one, or:
   `keytool -keystore debug.keystore -storepass android -alias androiddebugkey -keypass android -genkey -keyalg RSA -validity 9999`
   Point Editor Settings → Export → Android → Debug Keystore at it.
4. **Release keystore** (for the store — keep it safe, you can never change it):
   `keytool -genkey -v -keystore tarkeez-release.keystore -alias tarkeez -keyalg RSA -keysize 2048 -validity 10000`
   Set it on the export preset (release keystore/user/password).

## Build
- Quick test APK (device in USB-debug, then in Godot press the Android "remote
  deploy" / *Export → Export Project*):
  `godot --headless --path . --export-debug "Android" build/Tarkeez.apk`
- Release **AAB** for Play (set `gradle_build/use_gradle_build=true` +
  `export_format=1` in the preset, install the Gradle build template via
  *Project → Install Android Build Template*):
  `godot --headless --path . --export-release "Android" build/Tarkeez.aab`

## Store checklist (your accounts)
- **Google Play**: one-time $25. Create app → upload AAB → fill data-safety,
  content rating, privacy policy URL → closed test → production.
- **Apple App Store**: $99/yr, a Mac + Xcode, export iOS, sign with your
  Apple Developer cert. Same flow via App Store Connect.
- **Assets needed** (Claude can generate): 512² icon (done — `assets/icons/`),
  feature graphic 1024×500, 4–8 phone screenshots (use the screenshot harness),
  short + full description (Arabic + English), privacy policy.
- **Monetization**: wire real IAP for Tarkeez+ — replace the mock in
  `AppState.subscribe_plus()` with Google Play Billing / StoreKit via a plugin,
  keep the `premium` gating already in `Catalog.gd`.

## Notes baked in
- Portrait locked (`window/handheld/orientation=portrait`).
- `art_raw/`, `art_gen/`, `_shots/`, docs and `.bat` files are excluded from the
  build via the preset's `exclude_filter`.
- Local notifications (`Notify.gd`) are stubs — add a notifications plugin to
  schedule the streak reminder on-device.
