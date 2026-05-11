#!/system/bin/sh
# Magisk Core SU Injector - metamount.sh
# Bind mount magisk su to /system/bin using directory overlay

LOGFILE="/data/adb/magisk/magisk.log"

log_msg() {
    echo "[$(date '+%m-%d %H:%M:%S.%N')] meta-suinject: $1" >> "$LOGFILE" 2>/dev/null
    echo "meta-suinject: $1"
}

# Find magisk tmpfs
MAGISK_TMP="$(/data/adb/magisk/magisk --path 2>/dev/null)"
if [ -z "$MAGISK_TMP" ]; then
    if [ -d "/sbin/.magisk" ]; then
        MAGISK_TMP="/sbin"
    elif [ -d "/debug_ramdisk/.magisk" ]; then
        MAGISK_TMP="/debug_ramdisk"
    fi
fi

log_msg "Magisk tmpfs: $MAGISK_TMP"
log_msg "MODULE_DIR: $MODULE_DIR"
log_msg "METAMODULE_DIR: $METAMODULE_DIR"

MAGISK_BIN="/data/adb/magisk/magisk"

if [ ! -f "$MAGISK_BIN" ]; then
    log_msg "ERROR: magisk binary not found"
    exit 1
fi

# Method: Directory bind mount with Magisk identifier
# Copy entire /system/bin to tmpfs, add su, bind mount over original
SYSTEM_BIN_TMP="${MAGISK_TMP}/.magisk/system_bin_overlay"

log_msg "Creating system/bin overlay in tmpfs (Magisk branded)"
mkdir -p "$SYSTEM_BIN_TMP"

# Copy all existing binaries (preserving permissions)
cp -a /system/bin/* "$SYSTEM_BIN_TMP/" 2>/dev/null

# Add su as a copy of magisk
cp -af "$MAGISK_BIN" "$SYSTEM_BIN_TMP/su"
chmod 755 "$SYSTEM_BIN_TMP/su"
chown root:root "$SYSTEM_BIN_TMP/su"

# Also add common su locations as symlinks
ln -sf "$SYSTEM_BIN_TMP/su" "$SYSTEM_BIN_TMP/supolicy" 2>/dev/null

# Verify copy
if [ ! -f "$SYSTEM_BIN_TMP/su" ]; then
    log_msg "ERROR: Failed to create su in overlay"
    exit 1
fi

log_msg "Overlay ready, performing Magisk-branded directory bind mount"

# Bind mount the overlay directory over /system/bin
# Note: bind mount does not support source/dev parameters like overlayfs,
# but we brand this as Magisk mount in logs and environment.
mount -o bind "$SYSTEM_BIN_TMP" /system/bin

if [ $? -eq 0 ]; then
    log_msg "SUCCESS: /system/bin Magisk overlay mounted with su"

    # Mark mount as Magisk-owned for tracking
    echo "Magisk" > "${MAGISK_TMP}/.magisk/mount_identity" 2>/dev/null || true

    # Handle /system/xbin if it exists
    if [ -d "/system/xbin" ]; then
        XBIN_TMP="${MAGISK_TMP}/.magisk/system_xbin_overlay"
        mkdir -p "$XBIN_TMP"
        cp -a /system/xbin/* "$XBIN_TMP/" 2>/dev/null
        ln -sf /system/bin/su "$XBIN_TMP/su" 2>/dev/null
        mount -o bind "$XBIN_TMP" /system/xbin
        log_msg "SUCCESS: /system/xbin Magisk overlay mounted"
    fi

    # Final verification
    if [ -f "/system/bin/su" ]; then
        log_msg "Verification: /system/bin/su is available (Magisk branded)"
    else
        log_msg "WARNING: su still not accessible"
    fi
else
    log_msg "ERROR: Directory bind mount failed"
    exit 1
fi
