#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e -u

## -- SYSTEM CONFIGURATION -- ##

# Set the hostname for the live environment
echo "aiml-os" > /etc/hostname

# Enable essential services for graphical login and networking
systemctl enable NetworkManager.service
systemctl enable gdm.service

## -- USER EXPERIENCE -- ##

# Set Zsh as the default shell for the 'arch' live user
# The live user is created by archiso automatically
usermod -s /bin/zsh arch

# Create a default .zshrc for a better terminal experience
cat <<EOF > /home/arch/.zshrc
# Use powerline-go for a slick prompt if available
# To install: go install github.com/justjanne/powerline-go@latest
if [ -f "\$GOPATH/bin/powerline-go" ]; then
    function _update_ps1() {
        PS1="\$(\$GOPATH/bin/powerline-go -error \$?)"
    }
    if [ "\$TERM" != "linux" ] && [ -f "\$GOPATH/bin/powerline-go" ]; then
        PROMPT_COMMAND="_update_ps1; \$PROMPT_COMMAND"
    fi
fi

# Basic aliases
alias ls='ls --color=auto'
alias ll='ls -l --color=auto'
alias la='ls -la --color=auto'

# Source global zsh config
if [ -f /etc/zsh/zshrc ]; then
    source /etc/zsh/zshrc
fi
EOF

# Set ownership of the new .zshrc file
chown arch:arch /home/arch/.zshrc

## -- GNOME DESKTOP CUSTOMIZATION -- ##

# Enable user themes and the Papirus icon theme
sudo -u arch gsettings set org.gnome.desktop.interface icon-theme 'Papirus'
sudo -u arch gsettings set org.gnome.shell.extensions.user-theme name "Adwaita-dark" # Default dark theme

# Enable useful GNOME extensions by default
# This gives the desktop a more traditional, user-friendly feel
sudo -u arch gsettings set org.gnome.shell enabled-extensions "['user-theme@gnome-shell-extensions.gcampax.github.com', 'appindicators@cinnamon.org']"

# Set a dark theme by default
sudo -u arch gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
sudo -u arch gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'

## -- CONVENIENCE -- ##

# Configure GDM for automatic login for the live user
sed -i 's/#  AutomaticLoginEnable = true/AutomaticLoginEnable = true/' /etc/gdm/custom.conf
sed -i 's/AutomaticLogin = user1/AutomaticLogin = arch/' /etc/gdm/custom.conf

# Add a welcome message to the terminal (Message of the Day)
cat <<EOF > /etc/motd

██╗ ██╗███╗   ███╗██╗     ██████╗  ██████╗ ███████╗
██║ ██║████╗ ████║██║     ██╔══██╗██╔═══██╗██╔════╝
███████║██╔████╔██║██║     ██║  ██║██║   ██║███████╗
██╔══██║██║╚██╔╝██║██║     ██║  ██║██║   ██║╚════██║
██║  ██║██║ ╚═╝ ██║███████╗██████╔╝╚██████╔╝███████║
╚═╝  ╚═╝╚═╝     ╚═╝╚══════╝╚═════╝  ╚═════╝ ╚══════╝

Welcome to Neuron OS(By MITS CAPSTONE [NameToBeDecided])!
- Custom Kernel.
- NVIDIA drivers, CUDA, and ML frameworks are pre-installed.
- Launch VS Code with 'code' or Jupyter with 'jupyter-lab'.

EOF
## -- FASTFETCH CUSTOMIZATION -- ##

# Create the configuration directory for the root user
mkdir -p /root/.config/fastfetch/

# Create the fastfetch config file for the root user
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

# Create the configuration directory for the live 'arch' user
mkdir -p /home/arch/.config/fastfetch/

# Copy the same config file to the 'arch' user's directory
cp /root/.config/fastfetch/config.jsonc /home/arch/.config/fastfetch/config.jsonc

# Set correct permissions for the 'arch' user's config
chown -R arch:arch /home/arch/.config
