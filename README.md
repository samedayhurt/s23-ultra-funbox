# Samsung Galaxy S23 Ultra - Kid-Friendly Emulation Box Setup Guide

Turn a Samsung Galaxy S23 Ultra into a dedicated, privacy-hardened emulation and gaming device for kids. This guide removes Samsung bloatware, strips tracking/telemetry, installs emulators for 17+ retro systems (including Nintendo Switch), adds kid-friendly apps, and configures a game launcher as the home screen.

**Three scripts, one command each:**
- `setup.sh` - Full setup: debloat, download emulators, install, configure launcher
- `harden.sh` - Privacy hardening: remove trackers, configure DNS, lock down telemetry
- `debloat.sh` - Standalone debloat script (subset of setup.sh)

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
| **Citron** | Nintendo Switch | [git.citron-emu.org](https://git.citron-emu.org/citron-emu/Citron/releases) |

```bash
wget "https://www.ppsspp.org/files/1_20_3/ppsspp.apk" -O ppsspp.apk
wget -L "https://dl.dolphin-emu.org/releases/2603a/dolphin-2603a.apk" -O dolphin.apk
wget -L "https://github.com/azahar-emu/azahar/releases/download/2124.3/azahar-2124.3-android-vanilla.apk" -O azahar-3ds.apk
wget -L "https://github.com/flyinghead/flycast/releases/download/v2.6/flycast-2.6.apk" -O flycast.apk
wget -L "https://git.citron-emu.org/citron-emu/Citron/releases/download/2026.03.12/app-mainline-release.apk" -O citron-switch.apk

adb install ppsspp.apk
adb install dolphin.apk
adb install azahar-3ds.apk
adb install flycast.apk
adb install citron-switch.apk
adb install NetherSX2.apk  # Provide your own APK
```

> **Note on Switch emulation:** Citron requires `prod.keys` and firmware files dumped from your own Nintendo Switch console. Place them in the Citron app's data directory. Without these files, games will not boot.

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
| Switch | Playable (many games) | Citron (requires keys + firmware from your Switch) |

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

Via ADB:
```bash
adb shell cmd package set-home-activity com.magneticchen.daijishou/.activities.BootstrapActivity
```

### Grant Storage Permission

Daijisho uses Android's Storage Access Framework. Grant read permission via ADB:
```bash
adb shell pm grant com.magneticchen.daijishou android.permission.READ_EXTERNAL_STORAGE
```

### Configure Platforms

The `setup.sh` script downloads platform configs from the [Daijisho GitHub](https://github.com/TapiocaFox/Daijishou/tree/main/platforms) and pushes them to `/sdcard/Daijishou/platforms/`. To load them:

**Method A - Download from built-in index (easiest):**
1. Open Daijisho
2. Tap the **menu icon** (top-right) > **Manage Platforms**
3. Tap **+** > **Download from Index**
4. Download each system you want (NES, SNES, PS2, etc.)
5. For each platform, tap it > **Sync Paths** > **Add** > browse to `/sdcard/ROMs/<system>/`
6. Tap **Sync** to scan for games

**Method B - Import from file:**
1. Open Daijisho > **Manage Platforms** > **+** > **Import from file**
2. Browse to `/sdcard/Daijishou/platforms/`
3. Select a platform JSON (e.g., `SonyPlayStation2.json`)
4. Set the Sync Path to the matching ROM folder

### Platform-to-Emulator Mapping

Each platform config already includes launch intents for the correct emulator. The configs reference these package names:

| Platform | Default Emulator | Package |
|----------|-----------------|---------|
| NES / SNES / GB / GBA / N64 / DS / Genesis | RetroArch | `com.retroarch.aarch64` |
| PSX (PS1) | RetroArch (Beetle PSX) | `com.retroarch.aarch64` |
| PS2 | NetherSX2 / AetherSX2 | `xyz.aethersx2.android` |
| PSP | PPSSPP | `org.ppsspp.ppsspp` |
| GameCube / Wii | Dolphin | `org.dolphinemu.dolphinemu` |
| Dreamcast | Flycast | `com.flycast.emulator` |
| 3DS | Azahar / Lime3DS | `io.github.lime3ds.android` |
| Switch | Citron | `org.citron.citron_emu` |

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
├── Switch/
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
| Citron | `org.citron.citron_emu` | Nintendo Switch emulator |
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

---

## Phase 7.5: Steam Gaming (Stream + Native x86)

The S23 Ultra can run Steam games two ways:

### Steam Link (Stream from your gaming PC)

Stream your full Steam library from any gaming PC on your network. Zero performance overhead - the PC does the rendering, the phone just displays it.

```bash
# Install from Google Play Store (no direct APK available)
adb shell am start -a android.intent.action.VIEW -d "market://details?id=com.valvesoftware.steamlink"
```

Then tap **Install** on the phone. After installing:
1. Open Steam Link on the phone
2. Make sure your gaming PC has Steam running
3. Both devices must be on the same network (5GHz WiFi recommended)
4. Pair a Bluetooth controller for the best experience
5. Works great with Samsung DeX on a monitor too

### Winlator (Run x86 Windows Games Locally)

[Winlator](https://github.com/brunodev85/winlator) runs Windows x86/x64 games directly on the phone using Wine + Box86/Box64 translation. No PC required.

```bash
wget -L "https://github.com/brunodev85/winlator/releases/download/v10.1.0/Winlator_10.1.apk" -O winlator.apk
adb install winlator.apk
```

**What runs well on Snapdragon 8 Gen 2:**
- Older/lighter Steam games (pre-2015 titles)
- Source engine games (Half-Life 2, Portal)
- Indie games, visual novels, older RPGs
- GOG classics

**What won't run well:**
- AAA games from 2020+
- Games requiring high-end GPU features
- Games with aggressive DRM

> **Note on Valve's ARM plans:** Valve is developing **FEX** (an x86-to-ARM translation layer) and **SteamOS for ARM** for their upcoming Steam Frame hardware (shipping 2026). This technology may eventually become available for other ARM devices, which would significantly improve Steam game compatibility on phones.

### Installed Steam Apps

| App | Package | Purpose |
|-----|---------|---------|
| Steam Link | `com.valvesoftware.steamlink` | Stream games from gaming PC |
| Winlator | `com.winlator.FLAVOR` | Run x86 Windows games locally |

---

## Phase 8: Privacy Hardening (Getting Close to GrapheneOS)

Since GrapheneOS only supports Pixel devices, we can't install it on a Samsung. But we can get surprisingly close by stripping out tracking, telemetry, and analytics at the ADB level.

### Run the Hardening Script

```bash
chmod +x harden.sh

# Full hardening (interactive DNS selection)
./harden.sh

# Or run individual phases
./harden.sh --tracking-only   # Remove tracking packages
./harden.sh --dns-only        # Configure Private DNS
./harden.sh --settings-only   # Apply privacy settings
./harden.sh --audit           # Scan for remaining trackers
```

### What the Hardening Script Does

#### 1. Removes Tracking Packages (28+ packages)

| Category | Packages Removed |
|----------|-----------------|
| **Samsung Analytics** | Device Analytics Agent, Rubin AI/ML, Device Quality Agent, Diagnostic Monitor, Usage Reporter, Samsung Mobile Services |
| **Samsung Ads** | Advertising ID, Ad ID service |
| **Google Telemetry** | Mainline Telemetry, Ad Services, Android System Intelligence, Private Compute Services, Device Health Services, Config Updater, Partner Setup |
| **Google Apps** | YouTube (use NewPipe instead), Google Search, Google TTS, Google Lens, Print Recommendations |
| **Samsung Spyware** | Find My Mobile, Samsung Pass, Bixby (always-listening), Maps Agent, Push Service, Knox analytics |
| **Third-party** | Facebook services, Chrome Customizations |

#### 2. Configures Private DNS (DNS-over-TLS)

Blocks ads, trackers, and adult content at the DNS level. Options include:

| Provider | Hostname | Blocks |
|----------|----------|--------|
| **AdGuard Family** (recommended) | `family.adguard-dns.com` | Ads, trackers, adult content |
| AdGuard Default | `dns.adguard-dns.com` | Ads, trackers |
| Mullvad Extended | `all.dns.mullvad.net` | Ads, trackers, malware, adult, gambling, social |
| Cloudflare Families | `family.cloudflare-dns.com` | Malware, adult content |
| Quad9 | `dns.quad9.net` | Malware |

#### 3. Applies Privacy Settings

- **Disables personalized ads** and enables ad tracking limits
- **Disables background WiFi/Bluetooth scanning** (used for location tracking)
- **Disables nearby device scanning**
- **Redirects captive portal checks** away from Google to a privacy-respecting server
- **Disables Samsung error logging**, marketing push, experience improvement program, Knox analytics
- **Hides lock screen notification content**
- **Restricts background data** for all apps
- **Disables ADB over WiFi** (security hardening)

### Recommended Privacy Apps (Install from F-Droid)

| App | Purpose |
|-----|---------|
| **RethinkDNS** | All-in-one firewall + DNS blocker + per-app network control |
| **Mull** | Privacy-hardened Firefox fork |
| **NewPipe** | YouTube without Google tracking (great for kids) |
| **Shelter** | Isolate apps in Android Work Profile |
| **Organic Maps** | Offline maps, no tracking |

### Manual Steps on the Phone

After running the script, also do these on the device itself:

1. **Settings > Privacy > Customization Service** - Turn OFF all toggles
2. **Settings > Privacy > Send diagnostic data** - Turn OFF
3. **Settings > Privacy > Ads** - Delete advertising ID, opt out
4. **Settings > Location > Improve accuracy** - Turn OFF WiFi and Bluetooth scanning
5. **Settings > Biometrics > More biometrics** - Turn OFF any Samsung Pass features

### How This Compares to GrapheneOS

| Feature | GrapheneOS | Our Setup |
|---------|-----------|-----------|
| Custom hardened kernel | Yes | No (Samsung kernel) |
| No Google services | Yes (optional sandboxed) | Partial (GMS still present for Play Store) |
| DNS-level blocking | Manual config | Yes (AdGuard Family DNS) |
| Tracker removal | N/A (never installed) | Yes (28+ packages removed via ADB) |
| Telemetry disabled | By default | Yes (via ADB settings) |
| Per-app firewall | Via apps | Yes (via RethinkDNS) |
| Verified boot | Yes | Yes (Samsung Knox, but with Samsung keys) |
| App sandboxing | Enhanced | Standard Android + Work Profile via Shelter |
| OTA updates | AOSP-based | Samsung (may re-enable some trackers) |

> **After Samsung OTA updates:** Some removed packages may be reinstalled. Re-run `./harden.sh --tracking-only` after each system update.

---

## License

This guide is provided as-is for educational purposes. Use at your own risk. ROMs must be legally obtained from games you own.
