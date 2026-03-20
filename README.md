# Samsung Galaxy S23 Ultra - Kid-Friendly Emulation Box

Turn a Samsung Galaxy S23 Ultra into a dedicated, privacy-hardened emulation and gaming device for kids. Removes Samsung bloatware, strips tracking/telemetry, installs emulators for 17+ retro systems (including Nintendo Switch and PS2), streams PC games via Steam Link, and configures a retro game launcher as the home screen.

## Quick Start

```bash
git clone https://github.com/samedayhurt/s23-ultra-funbox.git
cd s23-ultra-funbox

# Enable USB Debugging on the phone first (see below), then:
./setup.sh          # Debloat + install emulators + configure launcher
./harden.sh         # Strip tracking, configure private DNS, disable telemetry
```

### What's In the Box

| Script | What It Does |
|--------|-------------|
| `setup.sh` | Full automated setup: debloat, download & install all emulators/apps, create ROM directories, set Daijisho as launcher, apply performance tweaks |
| `harden.sh` | Privacy hardening: remove 27+ tracking packages, configure DNS-over-TLS, disable Samsung/Google analytics, lock down telemetry |
| `debloat.sh` | Standalone debloat-only script (subset of setup.sh) |

Each script supports flags for running individual phases. Run with `--help` for options.

---

## Prerequisites

- Samsung Galaxy S23 Ultra (Snapdragon 8 Gen 2)
- USB-C data cable (not charge-only)
- Computer with ADB installed
- USB Debugging enabled on the phone

### Enable USB Debugging

1. **Settings > About phone** - tap **Build number** 7 times
2. **Settings > Developer options** - enable **USB debugging**
3. Connect via USB, tap **Allow** on the debugging prompt (check "Always allow")
4. Set USB mode to **File Transfer / MTP**

```bash
adb devices   # Should show your device serial
```

---

## Phase 1: Debloat Samsung (112 packages)

Uses `pm uninstall -k --user 0` - safe, user-level only, **fully reversible via factory reset**.

```bash
./debloat.sh
# or: ./setup.sh --debloat-only
```

### What Gets Removed

| Category | Examples |
|----------|----------|
| **Facebook** | Facebook, Facebook Services, App Manager |
| **Microsoft** | OneDrive, App Manager |
| **Bixby** | Agent, Wakeup, Vision, Settings |
| **Samsung Apps** | Browser, Pay, Cloud, Calendar, Galaxy Store, Video, AR Zone/Emoji/Drawing, Game Launcher, Themes, Tips, Members, Kids Mode |
| **Samsung Smart** | Smart Suggestions, Smart Call, Smart Face, Smart Mirroring |
| **Knox** | Analytics, Container, Secure Folder, KLMS Agent |
| **TTS Languages** | 12 non-English language packs |
| **Google Bloat** | Assistant, Android Auto, Maps, Duo, Feedback |

### What We Keep

