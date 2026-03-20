# Samsung Galaxy S23 Ultra - Kid-Friendly Emulation Box Setup Guide

Turn a Samsung Galaxy S23 Ultra into a dedicated emulation and gaming device for kids. This guide removes Samsung bloatware, installs emulators for 17+ retro systems, adds kid-friendly apps, and configures a game launcher as the home screen.

## Prerequisites

- Samsung Galaxy S23 Ultra (Snapdragon 8 Gen 2)
- USB cable (USB-C)
- Computer with ADB installed
- USB Debugging enabled on the phone

### Enable USB Debugging

1. Go to **Settings > About phone**
2. Tap **Build number** 7 times to unlock Developer Options
3. Go to **Settings > Developer options**
4. Enable **USB debugging**
5. Connect the phone via USB and tap **Allow** on the debugging prompt
6. Set USB mode to **File Transfer / MTP**

### Verify Connection

```bash
adb devices
```

You should see your device serial (e.g., `R5CX3162VNW	device`).

---

## Phase 1: Debloat Samsung

We use `pm uninstall -k --user 0` which safely disables packages for the current user without touching the system partition. This is **fully reversible via factory reset**.

### What Gets Removed (129 packages)

| Category | Examples |
|----------|----------|
| **Facebook** | Facebook, Facebook Services, Facebook App Manager |
| **Microsoft** | OneDrive, Microsoft App Manager |
| **Bixby** | Bixby Agent, Bixby Wakeup, Bixby Vision |
| **Samsung Apps** | Samsung Browser, Samsung Pay, Samsung Cloud, Samsung Calendar, Galaxy Store, Samsung Video, AR Zone, AR Emoji, AR Drawing, Game Launcher, Galaxy Themes |
| **Samsung Smart Features** | Smart Suggestions, Smart Call, Smart Face, Smart Mirroring |
| **Knox/Secure Folder** | Knox Analytics, Knox Container, Secure Folder, KLMS Agent |
| **Samsung Misc** | Tips, Safety Information, Samsung Members, Kids Mode, Device Security, Update Center, Easy Setup |
| **TTS Languages** | 12 non-English TTS language packs |
| **Google Bloat** | Google Assistant, Android Auto, Google Maps, Google Duo, Feedback, Wellbeing |

### What We Keep

- Samsung Dialer & Contacts (phone still works)
- Samsung Camera (best camera app for the hardware)
- Samsung Keyboard (Honeyboard)
- Samsung DeX (for monitor/TV output gaming)
- Core system services (connectivity, WiFi, Bluetooth, NFC)
- Google Play Store & Google Play Services
- Google Chrome

### Run the Debloat Script

```bash
chmod +x debloat.sh
bash debloat.sh
```

Expected output: ~112 removed, ~16 skipped (not present), ~1 failed (protected).

### Restore a Package (if needed)

```bash
adb shell cmd package install-existing <package.name>
```

Example - restore Samsung Calendar:
```bash
adb shell cmd package install-existing com.samsung.android.calendar
```

---

## Phase 2: Install App Stores

### Aurora Store (Anonymous Google Play Access)
```bash
wget "https://f-droid.org/repo/com.aurora.store_73.apk" -O aurora-store.apk
adb install aurora-store.apk
```

### F-Droid (Open Source App Store)
```bash
wget "https://f-droid.org/F-Droid.apk" -O f-droid.apk
adb install f-droid.apk
```

---

## Phase 3: Install Emulators

### Multi-System

