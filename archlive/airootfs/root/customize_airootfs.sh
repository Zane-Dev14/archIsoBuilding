#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e -u

## -- SYSTEM CONFIGURATION -- ##

# Set the hostname for the live environment
echo "NeuronOS" > /etc/hostname

# Enable essential services
systemctl enable NetworkManager.service
systemctl enable gdm.service
systemctl enable docker.service

## -- USER EXPERIENCE -- ##

# Set Zsh as the default shell for the 'arch' live user
usermod -s /bin/zsh arch

# Create a default .zshrc for a better terminal experience
cat <<'EOF' > /home/arch/.zshrc
# Use powerline-go for a slick prompt if available
# To install: go install github.com/justjanne/powerline-go@latest
if [ -f "$GOPATH/bin/powerline-go" ]; then
    function _update_ps1() {
        PS1="$(/bin/powerline-go -error $?)"
    }
    if [ "$TERM" != "linux" ] && [ -f "$GOPATH/bin/powerline-go" ]; then
        PROMPT_COMMAND="_update_ps1; $PROMPT_COMMAND"
    fi
fi

# Basic aliases
alias ls='ls --color=auto'
alias ll='ls -l --color=auto'
alias la='ls -la --color=auto'
alias yay='yay --color=auto'

# Source global zsh config
if [ -f /etc/zsh/zshrc ]; then
    source /etc/zsh/zshrc
fi
EOF

# Set ownership of the new .zshrc file
chown arch:arch /home/arch/.zshrc

## -- GNOME DESKTOP CUSTOMIZATION -- ##

# Use sudo to run gsettings commands as the 'arch' user
sudo -u arch gsettings set org.gnome.desktop.interface icon-theme 'Papirus'
sudo -u arch gsettings set org.gnome.shell.extensions.user-theme name "Adwaita-dark"
sudo -u arch gsettings set org.gnome.shell enabled-extensions "['user-theme@gnome-shell-extensions.gcampax.github.com', 'appindicators@cinnamon.org']"
sudo -u arch gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
sudo -u arch gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'

## -- CONVENIENCE -- ##

# Configure GDM for automatic login (Robust Method)
# This finds the [daemon] section and adds our config directly under it.
awk '/^\[daemon\]/ { print; print "AutomaticLoginEnable=true\nAutomaticLogin=arch"; next } 1' /etc/gdm/custom.conf > /etc/gdm/custom.conf.tmp && mv /etc/gdm/custom.conf.tmp /etc/gdm/custom.conf

# Add a welcome message to the terminal (Message of the Day)
cat <<EOF > /etc/motd

██╗ ██╗███╗   ███╗██╗     ██████╗  ██████╗ ███████╗
██║ ██║████╗ ████║██║     ██╔══██╗██╔═══██╗██╔════╝
███████║██╔████╔██║██║     ██║  ██║██║   ██║███████╗
██╔══██║██║╚██╔╝██║██║     ██║  ██║██║   ██║╚════██║
██║  ██║██║ ╚═╝ ██║███████╗██████╔╝╚██████╔╝███████║
╚═╝  ╚═╝╚═╝     ╚═╝╚══════╝╚═════╝  ╚═════╝ ╚══════╝

Welcome to Neuron OS (By MITS CAPSTONE)!
- Your custom kernel is running.
- NVIDIA drivers, CUDA, and ML frameworks are pre-installed.
- Launch VS Code with 'code' or Jupyter with 'jupyter-lab'.

EOF

## -- FASTFETCH CUSTOMIZATION -- ##

# Create the configuration directory for both root and the live user
mkdir -p /root/.config/fastfetch/
mkdir -p /home/arch/.config/fastfetch/

# Create the fastfetch config file
cat <<'EOF' > /root/.config/fastfetch/config.jsonc
{
  "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.jsonc",
  "logo": {
    "type": "raw",
    "source": [
      "        %&&@@@@@@@@@@@@@@@@&&%",
      "     #&@@@@@@@@@@@@@@@@@@@@@@@@&#",
      "   &@@@@#        (&@@@@@@@@@@@@@@@&",
      " #@@@&             /@@@@@@@@@@@@@@@@#",
      "&@@@/               ,&@@@@@@@@@@@@@@@@&",
      "@@@%                 ,&@@@@@@@@@@@@@@@@@",
      "@@@%                  %@@@@@@@@@@@@@@@@@",
      "@@@@,                 #@@@@@@@@@@@@@@@@@",
      "&@@@@,               ,@@@@@@@@@@@@@@@@@&",
      " #@@@@&             ,&@@@@@@@@@@@@@@@#",
      "   &@@@@#,        ,&@@@@@@@@@@@@@@@&",
      "     #&@@@@@@@@@@@@@@@@@@@@@@@@&#",
      "        %&&@@@@@@@@@@@@@@@@&&%"
    ],
    "colors": [
      "blue",
      "cyan"
    ]
  },
  "modules": [
    "title",
    "separator",
    "os",
    "host",
    "kernel",
    "uptime",
    "de",
    "wm",
    "theme",
    "icons",
    "cpu",
    "gpu",
    "memory",
    "disk",
    "break",
    "colors"
  ]
}
EOF

# Copy the config to the 'arch' user's directory
cp /root/.config/fastfetch/config.jsonc /home/arch/.config/fastfetch/config.jsonc

# Set correct permissions for the 'arch' user's entire .config directory
chown -R arch:arch /home/arch/.config

## -- ADVANCED FEATURES -- ##

# Add live user to the docker group so they can use it without sudo
usermod -aG docker arch

# Build and install the 'yay' AUR helper as the 'arch' user
sudo -u arch bash <<'ARCH_EOF'
cd /home/arch
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg --noconfirm -si
cd ..
rm -rf yay
ARCH_EOF

## -- FINAL CLEANUP -- ##

# Clean pacman cache to reduce ISO size
pacman -Scc --noconfirm
