# archIsoBuilding
 tying to build
So, few things for everyone who continues this
Kernel-> Built from Arch, applied BORE patch(took a very long time and lots of errors). Had to ditch Chris' kernel. Lz4, didnt get rid of x86, not much performance boost, doesnt take too much space,

tree
archlive-> where everything happens, build dir for ISO 

important files
_____________________________________________
1)archlive/airootfs/root/customize_airootfs.sh -> used during Arch ISO building to customize the live environment's root filesystem (airootfs), allowing you to install packages, configure settings, or add files before the ISO is built.

2)archlive/packages.x86_64 -> where we add stuff to install from pacman DURING build

3)archlive/airootfs/etc/systemd/system/post-install.service  -> the service to post install, runs only once(PIP PACKAGES, LIke transformers accelerate datasets safetensors sentencepiece)

4)archlive/airootfs/usr/local/bin/install-ml.sh -> install script. POST install.

5)archlive/profiledef.sh -> iso name, description etc

_____________________________________________
TREE

❯ tree -d -I "yay|work"
.
├── archlive
│   ├── airootfs
│   │   ├── etc
│   │   │   ├── mkinitcpio.conf.d
│   │   │   ├── mkinitcpio.d
│   │   │   ├── modprobe.d
│   │   │   ├── pacman.d
│   │   │   │   └── hooks
│   │   │   ├── ssh
│   │   │   │   └── sshd_config.d
│   │   │   ├── systemd
│   │   │   │   ├── journald.conf.d
│   │   │   │   ├── logind.conf.d
│   │   │   │   ├── network
│   │   │   │   ├── networkd.conf.d
│   │   │   │   ├── resolved.conf.d
│   │   │   │   ├── system
│   │   │   │   │   ├── cloud-init.target.wants
│   │   │   │   │   ├── getty@tty1.service.d
│   │   │   │   │   ├── multi-user.target.wants
│   │   │   │   │   ├── network-online.target.wants
│   │   │   │   │   ├── reflector.service.d
│   │   │   │   │   ├── sockets.target.wants
│   │   │   │   │   ├── sound.target.wants
│   │   │   │   │   ├── sysinit.target.wants
│   │   │   │   │   └── systemd-networkd-wait-online.service.d
│   │   │   │   └── system-generators
│   │   │   └── xdg
│   │   │       └── reflector
│   │   ├── root
│   │   └── usr
│   │       └── local
│   │           ├── bin
│   │           └── share
│   │               └── livecd-sound
│   ├── efiboot
│   │   └── loader
│   │       └── entries
│   ├── grub
│   └── syslinux
├── local_repo
└── out

43 directories
