#!/bin/bash
set -e

KVER="6.16.4-2-mits-capstone-Mits-Capstone"

if [ -f "/lib/modules/${KVER}/vmlinuz" ]; then
    echo "[mits-capstone] Copying kernel to /boot..."
    cp "/lib/modules/${KVER}/vmlinuz" "/boot/vmlinuz-linux-mits-capstone"

    echo "[mits-capstone] Generating initramfs..."
    mkinitcpio -k "$KVER" -g "/boot/initramfs-linux-mits-capstone.img"
    mkinitcpio -k "$KVER" -g "/boot/initramfs-linux-mits-capstone-fallback.img" -S autodetect
else
    echo "[mits-capstone] ERROR: kernel image not found in /lib/modules/${KVER}"
    exit 1
fi
