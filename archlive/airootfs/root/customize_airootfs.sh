#!/bin/bash
set -e

# ----------------------------------------------------
# Hostname
# ----------------------------------------------------
echo "NeuronOS" > /etc/hostname

# ----------------------------------------------------
# Enable services
# ----------------------------------------------------
systemctl enable NetworkManager.service
systemctl enable gdm.service
systemctl enable docker.service

# ----------------------------------------------------
# Kernel + Initramfs handling
# ----------------------------------------------------
KVER="6.16.4-2-mits-capstone-Mits-Capstone"
BOOT_DIR="/boot"

# Copy the kernel image from /lib/modules/<version> into /boot
if [[ -f /lib/modules/$KVER/vmlinuz ]]; then
    cp /lib/modules/$KVER/vmlinuz "$BOOT_DIR/vmlinuz-linux-mits-capstone"
    echo "[customize_airootfs] Copied kernel -> $BOOT_DIR/vmlinuz-linux-mits-capstone"
else
    echo "[customize_airootfs][ERROR] Kernel vmlinuz not found at /lib/modules/$KVER/"
    exit 1
fi

# Generate initramfs (normal + fallback)
if command -v mkinitcpio >/dev/null 2>&1; then
    echo "[customize_airootfs] Generating initramfs images..."
    mkinitcpio -k "$KVER" -g "$BOOT_DIR/initramfs-linux-mits-capstone.img"
    mkinitcpio -k "$KVER" -g "$BOOT_DIR/initramfs-linux-mits-capstone-fallback.img" -S autodetect || true
else
    echo "[customize_airootfs][ERROR] mkinitcpio not found inside chroot!"
    exit 1
fi

# ----------------------------------------------------
# Optional: Backup copies to host (safety net)
# ----------------------------------------------------
BACKUP_DIR="/run/archiso/copy-out"
mkdir -p "$BACKUP_DIR"
cp "$BOOT_DIR"/vmlinuz-linux-mits-capstone "$BOOT_DIR"/initramfs-linux-mits-capstone*.img "$BACKUP_DIR"/
echo "[customize_airootfs] Backed up kernel + initramfs to $BACKUP_DIR"
