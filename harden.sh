#!/bin/bash
# ============================================================
# S23 Ultra FunBox - Privacy Hardening Script
# Removes tracking, telemetry, analytics, and ad services.
# Configures private DNS, disables sensors used for tracking,
# and locks down the device for a kid-friendly experience.
#
# Usage: ./harden.sh [--tracking-only] [--dns-only] [--settings-only]
#        ./harden.sh           (runs everything)
#        ./harden.sh --audit   (scan for remaining trackers)
# ============================================================

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$SCRIPT_DIR/harden.log"

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

remove_pkg() {
    local pkg="$1"
    local result
    result=$(adb shell pm uninstall -k --user 0 "$pkg" 2>&1)
    if echo "$result" | grep -q "Success"; then
        log "[REMOVED] $pkg"
        return 0
    elif echo "$result" | grep -q "not installed"; then
        return 1
    else
        warn "[FAIL] $pkg - $result"
        return 1
    fi
}

# ============================================================
# Pre-flight
# ============================================================
preflight() {
    header "Pre-flight Checks"

    if ! command -v adb &>/dev/null; then
        err "ADB not found."
        exit 1
    fi

    local device_count
    device_count=$(adb devices | grep -c 'device$' || true)
    if [ "$device_count" -eq 0 ]; then
        err "No device detected. Enable USB Debugging and reconnect."
        exit 1
    fi

    log "Device connected: $(adb devices | grep 'device$' | head -1 | awk '{print $1}')"
}

# ============================================================
# Remove tracking / telemetry / analytics packages
# ============================================================
remove_tracking() {
    header "Removing Tracking & Telemetry Packages"

    local success=0 skip=0

    # --- Samsung Tracking & Analytics ---
    local SAMSUNG_TRACKING=(
        "com.samsung.android.da.daagent"              # Device Analytics Agent
        "com.samsung.android.rubin.app"               # Samsung Rubin AI/ML data collection
        "com.samsung.android.mobileservice"           # Samsung Mobile Services
        "com.samsung.android.sdm.config"              # Samsung Device Management
        "com.samsung.android.advertisingid"            # Samsung Advertising ID
        "com.samsung.android.ads.adid"                # Samsung Ad ID
        "com.samsung.android.app.usage"               # Samsung Usage Reporter
        "com.sec.android.diagmonagent"                # Diagnostic Monitor Agent
        "com.samsung.android.dqagent"                 # Device Quality Agent
        "com.samsung.android.intelligenceservice2"    # Intelligence Service
        "com.samsung.android.mapsagent"               # Samsung Location Tracking
        "com.samsung.android.customization.service"   # Customization Service (usage tracking)
        "com.samsung.android.service.peoplestripe"    # People Stripe
        "com.samsung.android.pushservice"             # Samsung Push Service
        "com.samsung.android.samsungpass"             # Samsung Pass (biometric telemetry)
        "com.samsung.android.samsungpassautofill"     # Samsung Pass Autofill
        "com.samsung.android.authfw"                  # Authentication Framework
        "com.samsung.android.app.spage"               # Samsung Free / Daily
        "com.samsung.android.mcfserver"               # Multi-Connect Framework
        "com.samsung.android.networkdiagnostic"       # Network Diagnostic
        "com.samsung.android.strangecloud"            # Samsung Cloud
        "com.samsung.android.scloud"                  # Samsung Cloud

        # Knox (phones home)
        "com.samsung.android.knox.enrollment"
        "com.samsung.android.knox.pushmanager"
        "com.samsung.android.knox.analytics.uploader"
        "com.samsung.android.knox.containercore"
        "com.samsung.android.knox.kpecore"
        "com.sec.enterprise.knox.attestation"

        # Bixby (always-listening)
        "com.samsung.android.bixby.service"
        "com.samsung.android.bixby.agent"
        "com.samsung.android.bixby.agent.dummy"
        "com.samsung.android.bixby.wakeup"
        "com.samsung.systemui.bixby2"
        "com.samsung.android.visionintelligence"

        # Samsung Browser (heavy telemetry)
        "com.sec.android.app.sbrowser"

        # Samsung Find My Mobile (location tracking)
        "com.samsung.android.fmm"
    )

    # --- Google Tracking & Analytics ---
    local GOOGLE_TRACKING=(
        "com.google.android.adservices.api"           # Google Ad Services
        "com.google.mainline.adservices"              # Mainline Ad Services
        "com.google.mainline.telemetry"               # Google Mainline Telemetry
        "com.google.android.ext.services"             # Ext Services (ad ML)
        "com.google.android.gms.policy_sidecar_aps"  # GMS Policy Sidecar
        "com.google.android.feedback"                 # Google Feedback
        "com.google.android.apps.wellbeing"           # Digital Wellbeing (telemetry)
        "com.google.android.apps.turbo"               # Device Health Services
        "com.google.android.as"                       # Android System Intelligence
        "com.google.android.as.oss"                   # Private Compute Services (federated analytics)
        "com.google.android.partnersetup"             # Partner Setup
        "com.google.android.marvin.recommendation"    # Google App Suggestions
        "com.google.android.configupdater"            # Config Updater
        "com.google.android.onetimeinitializer"       # One Time Initializer
        "com.google.android.googlequicksearchbox"     # Google Search Bar
        "com.google.android.apps.googleassistant"     # Google Assistant
        "com.google.android.tts"                      # Google TTS (phones home)
        "com.google.android.printservice.recommendation" # Print Recommendations
        "com.google.android.apps.restore"             # Backup/Restore Telemetry
        "com.google.ar.lens"                          # Google Lens
        "com.google.android.youtube"                  # YouTube (use NewPipe instead)
        "com.google.android.apps.youtube.music"       # YouTube Music
    )

    # --- Carrier / Third-party Tracking ---
    local OTHER_TRACKING=(
        "com.facebook.appmanager"
        "com.facebook.system"
        "com.facebook.services"
        "com.facebook.katana"
        "com.sec.android.app.chromecustomizations"    # Chrome Customizations
        "com.linkedin.android"
        "com.spotify.music"
        "com.netflix.mediaclient"
        "com.netflix.partner.activation"
    )

    echo -e "${BOLD}Samsung tracking packages:${NC}"
    for pkg in "${SAMSUNG_TRACKING[@]}"; do
        remove_pkg "$pkg" && ((success++)) || ((skip++))
    done

    echo -e "\n${BOLD}Google tracking packages:${NC}"
    for pkg in "${GOOGLE_TRACKING[@]}"; do
        remove_pkg "$pkg" && ((success++)) || ((skip++))
    done

    echo -e "\n${BOLD}Third-party tracking packages:${NC}"
    for pkg in "${OTHER_TRACKING[@]}"; do
        remove_pkg "$pkg" && ((success++)) || ((skip++))
    done

    echo ""
    log "Tracking removal: ${success} removed, ${skip} skipped/already gone"
}

