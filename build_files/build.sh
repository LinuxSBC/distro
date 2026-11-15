#!/bin/bash

set -ouex pipefail

### Install packages

rpm --import https://downloads.1password.com/linux/keys/1password.asc
echo -e "[1password]\nname=1Password Stable Channel\nbaseurl=https://downloads.1password.com/linux/rpm/stable/\$basearch\nenabled=1\ngpgcheck=1\nrepo_gpgcheck=1\ngpgkey=\"https://downloads.1password.com/linux/keys/1password.asc\"" > /etc/yum.repos.d/1password.repo

# Terra repo
curl -fsSL https://github.com/terrapkg/subatomic-repos/raw/main/terra.repo > /etc/yum.repos.d/terra.repo
dnf5 -y install terra-release

dnf5 -y copr enable alternateved/keyd
dnf5 -y copr enable yuezk/globalprotect-openconnect

dnf5 install -y --allowerasing \
    zsh bat fd-find gh zoxide \
    neovim nodejs-bash-language-server shellcheck \
    cmake gtk4-devel json-glib-devel libevdev-devel libevdev-utils libgtop2-devel libinput-devel libinput-utils meson python3-tkinter python3-devel rpmdevtools flatpak-builder \
    firefox \
    gnome-shell-extension-gsconnect gnome-firmware gnome-tweaks nodejs26-npm \
    keyd \
    freerdp docker powertop \
    fx-autoconfig \
    lm_sensors nerd-fonts tailscale ddcutil fira-code-fonts fastfetch \
    xdg-native-messaging-proxy xdg-terminal-exec \
    python3-pygit2 python3-dbus nautilus-python \
    globalprotect-openconnect
    # gnome-shell-extension-forge gnome-shell-extension-pop-shell \
    # I'd like to install 1Password, but it installs to /opt, which isn't included in the image. It needs to be layered.
    # 1password 1password-cli \


### Enable sockets

systemctl enable podman.socket
