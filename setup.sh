#!/bin/bash
# ============================================================
# S23 Ultra FunBox - Complete Setup Script
# Turns a Samsung Galaxy S23 Ultra into a kid-friendly
# emulation and gaming device.
#
# Usage: ./setup.sh [--debloat-only] [--install-only] [--tweaks-only]
#        ./setup.sh                  (runs everything)
#        ./setup.sh --restore        (undo debloat)
# ============================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APK_DIR="$SCRIPT_DIR/apks"
LOG_FILE="$SCRIPT_DIR/setup.log"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

log() { echo -e "${GREEN}[+]${NC} $1"; echo "[+] $1" >> "$LOG_FILE"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; echo "[!] $1" >> "$LOG_FILE"; }
err() { echo -e "${RED}[X]${NC} $1"; echo "[X] $1" >> "$LOG_FILE"; }
header() { echo -e "\n${CYAN}${BOLD}=== $1 ===${NC}\n"; echo "=== $1 ===" >> "$LOG_FILE"; }

# ============================================================
# Pre-flight checks
# ============================================================
preflight() {
    header "Pre-flight Checks"

    if ! command -v adb &>/dev/null; then
        err "ADB not found. Install Android platform-tools first."
        exit 1
    fi
    log "ADB found: $(which adb)"

    local device_count
    device_count=$(adb devices | grep -c 'device$' || true)
    if [ "$device_count" -eq 0 ]; then
        err "No device detected. Enable USB Debugging and reconnect."
        echo ""
        echo "  1. Settings > About phone > Tap 'Build number' 7 times"
        echo "  2. Settings > Developer options > Enable 'USB debugging'"
        echo "  3. Reconnect USB and tap 'Allow' on the phone"
        exit 1
    fi

    local serial
    serial=$(adb devices | grep 'device$' | head -1 | awk '{print $1}')
    log "Device connected: $serial"

    local model
    model=$(adb shell getprop ro.product.model 2>/dev/null || echo "Unknown")
    log "Device model: $model"

    local android_ver
    android_ver=$(adb shell getprop ro.build.version.release 2>/dev/null || echo "Unknown")
    log "Android version: $android_ver"
}

