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

Download URL [Iosevka & JetBrains](https://github.com/ryanoasis/nerd-fonts/releases) and [Material-Design-Iconic](https://zavoloklom.dev/material-design-iconic-font/)

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

| File type                  | Opens with                                    |
| -------------------------- | --------------------------------------------- |
| .docx .pptx .xlsx          | libreoffice                                   |
| .pdf .md .html             | firefox                                       |
| .jpg .png .gif .bmp .svg   | nsxiv                                         |
| .mp3 .mp4 .mkv .avi .mov   | mpv                                           |
| .txt .c .h .py .conf .sh   | nvim                                          |
| .zip .tar .gz .bz2 .xz .7z | [archive-preview.sh](mime/archive-preview.sh) |

→ [what's mime?](https://en.wikipedia.org/wiki/MIME)

to make `mime/setup.sh` work, the package [`perl-file-mimeinfo`](https://archlinux.org/packages/extra/any/perl-file-mimeinfo/) is also needed.

> Note: Using Firefox to preview markdown files requires the [Markdown Viewer](https://addons.mozilla.org/en-US/firefox/addon/markdown-viewer-webext/) extension.

## Customization

### config.h

Modify this file to control how dwm looks and behaves - window borders, bar, fonts, rules, layouts, keybindings and mouse bindings.

#### appearance

| variable                               | description                         |
| -------------------------------------- | ----------------------------------- |
| `borderpx`                             | border width of windows             |
| `snap`                                 | snap threshold in pixels            |
| `showbar` / `topbar`                   | show bar / bar position             |
| `sidepad` / `iconsize` / `iconspacing` | padding and title icon size         |
| `ulpad` / `ulstroke`                   | tag underline offset and thickness  |
| `fonts[]`                              | font fallback list (with Nerd Font) |

Colors and `schemetags[]` are managed by the theme system, see [themes & icons](#themes--icons).

#### rules

When a new window appears, `applyrules()` walks `rules[]` in order and applies the **first** matching rule.

- Matching fields (substring match, NULL matches any):

| field                | source                                                    |
| -------------------- | --------------------------------------------------------- |
| `class` / `instance` | `WM_CLASS` from `xprop`                                   |
| `title`              | `WM_NAME` / `_NET_WM_NAME`                                |
| `wintype`            | `_NET_WM_WINDOW_TYPE` (e.g. `_NET_WM_WINDOW_TYPE_DIALOG`) |

- Action fields:

| field        | effect                                                                         |
| ------------ | ------------------------------------------------------------------------------ |
| `tags`       | bitmask via `TAG(n)`. 0 means current tag. Ignored if `isglobal` is set.       |
| `isfloating` | 1 = float, 0 = tile                                                            |
| `isglobal`   | 1 = visible on all tags                                                        |
| `monitor`    | assign to monitor by index, `-1` = no assignment, keeps default.               |
| `unmanaged`  | 1 = raise and exclude from tiling, 2 = lower, 3 = exclude with no stack change |

#### layouts

`layouts[]` defines available arrangements. Each entry has a symbol shown in the bar and an arrange function:

| symbol | layout   | description                            |
| ------ | -------- | -------------------------------------- |
| 󰙀      | tile     | master-stack tiling (default)          |
| 󰗣      | floating | no arrange function, all windows float |
| 󰎡      | monocle  | fullscreen single window               |

`mfact` controls master area ratio, `nmaster` the number of clients in master area.

#### key & button

First define a command array (NULL-terminated):

```c
const char *termcmd[] = {"st", NULL};
const char *menucmd[] = {"sh", "-c", "~/.config/rofi/scripts/rofi-main.sh", NULL};
```

Bind it to a key with `spawn`:

```c
{MODKEY,             XK_p,      spawn,          {.v = menucmd}},
{MODKEY | ShiftMask, XK_Return, spawn,          {.v = termcmd}},
```

MODKEY is `Mod4Mask` (Super Key). Other modifiers: `ControlMask`, `ShiftMask`, `Mod1Mask..Mod5Mask`.

The same `{.v = ...}` works for buttons:

```c
{ClkWinTitle,   0,      Button2, zoom,           {0}},
{ClkClientWin,  MODKEY, Button1, movemouse,      {0}},
{ClkStatusText, 0,      Button1, clkstatusbar,   {0}},
```

Click areas: `ClkLtSymbol`, `ClkWinTitle`, `ClkStatusText`, `ClkTagBar`, `ClkClientWin`.

### .config/

`.config/` is where third-party application config files related to this dwm setup are stored.
Run `make deploy` to copy them to `~/.config/` so the corresponding apps can pick them up.

```
.config
├── dunst
│   └── dunstrc                # notification daemon
├── fastfetch
│   ├── config.jsonc           # system info tool (shows $DWM_THEME, $DWM_ICONS)
│   └── logo.png               # custom logo
├── mpv
│   ├── albumart.jpg           # fallback cover for music mode
│   ├── mpv.conf               # Vulkan gpu-next, ModernX OSC, thumbfast
│   ├── script-opts
│   └── scripts                # modernx.lua, thumbfast.lua, albumart.lua
├── picom
│   └── picom.conf             # X11 compositor: rounded corners, blur, animations
└── rofi
    ├── config.rasi            # global config
    ├── scripts                # rofi-main.sh launcher
    └── themes                 # main.rasi, shared.rasi
```

**related application manuals**

- [dunst](https://dunst-project.org/) — notification daemon
- [fastfetch](https://github.com/fastfetch-cli/fastfetch) — system info tool
- [mpv](https://mpv.io/) — media player
- [picom](https://github.com/yshui/picom) — X11 compositor
- [rofi](https://github.com/davatorium/rofi) — app launcher & window switcher

### themes & icons

#### setup

#### theme creation

#### icon design

## New Features

## Contributing

Contributions are welcome. Feel free to open an issue or submit a pull request:

1. [fork](https://github.com/lazypool/dwm/fork) and clone the repo
2. make your changes
3. submit a pull request

When developing, you may need freetype2 headers for the LSP type checker (e.g. in Neovim):

```bash
sudo pacman -S freetype2
sudo ln -s /usr/include/freetype2/ft2build.h /usr/include/
sudo ln -s /usr/include/freetype2/freetype /usr/include/
```

LICENSE [MIT/X Consortium License](LICENSE)
