#!/bin/bash

set -ouex pipefail

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/43/x86_64/repoview/index.html&protocol=https&redirect=1

# this installs a package from fedora repos
dnf5 install -y \
    1password 1password-cli \
    bat fd-find gh tealdeer zoxide \
    neovim nodejs-bash-language-server shellcheck \
    cmake gtk4-devel json-glib-devel libevdev-devel libevdev-utils libgtop2-devel libinput-devel libinput-utils meson python3-tkinter rpmdevtools \
    firefox \
    gnome-shell-extension-forge gnome-shell-extension-pop-shell gnome-shell-extension-system-monitor \
    keyd \
    freerdp globalprotect-openconnect 
# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging

#### Example for enabling a System Unit File

systemctl enable podman.socket