| App | Systems | Source |
|-----|---------|--------|
| **RetroArch** | NES, SNES, GB, GBC, GBA, Genesis, Master System, Saturn, N64, DS, PSX, Dreamcast, and more | [buildbot.libretro.com](https://buildbot.libretro.com/stable/) |
| **Lemuroid** | NES, SNES, GB, GBC, GBA, Genesis, N64, DS, PSX, Atari (simpler UI than RetroArch) | [GitHub](https://github.com/Swordfish90/Lemuroid/releases) |

```bash
wget "https://buildbot.libretro.com/stable/1.22.2/android/RetroArch_aarch64.apk" -O retroarch.apk
wget -L "https://github.com/Swordfish90/Lemuroid/releases/download/1.16.2/lemuroid-app-free-dynamic-release.apk" -O lemuroid.apk
adb install retroarch.apk
adb install lemuroid.apk
```

### Standalone Emulators (Better Performance)

| App | System | Source |
|-----|--------|--------|
| **PPSSPP** | PSP | [ppsspp.org](https://www.ppsspp.org/download/) |
| **Dolphin** | GameCube / Wii | [dolphin-emu.org](https://dolphin-emu.org/download/) |
| **NetherSX2** | PS2 | Community builds (not officially distributed) |
| **Azahar (Lime3DS)** | Nintendo 3DS | [GitHub](https://github.com/azahar-emu/azahar/releases) |
| **Flycast** | Dreamcast / Naomi | [GitHub](https://github.com/flyinghead/flycast/releases) |

```bash
wget "https://www.ppsspp.org/files/1_20_3/ppsspp.apk" -O ppsspp.apk
wget -L "https://dl.dolphin-emu.org/releases/2603a/dolphin-2603a.apk" -O dolphin.apk
wget -L "https://github.com/azahar-emu/azahar/releases/download/2124.3/azahar-2124.3-android-vanilla.apk" -O azahar-3ds.apk
wget -L "https://github.com/flyinghead/flycast/releases/download/v2.6/flycast-2.6.apk" -O flycast.apk

adb install ppsspp.apk
adb install dolphin.apk
adb install azahar-3ds.apk
adb install flycast.apk
adb install NetherSX2.apk  # Provide your own APK
```

### Emulator Compatibility Chart (S23 Ultra - Snapdragon 8 Gen 2)

| System | Performance | Recommended App |
|--------|-------------|-----------------|
| NES / SNES / GB / GBC / GBA | Perfect | Lemuroid or RetroArch |
| Sega Genesis / Master System | Perfect | Lemuroid or RetroArch |
| N64 | Perfect | RetroArch (Mupen64Plus core) |
| Nintendo DS | Perfect | Lemuroid or RetroArch |
| PSX (PS1) | Perfect | RetroArch (Beetle PSX HW core) |
| Dreamcast | Perfect | Flycast |
| PSP | Perfect | PPSSPP |
| GameCube | Great (most games) | Dolphin |
| Wii | Good-Great | Dolphin |
| PS2 | Good (many games) | NetherSX2 |
| 3DS | Good (many games) | Azahar / Lime3DS |

---

## Phase 4: Kid-Friendly Apps

### Minecraft
```bash
adb install minecraft.apk  # Provide your own APK
```

### YouTube Kids
- Download from Aurora Store or Google Play Store on the device
- Or download APK from [APKMirror](https://www.apkmirror.com/apk/google-inc/youtube-kids/) (manual download required - split APK)

---

## Phase 5: Game Launcher (Daijisho)

Daijisho is a retro game launcher that can be set as your home screen, giving the device a console-like feel.

```bash
wget -L "https://github.com/TapiocaFox/Daijishou/releases/download/v1.5.0/416.apk" -O daijisho.apk
adb install daijisho.apk
```

### Set Daijisho as Default Launcher

1. On the phone, press the **Home** button
2. Select **Daijishou** from the launcher picker
3. Tap **Always**

Or via ADB:
```bash
adb shell cmd package set-home-activity com.magneticchen.daijishou/.MainActivity
```

### Configure Daijisho

1. Open Daijisho
2. Go to **Settings > Platforms**
3. Add each platform and point it to the corresponding `/sdcard/ROMs/<system>` directory
4. Set the emulator for each platform (e.g., PSP -> PPSSPP, GameCube -> Dolphin)
5. Scan for games

---

## Phase 6: ROM Directory Structure

ROMs go in `/sdcard/ROMs/` on the device:

```
/sdcard/ROMs/
├── 3DS/
├── Dreamcast/
├── GB/
├── GBA/
├── GBC/
├── GameCube/
├── Genesis/
├── MasterSystem/
├── N64/
├── NDS/
├── NES/
├── PS2/
├── PSP/
├── PSX/
├── SNES/
├── Saturn/
└── Wii/
```

### Transfer ROMs via ADB

```bash
adb push ~/ROMs/SNES/* /sdcard/ROMs/SNES/
adb push ~/ROMs/GBA/* /sdcard/ROMs/GBA/
# etc.
```

Or just drag and drop via file manager when connected in MTP mode.

---

## Phase 7: Performance Tweaks Applied via ADB

```bash
# Reduce animations for snappier UI (0.5x instead of 1x)
adb shell settings put global animator_duration_scale 0.5
adb shell settings put global transition_animation_scale 0.5
adb shell settings put global window_animation_scale 0.5

# Stay awake while charging (great for long gaming sessions)
adb shell settings put global stay_on_while_plugged_in 3

# 10-minute screen timeout
adb shell settings put system screen_off_timeout 600000
```

---

## Samsung DeX Support

Samsung DeX was **kept enabled** so the device can be connected to a monitor or TV for big-screen gaming. All emulators work in DeX mode.

### How to Use DeX
1. Connect the S23 Ultra to a monitor/TV via USB-C to HDMI adapter or Samsung DeX dock
2. DeX mode launches automatically
3. Pair a Bluetooth controller for the best experience
4. Launch games from Daijisho or individual emulators

---

## Installed Apps Summary

| App | Package Name | Purpose |
|-----|-------------|---------|
| Aurora Store | `com.aurora.store` | Anonymous Google Play access |
| F-Droid | `org.fdroid.fdroid` | Open source app store |
| RetroArch | `com.retroarch.aarch64` | Multi-system emulator (17+ systems) |
| Lemuroid | `com.swordfish.lemuroid` | Simplified multi-system emulator |
| PPSSPP | `org.ppsspp.ppsspp` | PSP emulator |
| Dolphin | `org.dolphinemu.dolphinemu` | GameCube / Wii emulator |
| NetherSX2 | `xyz.aethersx2.android` | PS2 emulator |
| Azahar (Lime3DS) | `io.github.lime3ds.android` | 3DS emulator |
| Flycast | `com.flycast.emulator` | Dreamcast / Naomi emulator |
| Daijisho | `com.magneticchen.daijishou` | Retro game launcher |
| Minecraft | `com.mojang.minecraftpe` | Minecraft Bedrock Edition |

---

## Troubleshooting

### Restore a Removed Package
```bash
adb shell cmd package install-existing <package.name>
```

### Full Factory Reset Restore
All removed packages will be restored on factory reset since we used `pm uninstall -k --user 0` (user-level removal only).

### ADB Not Detecting Device
- Check USB cable supports data transfer (not charge-only)
- Toggle USB Debugging off and on
- Try a different USB port
- Run `adb kill-server && adb start-server`

### Emulator Running Slow
- Close background apps
- Enable **Performance mode** in Settings > Battery
- In RetroArch: try different video drivers (Vulkan recommended for S23 Ultra)
- In Dolphin: enable **Skip EFB Access from CPU**
- In NetherSX2: try **Vulkan** renderer, enable **EE Recompiler** and **VU Recompiler**

### Controller Not Working
- Pair via Bluetooth in Settings
- In each emulator, go to controller settings and map buttons
- Xbox and PlayStation controllers work best
- 8BitDo controllers are also excellent

---

## Quick Reference: Debloat Package List

<details>
<summary>Click to expand full list of 129 removed packages</summary>

### Facebook
- `com.facebook.appmanager`
- `com.facebook.katana`
- `com.facebook.services`
- `com.facebook.system`

### Microsoft
- `com.microsoft.appmanager`
- `com.microsoft.skydrive`

### Bixby
- `com.samsung.android.bixby.agent`
- `com.samsung.android.bixby.wakeup`
- `com.samsung.android.bixbyvision.framework`
- `com.samsung.android.app.settings.bixby`
- `com.samsung.android.visionintelligence`

### Samsung Apps
- `com.samsung.android.app.tips`
- `com.samsung.android.themestore`
- `com.samsung.android.forest`
- `com.samsung.android.game.gamehome`
- `com.samsung.android.game.gametools`
- `com.samsung.android.game.gos`
- `com.samsung.android.stickercenter`
- `com.samsung.android.aremoji`
- `com.samsung.android.aremojieditor`
- `com.samsung.android.app.camera.sticker.facearavatar.preload`
- `com.samsung.android.ardrawing`
- `com.samsung.android.app.dressroom`
- `com.samsung.android.video`
- `com.samsung.android.app.sharelive`
- `com.samsung.android.smartmirroring`
- `com.samsung.android.audiomirroring`
- `com.samsung.android.app.watchmanagerstub`
- `com.samsung.android.da.daagent`
- `com.samsung.android.smartswitchassistant`
- `com.samsung.android.app.reminder`
- `com.samsung.android.calendar`
- `com.samsung.android.app.routines`
- `com.samsung.android.svcagent`
- `com.samsung.android.spayfw`
- `com.samsung.android.dynamiclock`
- `com.samsung.android.app.clipboardedge`
- `com.samsung.android.app.appsedge`
- `com.samsung.android.app.taskedge`
- `com.samsung.android.app.cocktailbarservice`
- `com.samsung.android.widget.pictureframe`
- `com.samsung.android.smartsuggestions`
- `com.samsung.android.app.interpreter`
- `com.samsung.android.app.readingglass`
- `com.samsung.android.callassistant`
- `com.samsung.android.visualars`
- `com.samsung.android.visual.cloudcore`
- `com.samsung.android.hdmapp`
- `com.samsung.storyservice`
- `com.samsung.petservice`
- `com.samsung.mediasearch`
- `com.samsung.videoscan`
- `com.samsung.crane`
- `com.samsung.gpuwatchapp`
- `com.samsung.sait.sohservice`

### Samsung Security & Knox
- `com.samsung.android.samsungpassautofill`
- `com.samsung.android.scloud`
- `com.samsung.android.shortcutbackupservice`
- `com.samsung.knox.securefolder`
- `com.samsung.android.knox.analytics.uploader`
- `com.samsung.android.knox.containercore`
- `com.samsung.android.container`
- `com.samsung.klmsagent`
- `com.samsung.android.fmm`

### Samsung System
- `com.sec.android.desktopmode.uiservice` *(re-enabled for DeX)*
- `com.samsung.android.smartcallprovider`
- `com.samsung.android.smartface`
- `com.samsung.android.smartface.overlay`
- `com.samsung.android.singletake.service`
- `com.samsung.android.wifi.ai`
- `com.samsung.android.beaconmanager`
- `com.sec.android.app.samsungapps`
- `com.wsomacp`
- `com.samsung.android.kidsinstaller`
- `com.samsung.android.app.parentalcare`
- `com.samsung.ssu`
- `com.samsung.android.app.updatecenter`
- `com.samsung.android.easysetup`
- `com.samsung.android.app.kfa`
- `com.samsung.android.dbsc`
- `com.samsung.android.dqagent`
- `com.samsung.android.gru`
- `com.samsung.oda.service`
- `com.samsung.android.bbc.bbcagent`
- `com.samsung.android.ConnectivityOverlay`
- `com.samsung.android.ConnectivityUxOverlay`
- `com.samsung.android.globalpostprocmgr`
- `com.samsung.cmh`
- `com.samsung.android.dsms`
- `com.samsung.android.app.dofviewer`
- `com.samsung.app.newtrim`
- `com.samsung.safetyinformation`
- `com.samsung.android.bluelightfilter`
- `com.samsung.android.brightnessbackupservice`
- `com.samsung.android.sm.devicesecurity`

### Samsung TTS Languages
- `com.samsung.SMT.lang_de_de_f00`
- `com.samsung.SMT.lang_es_es_f00`
- `com.samsung.SMT.lang_es_mx_f00`
- `com.samsung.SMT.lang_es_us_f00`
- `com.samsung.SMT.lang_fr_fr_f00`
- `com.samsung.SMT.lang_hi_in_f00`
- `com.samsung.SMT.lang_it_it_f00`
- `com.samsung.SMT.lang_pl_pl_f00`
- `com.samsung.SMT.lang_pt_br_f00`
- `com.samsung.SMT.lang_ru_ru_f00`
- `com.samsung.SMT.lang_th_th_f00`
- `com.samsung.SMT.lang_vi_vn_f00`

### Google
- `com.google.android.apps.googleassistant`
- `com.google.android.projection.gearhead`
- `com.google.android.apps.maps`
- `com.google.android.apps.tachyon`
- `com.google.android.feedback`

</details>

---

## License

This guide is provided as-is for educational purposes. Use at your own risk. ROMs must be legally obtained from games you own.