# ============================================================
# Phase 1: Debloat
# ============================================================
debloat() {
    header "Phase 1: Debloating Samsung"

    local BLOAT_PACKAGES=(
        # Facebook
        "com.facebook.appmanager"
        "com.facebook.katana"
        "com.facebook.services"
        "com.facebook.system"

        # Microsoft
        "com.microsoft.appmanager"
        "com.microsoft.skydrive"

        # Bixby
        "com.samsung.android.bixby.agent"
        "com.samsung.android.bixby.wakeup"
        "com.samsung.android.bixbyvision.framework"
        "com.samsung.android.app.settings.bixby"
        "com.samsung.android.visionintelligence"

        # Samsung apps (non-essential)
        "com.samsung.android.app.tips"
        "com.samsung.android.themestore"
        "com.samsung.android.themecenter"
        "com.samsung.android.forest"
        "com.samsung.android.game.gamehome"
        "com.samsung.android.game.gametools"
        "com.samsung.android.game.gos"
        "com.samsung.android.stickercenter"
        "com.samsung.android.aremoji"
        "com.samsung.android.aremojieditor"
        "com.samsung.android.app.camera.sticker.facearavatar.preload"
        "com.samsung.android.ardrawing"
        "com.samsung.android.app.dressroom"
        "com.samsung.android.video"
        "com.samsung.android.app.sharelive"
        "com.samsung.android.smartmirroring"
        "com.samsung.android.audiomirroring"
        "com.samsung.android.app.watchmanagerstub"
        "com.samsung.android.da.daagent"
        "com.samsung.android.smartswitchassistant"
        "com.samsung.android.app.reminder"
        "com.samsung.android.calendar"
        "com.samsung.android.app.routines"
        "com.samsung.android.svcagent"
        "com.samsung.android.spayfw"
        "com.samsung.android.dynamiclock"
        "com.samsung.android.app.clipboardedge"
        "com.samsung.android.app.appsedge"
        "com.samsung.android.app.taskedge"
        "com.samsung.android.app.cocktailbarservice"
        "com.samsung.android.widget.pictureframe"
        "com.samsung.android.smartsuggestions"
        "com.samsung.android.app.interpreter"
        "com.samsung.android.app.readingglass"
        "com.samsung.android.callassistant"
        "com.samsung.android.visualars"
        "com.samsung.android.visual.cloudcore"
        "com.samsung.android.hdmapp"
        "com.samsung.storyservice"
        "com.samsung.petservice"
        "com.samsung.mediasearch"
        "com.samsung.videoscan"
        "com.samsung.crane"
        "com.samsung.gpuwatchapp"
        "com.samsung.sait.sohservice"

        # Samsung Browser
        "com.sec.android.app.sbrowser"
        "com.samsung.android.app.sbrowseredge"

        # Samsung Pay
        "com.samsung.android.samsungpay.gear"
        "com.samsung.android.samsungpassautofill"

        # Samsung Cloud & Backup
        "com.samsung.android.scloud"
        "com.samsung.android.shortcutbackupservice"

        # Knox / Secure Folder
        "com.samsung.knox.securefolder"
        "com.samsung.android.knox.analytics.uploader"
        "com.samsung.android.knox.containercore"
        "com.samsung.android.container"
        "com.samsung.klmsagent"

        # Find My Mobile
        "com.samsung.android.fmm"

        # AR Zone
        "com.samsung.android.arzone"

        # TTS language packs (keep English)
        "com.samsung.SMT.lang_de_de_f00"
        "com.samsung.SMT.lang_es_es_f00"
        "com.samsung.SMT.lang_es_mx_f00"
        "com.samsung.SMT.lang_es_us_f00"
        "com.samsung.SMT.lang_fr_fr_f00"
        "com.samsung.SMT.lang_hi_in_f00"
        "com.samsung.SMT.lang_it_it_f00"
        "com.samsung.SMT.lang_pl_pl_f00"
        "com.samsung.SMT.lang_pt_br_f00"
        "com.samsung.SMT.lang_ru_ru_f00"
        "com.samsung.SMT.lang_th_th_f00"
        "com.samsung.SMT.lang_vi_vn_f00"

        # Samsung Smart Features
        "com.samsung.android.smartcallprovider"
        "com.samsung.android.smartface"
        "com.samsung.android.smartface.overlay"
        "com.samsung.android.singletake.service"
        "com.samsung.android.wifi.ai"
        "com.samsung.android.beaconmanager"

        # Galaxy Store
        "com.sec.android.app.samsungapps"

        # Samsung Health
        "com.sec.android.app.shealth"
        "com.samsung.android.shealth"

        # Samsung Email
        "com.samsung.android.email.provider"
        "com.wsomacp"

        # Samsung Members
        "com.samsung.android.voc"

        # Samsung Kids (we use our own launcher)
        "com.samsung.android.kidsinstaller"
        "com.samsung.android.app.parentalcare"

        # Samsung Update Nag
        "com.samsung.ssu"

        # Other Samsung bloat
        "com.samsung.android.app.updatecenter"
        "com.samsung.android.easysetup"
        "com.samsung.android.app.kfa"
        "com.samsung.android.dbsc"
        "com.samsung.android.dqagent"
        "com.samsung.android.gru"
        "com.samsung.oda.service"
        "com.samsung.android.bbc.bbcagent"
        "com.samsung.android.ConnectivityOverlay"
        "com.samsung.android.ConnectivityUxOverlay"
        "com.samsung.android.globalpostprocmgr"
        "com.samsung.cmh"
        "com.samsung.android.dsms"
        "com.samsung.android.app.dofviewer"
        "com.samsung.app.newtrim"
        "com.samsung.safetyinformation"
        "com.samsung.android.bluelightfilter"
        "com.samsung.android.brightnessbackupservice"
        "com.samsung.android.sm.devicesecurity"

        # Google bloat
        "com.google.android.apps.googleassistant"
        "com.google.android.projection.gearhead"
        "com.google.android.apps.magazines"
        "com.google.android.videos"
        "com.google.android.music"
        "com.google.android.apps.docs"
        "com.google.android.apps.maps"
        "com.google.android.apps.tachyon"
        "com.google.android.apps.photos"
        "com.google.android.apps.wellbeing"
        "com.google.android.feedback"
        "com.google.android.apps.podcasts"
    )

    local success=0 fail=0 skip=0

    for pkg in "${BLOAT_PACKAGES[@]}"; do
        local result
        result=$(adb shell pm uninstall -k --user 0 "$pkg" 2>&1)
        if echo "$result" | grep -q "Success"; then
            log "[REMOVED] $pkg"
            ((success++))
        elif echo "$result" | grep -q "not installed"; then
            ((skip++))
        else
            warn "[FAIL] $pkg - $result"
            ((fail++))
        fi
    done

    echo ""
    log "Debloat complete: ${success} removed, ${skip} skipped, ${fail} failed"
}