# ============================================================
# Configure Private DNS (ad + tracker + adult content blocking)
# ============================================================
configure_dns() {
    header "Configuring Private DNS"

    echo -e "Select a Private DNS provider:\n"
    echo "  1) AdGuard Family (blocks ads, trackers, adult content) [RECOMMENDED]"
    echo "  2) AdGuard Default (blocks ads + trackers only)"
    echo "  3) Mullvad Extended (blocks ads, trackers, malware, adult, gambling, social)"
    echo "  4) Cloudflare Families (blocks malware + adult content)"
    echo "  5) Quad9 (blocks malware, no logging)"
    echo "  6) Custom hostname"
    echo "  7) Skip"
    echo ""

    local choice
    read -r -p "Choice [1]: " choice
    choice="${choice:-1}"

    local dns_host=""
    case "$choice" in
        1) dns_host="family.adguard-dns.com" ;;
        2) dns_host="dns.adguard-dns.com" ;;
        3) dns_host="all.dns.mullvad.net" ;;
        4) dns_host="family.cloudflare-dns.com" ;;
        5) dns_host="dns.quad9.net" ;;
        6) read -r -p "Enter DNS hostname: " dns_host ;;
        7) log "DNS configuration skipped"; return ;;
        *) dns_host="family.adguard-dns.com" ;;
    esac

    adb shell settings put global private_dns_mode hostname
    adb shell settings put global private_dns_specifier "$dns_host"
    log "Private DNS set to: $dns_host"
}

