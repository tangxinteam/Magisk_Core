#!/system/bin/sh
# Magisk Core SU Injector - service.sh
# Verify su injection is still active after boot

LOGFILE="/data/adb/magisk/magisk.log"

log_msg() {
    echo "[$(date '+%m-%d %H:%M:%S.%N')] meta-suinject: $1" >> "$LOGFILE" 2>/dev/null
}

# Check if /system/bin/su exists (should be in overlay)
if [ ! -f "/system/bin/su" ]; then
    log_msg "WARNING: /system/bin/su missing, attempting recovery"
    
    # Re-run metamount if script exists
    METAMOUNT="/data/adb/modules/meta-suinject/metamount.sh"
    if [ -f "$METAMOUNT" ]; then
        log_msg "Re-executing metamount.sh"
        /system/bin/sh "$METAMOUNT"
    fi
else
    # Verify it's actually magisk (not a broken symlink)
    if /system/bin/su -v >/dev/null 2>&1; then
        log_msg "Verification: su injection active"
    else
        log_msg "WARNING: /system/bin/su exists but not working"
    fi
fi
