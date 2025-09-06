#!/usr/bin/env bash
set -e

# Set hostname
echo "NeuronOS" > /etc/hostname

# Enable services
systemctl enable NetworkManager.service
systemctl enable gdm.service
systemctl enable docker.service

echo "[customize_airootfs] Waiting 60 seconds before squashfs..."
sleep 60

# Sanity check: verify kernel + initramfs + modules exist in ISO staging
ISO_BOOT="/build/iso/boot"
ISO_MODULES="/build/iso/lib/modules/6.16.4-2-mits-capstone-Mits-Capstone"

echo "[customize_airootfs] Checking if required kernel files exist in ISO staging..."

for f in \
    "$ISO_BOOT/vmlinuz-linux-mits-capstone" \
    "$ISO_BOOT/initramfs-linux-mits-capstone.img" \
    "$ISO_BOOT/initramfs-linux-mits-capstone-fallback.img"
do
    if [ -f "$f" ]; then
        echo "[OK] Found $f"
    else
        echo "[MISSING] $f"
    fi
done

if [ -d "$ISO_MODULES" ]; then
    echo "[OK] Found modules directory: $ISO_MODULES"
else
    echo "[MISSING] Modules directory: $ISO_MODULES"
fi