# ============================================================
# Apply privacy settings via ADB
# ============================================================
apply_privacy_settings() {
    header "Applying Privacy Settings"

    # --- Disable Google Telemetry ---
    echo -e "${BOLD}Google telemetry:${NC}"
    adb shell settings put global upload_apk_enable 0 && log "Disabled: APK upload"
    adb shell settings put global send_action_app_error 0 && log "Disabled: App error reporting"
    adb shell settings put global personalized_ad_enabled 0 && log "Disabled: Personalized ads"
    adb shell settings put global limit_ad_tracking 1 && log "Enabled: Limit ad tracking"
    adb shell settings put global bugreport_in_power_menu 0 && log "Disabled: Bug report in power menu"

    # --- Disable Location Tracking ---
    echo -e "\n${BOLD}Location hardening:${NC}"
    adb shell settings put global wifi_scan_always_enabled 0 && log "Disabled: Background WiFi scanning"
    adb shell settings put global ble_scan_always_enabled 0 && log "Disabled: Background Bluetooth scanning"
    adb shell settings put global nearby_scanning_enabled 0 && log "Disabled: Nearby device scanning"
    adb shell settings put global nearby_streaming_enabled 0 && log "Disabled: Nearby streaming"

    # --- Disable Network Analytics ---
    echo -e "\n${BOLD}Network analytics:${NC}"
    adb shell settings put global network_scoring_provisioned 0 && log "Disabled: Network scoring"
    adb shell settings put global network_recommendations_enabled 0 && log "Disabled: Network recommendations"
    adb shell settings put global wifi_watchdog_on 0 && log "Disabled: WiFi watchdog"

    # --- Redirect Captive Portal (away from Google) ---
    echo -e "\n${BOLD}Captive portal redirect:${NC}"
    adb shell settings put global captive_portal_http_url "http://captiveportal.kuketz.de" && log "Captive portal HTTP: kuketz.de"
    adb shell settings put global captive_portal_https_url "https://captiveportal.kuketz.de" && log "Captive portal HTTPS: kuketz.de"
    adb shell settings put global captive_portal_fallback_url "http://captiveportal.kuketz.de"
    adb shell settings put global captive_portal_other_fallback_urls "http://captiveportal.kuketz.de"

    # --- Samsung Telemetry ---
    echo -e "\n${BOLD}Samsung telemetry:${NC}"
    adb shell settings put secure samsung_errorlog_agree 0 && log "Disabled: Samsung error logging"
    adb shell settings put system samsung_errorlog_agree 0
    adb shell settings put secure diag_charged 0 && log "Disabled: Samsung diagnostics"
    adb shell settings put secure customization_service 0 && log "Disabled: Customization service"
    adb shell settings put system intelligenceservice_key 0 && log "Disabled: Intelligence service"
    adb shell settings put system marketing_push_agree 0 && log "Disabled: Samsung marketing"
    adb shell settings put system experience_improvement_program 0 && log "Disabled: Experience improvement program"
    adb shell settings put secure knox_analytics_enabled 0 && log "Disabled: Knox analytics"
    adb shell settings put global samsung_device_analytics 0 && log "Disabled: Samsung device analytics"
    adb shell settings put secure log_status 0 && log "Disabled: Log status"

    # --- Lock Screen Privacy ---
    echo -e "\n${BOLD}Lock screen privacy:${NC}"
    adb shell settings put secure lock_screen_show_notifications 0 && log "Disabled: Lock screen notifications"
    adb shell settings put secure lock_screen_allow_private_notifications 0 && log "Disabled: Private notification content on lock screen"

    # --- Restrict Background Data ---
    # NOTE: restrict-background can break app functionality (emulator downloads,
    # launcher sync, etc). Disabled by default. Uncomment if you want it.
    # echo -e "\n${BOLD}Network restrictions:${NC}"
    # adb shell cmd netpolicy set restrict-background true && log "Enabled: Restrict background data"

    # --- Disable ADB over WiFi (security) ---
    echo -e "\n${BOLD}Security hardening:${NC}"
    adb shell settings put global adb_wifi_enabled 0 && log "Disabled: ADB over WiFi"

    # --- Disable Smart Features That Track ---
    adb shell settings put secure adaptive_sleep 0 && log "Disabled: Adaptive sleep"
    adb shell settings put secure assist_gesture_enabled 0 && log "Disabled: Assist gesture"
    adb shell settings put secure assist_gesture_wake_enabled 0 && log "Disabled: Assist wake gesture"
}