# ============================================================
# Phase 2: Download APKs
# ============================================================
download_apks() {
    header "Phase 2: Downloading APKs"

    mkdir -p "$APK_DIR"

    declare -A DOWNLOADS=(
        ["aurora-store.apk"]="https://f-droid.org/repo/com.aurora.store_73.apk"
        ["f-droid.apk"]="https://f-droid.org/F-Droid.apk"
        ["retroarch.apk"]="https://buildbot.libretro.com/stable/1.22.2/android/RetroArch_aarch64.apk"
        ["ppsspp.apk"]="https://www.ppsspp.org/files/1_20_3/ppsspp.apk"
        ["dolphin.apk"]="https://dl.dolphin-emu.org/releases/2603a/dolphin-2603a.apk"
        ["flycast.apk"]="https://github.com/flyinghead/flycast/releases/download/v2.6/flycast-2.6.apk"
        ["daijisho.apk"]="https://github.com/TapiocaFox/Daijishou/releases/download/v1.5.0/416.apk"
        ["lemuroid.apk"]="https://github.com/Swordfish90/Lemuroid/releases/download/1.16.2/lemuroid-app-free-dynamic-release.apk"
        ["azahar-3ds.apk"]="https://github.com/azahar-emu/azahar/releases/download/2124.3/azahar-2124.3-android-vanilla.apk"
        ["citron-switch.apk"]="https://git.citron-emu.org/citron-emu/Citron/releases/download/2026.03.12/app-mainline-release.apk"
        ["winlator.apk"]="https://github.com/brunodev85/winlator/releases/download/v10.1.0/Winlator_10.1.apk"
    )

    # Steam Link must be installed from Play Store (no direct APK)
    warn "Steam Link: Install from Google Play Store on the device"
    warn "  Opening Play Store page now..."
    adb shell am start -a android.intent.action.VIEW -d "market://details?id=com.valvesoftware.steamlink" 2>/dev/null

    for filename in "${!DOWNLOADS[@]}"; do
        local url="${DOWNLOADS[$filename]}"
        local filepath="$APK_DIR/$filename"

        if [ -f "$filepath" ] && [ -s "$filepath" ]; then
            log "Already downloaded: $filename ($(du -h "$filepath" | cut -f1))"
            continue
        fi

        log "Downloading $filename..."
        if wget -q --show-progress -L "$url" -O "$filepath" 2>&1; then
            if [ -s "$filepath" ]; then
                log "Downloaded: $filename ($(du -h "$filepath" | cut -f1))"
            else
                err "Download empty: $filename"
                rm -f "$filepath"
            fi
        else
            err "Download failed: $filename"
            rm -f "$filepath"
        fi
    done

    echo ""
    log "Downloads complete. Contents of $APK_DIR:"
    ls -lhS "$APK_DIR/" 2>/dev/null || warn "APK directory is empty"
}

