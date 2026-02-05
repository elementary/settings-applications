# Applications Settings
[![Translation status](https://l10n.elementaryos.org/widget/settings/applications/svg-badge.svg)](https://l10n.elementaryos.org/engage/settings/)

![screenshot](data/screenshot-permissions.png?raw=true)

## Building and Installation

You'll need the following dependencies:

* libadwaita-1-dev
* libswitchboard-3-dev
* libflatpak-dev
* libgranite-7-dev >= 7.6.0
* libgtk-4-dev
* meson >= 0.58.0
* valac

Run `meson` to configure the build environment and then `ninja` to build

    meson build --prefix=/usr
    cd build
    ninja

To install, use `ninja install`

    ninja install
