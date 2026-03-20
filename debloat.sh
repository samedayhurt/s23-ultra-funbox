#!/bin/bash
# Samsung S23 Ultra Debloat Script
# Uses pm uninstall -k --user 0 (safe, reversible via factory reset)
# Does NOT touch system partition

BLOAT_PACKAGES=(
    # ===== FACEBOOK =====
    "com.facebook.appmanager"
    "com.facebook.katana"
    "com.facebook.services"
    "com.facebook.system"

    # ===== MICROSOFT =====
    "com.microsoft.appmanager"
    "com.microsoft.skydrive"

    # ===== BIXBY =====
    "com.samsung.android.bixby.agent"
    "com.samsung.android.bixby.wakeup"
    "com.samsung.android.bixbyvision.framework"
    "com.samsung.android.app.settings.bixby"
    "com.samsung.android.visionintelligence"

    # ===== SAMSUNG APPS (non-essential) =====
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

    # ===== SAMSUNG BROWSER & INTERNET =====
    "com.sec.android.app.sbrowser"
    "com.samsung.android.app.sbrowseredge"

    # ===== SAMSUNG PAY =====
    "com.samsung.android.samsungpay.gear"
    "com.samsung.android.samsungpassautofill"

    # ===== SAMSUNG CLOUD & BACKUP =====
    "com.samsung.android.scloud"
    "com.samsung.android.shortcutbackupservice"

    # ===== SAMSUNG SECURE FOLDER / KNOX (non-essential for kids) =====
    "com.samsung.knox.securefolder"
    "com.samsung.android.knox.analytics.uploader"
    "com.samsung.android.knox.containercore"
    "com.samsung.android.container"
    "com.samsung.klmsagent"

    # ===== SAMSUNG DEX =====
    "com.samsung.android.app.dexonpc"
    "com.sec.android.desktopmode.uiservice"

    # ===== SAMSUNG FIND MY MOBILE =====
    "com.samsung.android.fmm"

    # ===== AR ZONE / VISUAL =====
    "com.samsung.android.arzone"

    # ===== SAMSUNG TTS LANGUAGES (keep base, remove extras) =====
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

    # ===== SAMSUNG SMART FEATURES (not needed) =====
    "com.samsung.android.smartcallprovider"
    "com.samsung.android.smartface"
    "com.samsung.android.smartface.overlay"
    "com.samsung.android.singletake.service"
    "com.samsung.android.wifi.ai"
    "com.samsung.android.beaconmanager"

    # ===== SAMSUNG APPS STORE =====
    "com.sec.android.app.samsungapps"

    # ===== SAMSUNG HEALTH (if present) =====
    "com.sec.android.app.shealth"
    "com.samsung.android.shealth"

    # ===== SAMSUNG EMAIL =====
    "com.samsung.android.email.provider"
    "com.wsomacp"

    # ===== SAMSUNG MEMBERS =====
    "com.samsung.android.voc"

    # ===== SAMSUNG KIDS (we'll set up our own launcher) =====
    "com.samsung.android.kidsinstaller"
    "com.samsung.android.app.parentalcare"

    # ===== SAMSUNG SSU / UPDATE NAG =====
    "com.samsung.ssu"

    # ===== OTHER SAMSUNG BLOAT =====
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

    # ===== GOOGLE BLOAT (optional, keep core Google services) =====
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

SUCCESS=0
FAIL=0
SKIP=0

echo "========================================="
echo " Samsung S23 Ultra Debloat"
echo " Packages to process: ${#BLOAT_PACKAGES[@]}"
echo "========================================="

for pkg in "${BLOAT_PACKAGES[@]}"; do
    result=$(adb shell pm uninstall -k --user 0 "$pkg" 2>&1)
    if echo "$result" | grep -q "Success"; then
        echo "[REMOVED] $pkg"
        ((SUCCESS++))
    elif echo "$result" | grep -q "not installed"; then
        echo "[SKIP]    $pkg (not installed)"
        ((SKIP++))
    else
        echo "[FAIL]    $pkg - $result"
        ((FAIL++))
    fi
done

echo ""
echo "========================================="
echo " DEBLOAT COMPLETE"
echo " Removed: $SUCCESS"
echo " Skipped: $SKIP"
echo " Failed:  $FAIL"
echo "========================================="
