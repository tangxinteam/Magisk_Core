#!/system/bin/sh
# Magisk Core SU Injector - metainstall.sh
# Custom installer for modules when this metamodule is active

# This script is called when installing regular modules
# It provides the metamodule's own installation logic

# For meta-suinject, we don't need special install handling
# Just run the default module installation
echo "meta-suinject: delegating to default module installer"
