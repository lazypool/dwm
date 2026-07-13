# DWM - dynamic window manager

Dwm is an extremely fast, small, and dynamic window manager for X.
It's created by [suckless.org](https://dwm.suckless.org/) and still being updated.
This repo adds some [new features](#new-features) based on it.
So, this is a **personal-use** WM maintained by [lazypool](https://github.com/lazypool).
Part of its design is inspired by [chadwm](https://github.com/siduck/chadwm), another awesome dwm project.

## Overview

![Image Loading](awaiting image...)

![Image Loading](awaiting image...)

![Image Loading](awaiting image...)

## Requirements

One-line command for Arch Linux users:

```bash
sudo pacman -S --needed base-devel libx11 libxinerama libxft libxrender fontconfig freetype2 imlib2 xorg-server xorg-xsetroot rofi firefox neovim acpi brightnessctl alsa-utils pacman-contrib lm_sensors networkmanager speedtest-cli xorg-setxkbmap xf86-input-synaptics fcitx5 dunst picom feh unzip unrar p7zip tar gzip bzip2 xz xdg-utils desktop-file-utils fastfetch imagemagick mpv nsxiv libreoffice-fresh htop perl-file-mimeinfo
```

### required packages

<table>
<tr>
<th>command tool</th>
<th>other requirements</th>
</tr>
<tr>
<td valign="top">

- acpi
- brightnessctl
- alsa-utils
- pacman-contrib (only available on Arch)
- sensors
- networkmanager, speedtest-cli
- imagemagick
- unzip, unrar, p7zip, tar, gzip, bzip2, xz  
- perl-file-mimeinfo
- htop

</td>
<td valign="top">

- rofi
- st or any other terminal emulator &emsp;&emsp;&emsp;
- firefox
- [nvim](https://github.com/lazypool/nvim)
- libreoffice-fresh
- fcitx5
- dunst
- picom
- fastfetch
- feh, mpv, nsxiv

</td>
</tr>
</table>

### needed fonts

Note: fonts need to be installed separately.

```
~/.local/share/fonts
├── Iosevka
├── JetBrainsMono
└── Material-Design-Iconic-Font.ttf
```

Download URL [Iosevka & JetBrains](https://github.com/ryanoasis/nerd-fonts/releases) and  [Material-Design-Iconic](https://zavoloklom.dev/material-design-iconic-font/)

## Install

```bash
git clone https://github.com/lazypool/dwm
cd dwm
sudo make clean install
make deploy
```

Note: chmod +x all scripts

## Run Dwm

In your `~/.xinitrc`, set $DWM to the absolute path of the **DWM** folder inside this repo, then exec dwm:

```sh
export DWM="/path/to/dwm/repo/DWM"   # e.g., "$HOME/dwm/DWM"
exec dwm 2> "$HOME/.local/dwmerr"
```

Now you can run `startx` after login to launch dwm.

### mime setup

**rofi** needs MIME types to open files. Run [mime/setup.sh](mime/setup.sh) to set defaults:

| File type                          | Opens with                                    |
|------------------------------------|-----------------------------------------------|
| .docx .pptx .xlsx                  | libreoffice                                   |
| .pdf .md .html                     | firefox                                       |
| .jpg .png .gif .bmp .svg           | nsxiv                                         |
| .mp3 .mp4 .mkv .avi .mov           | mpv                                           |
| .txt .c .h .py .conf .sh           | nvim                                          |
| .zip .tar .gz .bz2 .xz .7z         | [archive-preview.sh](mime/archive-preview.sh) |

→ [what's mime?](https://en.wikipedia.org/wiki/MIME)

to make `mime/setup.sh` work, the package [`perl-file-mimeinfo`](https://archlinux.org/packages/extra/any/perl-file-mimeinfo/) is also needed.

> Note: Using Firefox to preview markdown files requires the [Markdown Viewer](https://addons.mozilla.org/en-US/firefox/addon/markdown-viewer-webext/) extension.

## Customization

### config.h

### .config/

### themes & icons

## New Features
