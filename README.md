# Meta SU Injector

A metamodule for Magisk_Core that provides `/system/bin/su` injection functionality.

## Purpose

Magisk_Core removed the magic mount system that was responsible for injecting `su` into `/system/bin`. This metamodule restores that functionality using bind mounts.

## How It Works

1. `metamount.sh` - Copies the magisk binary to tmpfs and bind mounts it as:
   - `/system/bin/su`
   - `/system/xbin/su` (if directory exists)

2. `post-fs-data.sh` - Early stage verification

3. `service.sh` - Runtime verification and recovery

## Installation

1. Zip the contents of this directory:
   ```bash
   cd meta-suinject
   zip -r ../meta-suinject.zip *
   ```

2. Install via Magisk Manager (Modules > Install from Storage)

3. Reboot

## Requirements

- Magisk_Core v30700+
- `/data/adb/magisk/magisk` binary must exist

## Notes

- This is a **metamodule**, meaning only one can be active at a time
- Installing this will replace any existing metamodule
- The bind mount survives reboots because it's established during each boot via `metamount.sh`

## Troubleshooting

If apps still cannot find su:
1. Check logs: `magisk --logcat | grep meta-suinject`
2. Verify bind mount: `mount | grep /system/bin/su`
3. Check magisk binary: `ls -la /data/adb/magisk/magisk`
