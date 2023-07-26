# Lazypool's build of dwm

dwm is an extremely fast, small, and dynamic window manager for X.

I have been using it for a so long time.

## Requirements

The Xlib header files are needed by dwm to be build. If you're an user of ArchLinux like me, you may do this:

```
$ sudo pacman -S xorg xorg-server xorg-xinit
```

## Installiton

Edit config.mk to match your local setup (dwm is installed into the /usr/local namespace by default).

Afterwards enter the following command to build and install dwm:

```
$ sudo make clean install
```

## Patches applied

All patches below can be found at [dwm.suckless.org](https://dwm.suckless.org):

- alpha.diff
- autostart.diff
- awesomebar.diff
- barheight.diff
- barpadding.diff
- clientopacity.diff
- exitmenu.diff
- hidevacanttags.diff
- monoclesymbol.diff
- pertag.diff
- uselessgap.diff
- vieontag.diff

Patches have been added already, you don't need to add them agin.

## Running dwm

Add the following line to your .xinitrc to start dwm using startx:

```
exec dwm
```

In order to connect dwm to a specific display, make sure that the DISPLAY environment variable is set correctly, e.g.:

```
DISPLAY=foo.bar:1 exec dwm
```

## Autostart

autostart is a patch provided by [this](https://github.com/axelGschaider/dwm-patch-autostart.sh/). It makes dwm to run commands before enter handler loop:

```
~/.dwm/autostart_blocking.sh
~/.dwm/autostart.sh &
```

So you can manage all your startup scripts in the ~/.dwm conveniently. If you want to refer to my scripts, you may look at [this](https://github.com/lazypool/.dwm)

## Acknowledgements

Sincerely thank [theCW](https://space.bilibili.com/13081489?spm_id_from=333.337.0.0) and [yaocccc](https://space.bilibili.com/303522232?spm_id_from=333.337.0.0) for their tutorial videos.