# ============================================================
# Audit: scan for remaining tracking packages
# ============================================================
audit() {
    header "Privacy Audit - Scanning for Remaining Trackers"

    echo -e "${BOLD}Potential tracking packages still installed:${NC}\n"

    local patterns=(
        "analytics"
        "diagnostic"
        "telemetry"
        "tracking"
        "adservice"
        "advertisingid"
        "ads.adid"
        "usage"
        "rubin"
        "diagmon"
        "pushservice"
        "mapsagent"
        "customization"
        "spage"
        "feedback"
        "wellbeing"
        "turbo"
        "intelligence"
        "bixby"
    )

    local pattern
    pattern=$(IFS='|'; echo "${patterns[*]}")

    local found
    found=$(adb shell pm list packages 2>/dev/null | sed 's/package://' | grep -iE "$pattern" | sort)

    if [ -z "$found" ]; then
        log "No known tracking packages found. Device is clean."
    else
        echo "$found" | while read -r pkg; do
            warn "Still installed: $pkg"
        done
        echo ""
        warn "Some of these may be system-critical. Review before removing."
    fi

    echo ""
    echo -e "${BOLD}Current Privacy DNS:${NC}"
    local dns_mode dns_host
    dns_mode=$(adb shell settings get global private_dns_mode 2>/dev/null)
    dns_host=$(adb shell settings get global private_dns_specifier 2>/dev/null)
    echo "  Mode: $dns_mode"
    echo "  Host: $dns_host"

    echo ""
    echo -e "${BOLD}Ad Tracking Status:${NC}"
    echo "  Personalized ads: $(adb shell settings get global personalized_ad_enabled 2>/dev/null)"
    echo "  Limit ad tracking: $(adb shell settings get global limit_ad_tracking 2>/dev/null)"

    echo ""
    echo -e "${BOLD}Background Scanning:${NC}"
    echo "  WiFi scan always: $(adb shell settings get global wifi_scan_always_enabled 2>/dev/null)"
    echo "  BLE scan always: $(adb shell settings get global ble_scan_always_enabled 2>/dev/null)"
    echo "  Nearby scanning: $(adb shell settings get global nearby_scanning_enabled 2>/dev/null)"
}

# ============================================================
# Main
# ============================================================
main() {
    echo -e "${CYAN}${BOLD}"
    echo "  ╔═══════════════════════════════════════════╗"
    echo "  ║   S23 Ultra FunBox - Privacy Hardening    ║"
    echo "  ║   Getting as close to GrapheneOS as we    ║"
    echo "  ║   can on Samsung hardware.                ║"
    echo "  ╚═══════════════════════════════════════════╝"
    echo -e "${NC}"

    : > "$LOG_FILE"

    case "${1:-all}" in
        --tracking-only)
            preflight
            remove_tracking
            ;;
        --dns-only)
            preflight
            configure_dns
            ;;
        --settings-only)
            preflight
            apply_privacy_settings
            ;;
        --audit)
            preflight
            audit
            ;;
        all|"")
            preflight
            remove_tracking
            configure_dns
            apply_privacy_settings
            audit
            ;;
        *)
            echo "Usage: $0 [--tracking-only|--dns-only|--settings-only|--audit]"
            echo ""
            echo "  (no args)        Run full hardening"
            echo "  --tracking-only  Only remove tracking packages"
            echo "  --dns-only       Only configure Private DNS"
            echo "  --settings-only  Only apply privacy settings"
            echo "  --audit          Scan for remaining trackers"
            exit 1
            ;;
    esac

    echo ""
    header "Hardening Complete"
    log "Log saved to: $LOG_FILE"
    echo ""
    echo -e "${BOLD}Recommended next steps:${NC}"
    echo "  1. Install RethinkDNS from F-Droid (firewall + DNS blocker)"
    echo "  2. Install Mull browser from F-Droid (hardened Firefox)"
    echo "  3. Use Aurora Store anonymously instead of Google Play"
    echo "  4. On the phone: Settings > Privacy > Customization Service > OFF"
    echo "  5. On the phone: Settings > Privacy > Send diagnostic data > OFF"
    echo ""
}

main "$@"
