

# **NeuronOS Arch ISO Build[NAme patent pending, idk what to use] — Project Overview**

## **Project Structure**

```
archIsoBuilding/
├── archlive/                 # Main ISO build profile
│   ├── airootfs/             # Root filesystem for the live environment
│   │   ├── etc/              # System configuration files
│   │   │   ├── mkinitcpio.d/     # Custom initramfs presets
│   │   │   ├── mkinitcpio.conf.d/ # Kernel hooks configs
│   │   │   ├── modprobe.d/       # Module configuration
│   │   │   ├── pacman.d/hooks/   # Custom pacman hooks
│   │   │   ├── ssh/sshd_config.d/ # SSH configuration
│   │   │   ├── systemd/           # Systemd unit and generator configs
│   │   │   │   ├── multi-user.target.wants/  # Services to start at boot
│   │   │   │   ├── network-online.target.wants/
│   │   │   │   ├── sysinit.target.wants/
│   │   │   │   └── ...other dirs
│   │   │   └── xdg/reflector/     # Mirror reflector configuration
│   │   ├── root/                # Root user files for live environment
│   │   │   └── customize_airootfs.sh   # Customization script for live ISO
│   │   └── usr/local/           # User binaries and extras
│   │       ├── bin/              # Custom scripts (install-ml.sh, etc)
│   │       └── share/livecd-sound/   # Live CD sounds
│   ├── efiboot/loader/entries/    # UEFI boot entries
│   ├── grub/                      # GRUB config for ISO
│   └── syslinux/                  # Syslinux config for ISO
├── local_repo/                     # Local package repository (if used)
└── out/                            # Output ISO files
```

---

## **Important Files and Purpose**

| File                                                        | Purpose / Notes                                                                                                                                            |
| ----------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `archlive/airootfs/root/customize_airootfs.sh`              | Runs **during ISO build** to customize live root filesystem. Installs packages, sets hostname, users, shells, themes, and configs.                         |
| `archlive/packages.x86_64`                                  | Packages to be installed via `pacman` into live environment during build.                                                                                  |
| `archlive/airootfs/etc/systemd/system/post-install.service` | **Runs once after installation** on target system. Installs Python / ML packages like Transformers, Accelerate, Datasets, Safetensors, Sentencepiece, etc. |
| `archlive/airootfs/usr/local/bin/install-ml.sh`             | Script executed by `post-install.service` to install ML packages.                                                                                          |
| `archlive/profiledef.sh`                                    | ISO metadata: name, label, description, version, publisher, boot modes, etc.                                                                               |
| `archlive/airootfs/hooks/arch_user.hook`                    | Creates live user `arch`, sets groups, shells, `.zshrc`, fastfetch config, and passwordless sudo.                                                          |
| `archlive/airootfs/hooks/50-copy_kernel.hook`               | Copies the built kernel vmlinuz from `/lib/modules/.../vmlinuz` into `/boot` **before mkarchiso prepares the ISO**, ensuring initramfs generation works.   |

---

## **Key Fixes / Changes Made**

1. **Live user creation**

   * Original `customize_airootfs.sh` tried `usermod arch` before the user existed.
   * Fixed by creating `arch` via **arch\_user.hook** (runs at correct hook stage).

2. **Kernel initramfs issue**

   * Original `mkinitcpio.d/linux.preset` pointed to `/boot/vmlinuz-linux`.
   * Your custom kernel is `/lib/modules/6.16.4-2-mits-capstone-Mits-Capstone/vmlinuz`.
   * Fixed by creating a hook `50-copy_kernel.hook` that copies `vmlinuz` **after kernel installation but before mkarchiso prepares ISO**.

3. **mkinitcpio preset update**

   * Modified to point to **custom kernel** (`6.16.4-2-mits-capstone-Mits-Capstone`)
   * Ensures `default` and `fallback` initramfs images are generated correctly.

4. **/tmp space issue**

   * Original build used `/tmp` (RAM-backed, small).
   * Now using `/home/zane/archiso-work` as `-r` workdir to avoid "No space left on device."

5. **Fastfetch config**

   * Copied `/root/.config/fastfetch/config.jsonc` to `/home/arch/.config/fastfetch/config.jsonc` for live user theme info.

6. **Post-install ML setup**

   * `install-ml.sh` and `post-install.service` ensure ML ecosystem installed **after first boot**, preventing ISO bloat.

---

### **Notes on Build Flow**

1. **Package Installation** → `packages.x86_64` installed into `airootfs`.
2. **Kernel & Initramfs** → `50-copy_kernel.hook` copies `vmlinuz`, mkinitcpio generates `initramfs-linux-mits-capstone.img` and fallback.
3. **User Setup** → `arch_user.hook` creates live user, sets `.zshrc`, sudo, fastfetch.
4. **Customize AIrootfs** → Runs scripts and sets hostname, themes, services.
5. **ISO Prep** → `mkarchiso` prepares boot loaders, copies kernel/initramfs, creates ISO.
6. **Post-install ML** → Runs only on installed system via systemd service.