- Phone/Contacts, Camera, Keyboard, **Samsung DeX** (for monitor gaming)
- Core system services, WiFi, Bluetooth, NFC
- Google Play Store & Play Services, Chrome
- **`com.google.android.ext.services`** (required system service - see [Known Issues](#known-issues))

### Restore Any Package

```bash
adb shell cmd package install-existing <package.name>
```

---

## Phase 2: App Stores

| App | Source | Purpose |
|-----|--------|---------|
| **Aurora Store** | [F-Droid](https://f-droid.org/repo/com.aurora.store_73.apk) | Anonymous Google Play access |
| **F-Droid** | [f-droid.org](https://f-droid.org/F-Droid.apk) | Open source app store |

---

## Phase 3: Emulators

### Installed Emulators

| App | System(s) | Source |
|-----|-----------|--------|
| **RetroArch** | NES, SNES, GB/GBC/GBA, Genesis, Master System, Saturn, N64, DS, PSX, Dreamcast, + more | [buildbot.libretro.com](https://buildbot.libretro.com/stable/) |
| **Lemuroid** | Same as above (simpler UI) | [GitHub](https://github.com/Swordfish90/Lemuroid/releases) |
| **PPSSPP** | PSP | [ppsspp.org](https://www.ppsspp.org/download/) |
| **Dolphin** | GameCube / Wii | [dolphin-emu.org](https://dolphin-emu.org/download/) |
| **NetherSX2** | PS2 | Community builds |
| **Azahar (Lime3DS)** | Nintendo 3DS | [GitHub](https://github.com/azahar-emu/azahar/releases) |
| **Flycast** | Dreamcast / Naomi | [GitHub](https://github.com/flyinghead/flycast/releases) |
| **Citron** | Nintendo Switch | [git.citron-emu.org](https://git.citron-emu.org/citron-emu/Citron/releases) |

### Performance Chart (Snapdragon 8 Gen 2)

| System | Performance | Best Emulator |
|--------|-------------|---------------|
| NES / SNES / GB / GBC / GBA | Perfect | Lemuroid or RetroArch |
| Sega Genesis / Master System | Perfect | Lemuroid or RetroArch |
| N64 | Perfect | RetroArch (Mupen64Plus) |
| Nintendo DS | Perfect | Lemuroid or RetroArch |
| PSX (PS1) | Perfect | RetroArch (Beetle PSX HW) |
| Dreamcast | Perfect | Flycast |
| PSP | Perfect | PPSSPP |
| GameCube | Great | Dolphin |
| Wii | Good-Great | Dolphin |
| PS2 | Good (most games) | NetherSX2 |
| 3DS | Good (most games) | Azahar / Lime3DS |
| Switch | Playable (many games) | Citron |

### BIOS Files

Some emulators require BIOS files dumped from your own hardware:

| Emulator | System | BIOS Needed | Location on Device |
|----------|--------|-------------|-------------------|
| **NetherSX2** | PS2 | `scph39001.bin` (US) or any PS2 BIOS | `/sdcard/BIOS/PS2/` - app prompts on first launch |
| **Flycast** | Dreamcast | `dc_boot.bin`, `dc_flash.bin` | `/sdcard/flycast/data/` |
| **RetroArch** (PSX) | PS1 | `scph5501.bin` | `/sdcard/RetroArch/system/` |
| **Citron** | Switch | `prod.keys` + firmware `.nca` files | `/sdcard/citron/keys/` and `/sdcard/citron/nand/system/Contents/registered/` |
| **Azahar** | 3DS | AES keys (app prompts) | Configured in-app |

**No BIOS needed:** RetroArch (most cores), Lemuroid, PPSSPP, Dolphin

Push BIOS files via ADB:
```bash
adb push scph39001.bin /sdcard/BIOS/PS2/
adb push dc_boot.bin /sdcard/flycast/data/
adb push dc_flash.bin /sdcard/flycast/data/
adb push scph5501.bin /sdcard/RetroArch/system/
adb push prod.keys /sdcard/citron/keys/
adb push firmware/*.nca /sdcard/citron/nand/system/Contents/registered/
```

---

## Phase 4: Kid-Friendly Apps

| App | Install Method |
|-----|---------------|
| **Minecraft** | `adb install minecraft.apk` (provide your own) |
| **YouTube Kids** | Install from Aurora Store or Google Play on device |
| **Steam Link** | Install from Google Play: `adb shell am start -a android.intent.action.VIEW -d "market://details?id=com.valvesoftware.steamlink"` |

---

## Phase 5: Steam Gaming

### Steam Link (Stream from Gaming PC)

Stream your full Steam library. The PC renders, the phone displays. Zero performance overhead.

1. Install Steam Link from Google Play (see above)
2. Both devices on the same network (5GHz WiFi or wired via DeX dock)
3. Steam running on the PC
4. Pair a Bluetooth controller

Works great with Samsung DeX on a monitor.

### Winlator (Run x86 Windows Games Locally)

[Winlator](https://github.com/brunodev85/winlator) translates Windows x86/x64 games to ARM using Wine + Box86/Box64. No PC required.

```bash
wget -L "https://github.com/brunodev85/winlator/releases/download/v10.1.0/Winlator_10.1.apk" -O winlator.apk
adb install winlator.apk
```

**Runs well:** Pre-2015 titles, Source engine (HL2, Portal), indie games, GOG classics
**Won't run well:** Modern AAA, heavy GPU games, aggressive DRM

> **Valve's ARM future:** Valve is developing **FEX** (x86-to-ARM translation) and **SteamOS for ARM** for the Steam Frame (2026). This may eventually work on other ARM devices.

---

## Phase 6: Game Launcher (Daijisho)

[Daijisho](https://github.com/TapiocaFox/Daijishou) is a retro game launcher set as the home screen.

```bash
# Set as default launcher
adb shell cmd package set-home-activity com.magneticchen.daijishou/.activities.BootstrapActivity

# Grant storage access
adb shell pm grant com.magneticchen.daijishou android.permission.READ_EXTERNAL_STORAGE
```

### Adding Game Systems to Daijisho

Daijisho requires manual platform setup through its UI:

1. Open Daijisho on the phone
2. Tap **three-dot menu** (top-right) > **"Manage Platforms"**
3. Tap **+** > **"Download from Index"**
4. Download each system you want (e.g., "Sony PlayStation 2", "Nintendo Entertainment System")
5. Tap the downloaded platform > **"Sync Paths"** > **+**
6. Browse to the matching folder: **Internal Storage > ROMs > PS2** (or NES, SNES, etc.)
7. Tap **Sync** to scan for games
8. Repeat for each system

### Platform-to-Emulator Mapping

Each platform config includes launch intents for the correct emulator:

| Platform | Default Emulator | Package |
|----------|-----------------|---------|
| NES / SNES / GB / GBA / N64 / DS / Genesis | RetroArch | `com.retroarch.aarch64` |
| PSX (PS1) | RetroArch (Beetle PSX) | `com.retroarch.aarch64` |
| PS2 | NetherSX2 | `xyz.aethersx2.android` |
| PSP | PPSSPP | `org.ppsspp.ppsspp` |
| GameCube / Wii | Dolphin | `org.dolphinemu.dolphinemu` |
| Dreamcast | Flycast | `com.flycast.emulator` |
| 3DS | Azahar / Lime3DS | `io.github.lime3ds.android` |
| Switch | Citron | `org.citron.citron_emu` |

### Revert to Samsung Launcher

```bash
adb shell cmd package set-home-activity com.sec.android.app.launcher/.activities.LauncherActivity
```

---

## Phase 7: ROM Directory Structure

```
/sdcard/ROMs/
├── 3DS/        ├── NDS/        ├── PSX/
├── Dreamcast/  ├── NES/        ├── SNES/
├── GB/         ├── PS2/        ├── Saturn/
├── GBA/        ├── PSP/        ├── Switch/
├── GBC/        ├── GameCube/   └── Wii/
├── Genesis/    ├── MasterSystem/
├── N64/
```

```bash
# Transfer ROMs via ADB
adb push ~/ROMs/PS2/*.iso /sdcard/ROMs/PS2/
adb push ~/ROMs/SNES/*.sfc /sdcard/ROMs/SNES/
```

Or drag and drop via file manager in MTP mode.

---

## Phase 8: Performance Tweaks

```bash
# Reduce animations (0.5x)
adb shell settings put global animator_duration_scale 0.5
adb shell settings put global transition_animation_scale 0.5
adb shell settings put global window_animation_scale 0.5

# Stay awake while charging
adb shell settings put global stay_on_while_plugged_in 3

# 10-minute screen timeout
adb shell settings put system screen_off_timeout 600000
```

---

## Phase 9: Samsung DeX (Big Screen Gaming)

Samsung DeX is **kept enabled** for monitor/TV gaming. All emulators work in DeX.

1. USB-C to HDMI adapter or Samsung DeX dock
2. DeX launches automatically
3. Pair a Bluetooth controller
4. Launch games from Daijisho or emulators directly

---

## Phase 10: Privacy Hardening

Getting as close to GrapheneOS as possible on Samsung hardware.

```bash
./harden.sh                  # Full hardening (interactive DNS selection)
./harden.sh --tracking-only  # Remove tracking packages only
./harden.sh --dns-only       # Configure Private DNS only
./harden.sh --settings-only  # Apply privacy settings only
./harden.sh --audit          # Scan for remaining trackers
```

### What Gets Hardened

**Tracking packages removed (27+):**

| Category | What's Removed |
|----------|---------------|
| Samsung Analytics | Device Analytics, Rubin AI/ML, Diagnostic Monitor, Usage Reporter, Mobile Services |
| Samsung Ads | Advertising ID, Ad ID service |
| Google Telemetry | Mainline Telemetry, Ad Services, Android System Intelligence, Private Compute Services, Device Health |
| Google Apps | YouTube, Search, TTS, Lens, Print Recommendations |
| Samsung Spyware | Find My Mobile, Samsung Pass, Bixby (always-listening), Maps Agent, Push Service |
| Third-party | Facebook services, Chrome Customizations |

**Private DNS (DNS-over-TLS):**

| Provider | Hostname | Blocks |
|----------|----------|--------|
| **AdGuard Family** (default) | `family.adguard-dns.com` | Ads, trackers, adult content |
| AdGuard Default | `dns.adguard-dns.com` | Ads, trackers |
| Mullvad Extended | `all.dns.mullvad.net` | Ads, trackers, malware, adult, gambling, social |
| Cloudflare Families | `family.cloudflare-dns.com` | Malware, adult content |
| Quad9 | `dns.quad9.net` | Malware |

**Privacy settings applied:**
- Personalized ads disabled, ad tracking limited
- Background WiFi/Bluetooth scanning disabled
- Nearby device scanning disabled
- Captive portal redirected away from Google (to kuketz.de)
- Samsung error logging, marketing, analytics all disabled
- Lock screen notification content hidden
- ADB over WiFi disabled

### Recommended F-Droid Privacy Apps

| App | Purpose |
|-----|---------|
| **RethinkDNS** | All-in-one firewall + DNS blocker + per-app network control |
| **Mull** | Privacy-hardened Firefox fork |
| **NewPipe** | YouTube without Google tracking (great for kids) |
| **Shelter** | Isolate apps in Android Work Profile |

### Manual Steps on the Phone

1. **Settings > Privacy > Customization Service** - Turn OFF
2. **Settings > Privacy > Send diagnostic data** - Turn OFF
3. **Settings > Privacy > Ads** - Delete advertising ID, opt out
4. **Settings > Location > Improve accuracy** - Turn OFF WiFi/BT scanning

### GrapheneOS Comparison

| Feature | GrapheneOS | Our Setup |
|---------|-----------|-----------|
| Custom hardened kernel | Yes | No (Samsung kernel) |
| No Google services | Yes (optional sandboxed) | Partial (GMS for Play Store) |
| DNS-level blocking | Manual | Yes (AdGuard Family) |
| Tracker removal | N/A (never installed) | 27+ packages removed |
| Telemetry disabled | By default | Yes (via ADB) |
| Per-app firewall | Via apps | Via RethinkDNS |
| App sandboxing | Enhanced | Standard + Work Profile |

> **After OTA updates:** Re-run `./harden.sh --tracking-only` - Samsung may reinstall tracking packages.

---

## Installed Apps Summary

| App | Package | Purpose |
|-----|---------|---------|
| Aurora Store | `com.aurora.store` | Anonymous Play Store |
| F-Droid | `org.fdroid.fdroid` | Open source apps |
| RetroArch | `com.retroarch.aarch64` | Multi-system emulator |
| Lemuroid | `com.swordfish.lemuroid` | Simplified multi-system |
| PPSSPP | `org.ppsspp.ppsspp` | PSP |
| Dolphin | `org.dolphinemu.dolphinemu` | GameCube / Wii |
| NetherSX2 | `xyz.aethersx2.android` | PS2 |
| Azahar | `io.github.lime3ds.android` | 3DS |
| Flycast | `com.flycast.emulator` | Dreamcast |
| Citron | `org.citron.citron_emu` | Nintendo Switch |
| Daijisho | `com.magneticchen.daijishou` | Game launcher (home screen) |
| Winlator | `com.winlator.FLAVOR` | x86 Windows games |
| Minecraft | `com.mojang.minecraftpe` | Minecraft Bedrock |
| Steam Link | `com.valvesoftware.steamlink` | Stream from gaming PC |

---

## Known Issues

### CRITICAL: Do NOT remove `com.google.android.ext.services`

This is a **required Android system service** (`config_servicesExtensionPackage`). Removing it causes `PackageManagerService` to crash during boot, resulting in a bootloop that forces safe mode and eventually requires a factory reset.

The `harden.sh` script has been patched to skip this package. If you're manually removing packages, **never remove `com.google.android.ext.services`**.

**If you hit this bootloop:**
1. Boot into recovery (Power + Volume Up)
2. If ADB is available: `adb shell cmd package install-existing com.google.android.ext.services`
3. If not: select "Erase app data" (factory reset) - all system packages will be restored

### Factory Reset Behavior

`pm uninstall -k --user 0` is user-level removal. A factory reset **restores all removed packages**. You'll need to re-run the scripts after a reset. That's exactly what they're designed for - the whole setup is repeatable.

### Daijisho Shows No Games

Daijisho doesn't auto-detect ROMs. You must add platforms manually:
1. **Manage Platforms** > **+** > **Download from Index**
2. Download each system
3. Add **Sync Paths** pointing to `/sdcard/ROMs/<system>/`
4. Tap **Sync**

See [Phase 6](#phase-6-game-launcher-daijisho) for detailed steps.

### Emulator Can't Find ROMs/BIOS

Grant storage permission to the emulator:
```bash
adb shell pm grant <package.name> android.permission.READ_EXTERNAL_STORAGE
```

### ADB Not Detecting Device

- Verify USB cable supports data (not charge-only)
- Toggle USB Debugging off/on
- `adb kill-server && adb start-server`

### Emulator Performance Tips

- Enable **Performance mode** in Settings > Battery
- RetroArch: use **Vulkan** video driver
- Dolphin: enable **Skip EFB Access from CPU**
- NetherSX2: use **Vulkan** renderer, enable **EE/VU Recompiler**

### Controller Setup

- Pair via Bluetooth in Settings
- Xbox and PlayStation controllers work best
- 8BitDo controllers also excellent
- Map buttons in each emulator's controller settings

---

## License

This guide is provided as-is for educational purposes. Use at your own risk. ROMs and BIOS files must be legally obtained from hardware you own.
