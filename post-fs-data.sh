#!/system/bin/sh
# Magisk Core SU Injector - post-fs-data.sh
# Early stage setup for su injection

MAGISK_BIN="/data/adb/magisk/magisk"

# Verify magisk binary is available
if [ ! -f "$MAGISK_BIN" ]; then
    echo "meta-suinject: magisk binary not available yet"
    exit 0
fi

# Ensure /data/adb/magisk directory exists and has proper permissions
if [ -d "/data/adb/magisk" ]; then
    chmod 755 "/data/adb/magisk"
fi

echo "meta-suinject: post-fs-data setup complete"
