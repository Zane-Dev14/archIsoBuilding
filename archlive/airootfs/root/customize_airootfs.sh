# Set hostname
echo "NeuronOS" > /etc/hostname

# Enable services
systemctl enable NetworkManager.service
systemctl enable gdm.service
systemctl enable docker.service