# ============================================================
# Phase 3: Install APKs
# ============================================================
install_apks() {
    header "Phase 3: Installing APKs"

    local success=0 fail=0

    # Install all APKs from the apks/ directory
    for apk in "$APK_DIR"/*.apk; do
        [ -f "$apk" ] || continue
        local name
        name=$(basename "$apk")
        log "Installing $name..."
        if adb install -r "$apk" 2>&1 | grep -q "Success"; then
            log "Installed: $name"
            ((success++))
        else
            err "Failed to install: $name"
            ((fail++))
        fi
    done

    # Install any APKs in the project root (e.g., user-provided minecraft)
    for apk in "$SCRIPT_DIR"/*.apk; do
        [ -f "$apk" ] || continue
        local name
        name=$(basename "$apk")
        log "Installing $name (from project root)..."
        if adb install -r "$apk" 2>&1 | grep -q "Success"; then
            log "Installed: $name"
            ((success++))
        else
            err "Failed to install: $name"
            ((fail++))
        fi
    done

    echo ""
    log "Install complete: ${success} installed, ${fail} failed"
}

# ============================================================
# Phase 4: Create ROM directories
# ============================================================
create_rom_dirs() {
    header "Phase 4: Creating ROM Directories"

    local systems=(
        NES SNES GB GBC GBA N64 NDS
        PSX PSP PS2
        Dreamcast GameCube Wii
        3DS Switch Genesis Saturn MasterSystem
    )

    adb shell mkdir -p /sdcard/ROMs 2>/dev/null
    for sys in "${systems[@]}"; do
        adb shell mkdir -p "/sdcard/ROMs/$sys" 2>/dev/null
        log "Created /sdcard/ROMs/$sys"
    done
}

# ============================================================
# Phase 5: Performance tweaks
# ============================================================
apply_tweaks() {
    header "Phase 5: Applying Performance Tweaks"

    # Faster animations
    adb shell settings put global animator_duration_scale 0.5
    log "Animator duration: 0.5x"

    adb shell settings put global transition_animation_scale 0.5
    log "Transition animations: 0.5x"

    adb shell settings put global window_animation_scale 0.5
    log "Window animations: 0.5x"

    # Gaming-friendly settings
    adb shell settings put global stay_on_while_plugged_in 3
    log "Stay awake while charging: enabled"

    adb shell settings put system screen_off_timeout 600000
    log "Screen timeout: 10 minutes"
}

# ============================================================
# Phase 6: Set Daijisho as default launcher
# ============================================================
set_launcher() {
    header "Phase 6: Setting Daijisho as Default Launcher"

    if adb shell pm list packages 2>/dev/null | grep -q "com.magneticchen.daijishou"; then
        # Set as default launcher
        adb shell cmd package set-home-activity com.magneticchen.daijishou/.activities.BootstrapActivity 2>&1
        log "Default launcher set to Daijisho"

        # Grant storage permission
        adb shell pm grant com.magneticchen.daijishou android.permission.READ_EXTERNAL_STORAGE 2>/dev/null

        # Download and push platform configs from Daijisho GitHub
        log "Downloading Daijisho platform configs..."
        local platforms_dir="/tmp/daijisho_platforms_$$"
        mkdir -p "$platforms_dir"
        local BASE="https://raw.githubusercontent.com/TapiocaFox/Daijishou/main/platforms"
        local platform_count=0
        for platform in \
            NintendoEntertainmentSystem SuperNintendoEntertainmentSystem \
            NintendoGameBoy NintendoGameBoyColor NintendoGameBoyAdvance \
            Nintendo64 NintendoDS Nintendo3DS NintendoGameCube \
            NintendoWii NintendoSwitch SonyPlayStation SonyPlayStation2 \
            PlayStationPortable Dreamcast SegaGenesis SegaMasterSystem SegaSaturn; do
            if wget -q "$BASE/$platform.json" -O "$platforms_dir/$platform.json" 2>/dev/null; then
                ((platform_count++))
            fi
        done
        adb shell mkdir -p /sdcard/Daijishou/platforms 2>/dev/null
        adb push "$platforms_dir/" /sdcard/Daijishou/platforms/ 2>/dev/null
        rm -rf "$platforms_dir"
        log "Pushed $platform_count platform configs to /sdcard/Daijishou/platforms/"
        log ""
        log "IMPORTANT: To activate platforms in Daijisho:"
        log "  1. Open Daijisho > top-right menu > 'Manage Platforms'"
        log "  2. Tap '+' > 'Download from Index'"
        log "  3. Download each system you want"
        log "  4. For each platform, tap it > 'Sync Paths' > add /sdcard/ROMs/<system>"
        log "  OR: Import from file > browse to /sdcard/Daijishou/platforms/"
    else
        warn "Daijisho not installed - skipping launcher setup"
    fi
}

# ============================================================
# Restore: Undo debloat
# ============================================================
restore() {
    header "Restoring Removed Packages"

    warn "This will attempt to restore all debloated packages."
    echo -e "${YELLOW}Press Ctrl+C within 5 seconds to cancel...${NC}"
    sleep 5

    local restored=0 failed=0

    # Read the log for removed packages
    if [ ! -f "$LOG_FILE" ]; then
        err "No setup log found. Cannot determine which packages were removed."
        err "To restore everything, perform a factory reset."
        exit 1
    fi

    while IFS= read -r line; do
        if echo "$line" | grep -q "\[REMOVED\]"; then
            local pkg
            pkg=$(echo "$line" | grep -oP '\[REMOVED\] \K\S+')
            if [ -n "$pkg" ]; then
                local result
                result=$(adb shell cmd package install-existing "$pkg" 2>&1)
                if echo "$result" | grep -q "installed for user"; then
                    log "Restored: $pkg"
                    ((restored++))
                else
                    warn "Could not restore: $pkg"
                    ((failed++))
                fi
            fi
        fi
    done < "$LOG_FILE"

    # Restore Samsung launcher
    adb shell cmd package set-home-activity com.sec.android.app.launcher/.activities.LauncherActivity 2>&1
    log "Samsung launcher restored as default"

    echo ""
    log "Restore complete: ${restored} restored, ${failed} failed"
}

# ============================================================
# Verify installation
# ============================================================
verify() {
    header "Verification"

    echo -e "${BOLD}Installed emulators & apps:${NC}"
    adb shell pm list packages 2>/dev/null | grep -iE \
        'retroarch|ppsspp|dolphin|flycast|daijisho|lemuroid|azahar|lime3ds|nethersx|aethersx|aurora|fdroid|minecraft' \
        | sed 's/package:/  /' | sort

    echo ""
    echo -e "${BOLD}ROM directories:${NC}"
    adb shell ls /sdcard/ROMs/ 2>/dev/null | sed 's/^/  /'

    echo ""
    echo -e "${BOLD}Default launcher:${NC}"
    adb shell cmd package resolve-activity --brief -a android.intent.action.MAIN -c android.intent.category.HOME 2>/dev/null | tail -1 | sed 's/^/  /'
}

# ============================================================
# Main
# ============================================================
main() {
    echo -e "${CYAN}${BOLD}"
    echo "  ╔═══════════════════════════════════════════╗"
    echo "  ║   S23 Ultra FunBox - Emulation Setup      ║"
    echo "  ║   github.com/samedayhurt/s23-ultra-funbox ║"
    echo "  ╚═══════════════════════════════════════════╝"
    echo -e "${NC}"

    : > "$LOG_FILE"

    case "${1:-all}" in
        --debloat-only)
            preflight
            debloat
            ;;
        --install-only)
            preflight
            download_apks
            install_apks
            ;;
        --tweaks-only)
            preflight
            apply_tweaks
            ;;
        --restore)
            preflight
            restore
            ;;
        --verify)
            preflight
            verify
            ;;
        all|"")
            preflight
            debloat
            download_apks
            install_apks
            create_rom_dirs
            apply_tweaks
            set_launcher
            verify
            ;;
        *)
            echo "Usage: $0 [--debloat-only|--install-only|--tweaks-only|--restore|--verify]"
            echo ""
            echo "  (no args)       Run full setup"
            echo "  --debloat-only  Only remove bloatware"
            echo "  --install-only  Only download & install emulators/apps"
            echo "  --tweaks-only   Only apply performance tweaks"
            echo "  --restore       Undo debloat and restore Samsung launcher"
            echo "  --verify        Check what's installed"
            exit 1
            ;;
    esac

    echo ""
    header "All Done"
    log "Setup log saved to: $LOG_FILE"
    echo ""
    echo -e "${GREEN}${BOLD}Your S23 Ultra FunBox is ready!${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. Transfer ROMs to /sdcard/ROMs/<system>/ on the device"
    echo "  2. Open Daijisho and configure platforms"
    echo "  3. Pair a Bluetooth controller"
    echo "  4. Install YouTube Kids from Aurora Store"
    echo ""
}

main "$@"
