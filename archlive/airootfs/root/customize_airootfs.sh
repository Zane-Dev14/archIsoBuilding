# Set hostname
echo "NeuronOS" > /etc/hostname

# Enable services
systemctl enable NetworkManager.service
systemctl enable gdm.service
systemctl enable docker.service


KVER="6.16.4-2-mits-capstone-Mits-Capstone"

# Copy kernel and generate initramfs
if [ -f "/lib/modules/$KVER/vmlinuz" ]; then
    echo "Copying kernel..."
    cp /lib/modules/$KVER/vmlinuz /boot/vmlinuz-linux-mits-capstone

    echo "Generating initramfs..."
    mkinitcpio -k "$KVER" -g "/boot/initramfs-linux-mits-capstone.img"
    mkinitcpio -k "$KVER" -g "/boot/initramfs-linux-mits-capstone-fallback.img" -S autodetect

    echo "Kernel + initramfs ready"
else
    echo "ERROR: Kernel not found at /lib/modules/$KVER/vmlinuz"
    exit 1
fi
