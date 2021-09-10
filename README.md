# **Caution Ahead**
I know next to nothing about bash so there could be dragons and possibly a few trolls so use at your own risk.  

This repo is my complete? setup for Void Linux.

### Includes:
* unbound
* rofi
* herbstluftwm
* polybar        

## void-linux-installer.sh
This partially interarctive bash script is setup to install Void Linux for Desktop or Server (headless).

### Requirement (glibc version not tested)
[void-live-x86_64-musl-20210218.iso](https://ftp.swin.edu.au/voidlinux/live/current/void-live-x86_64-musl-20210218.iso)

### Install dotfiles manually or use [summon](https://gitlab.com/semente/summon)
```
git clone https://gitlab.com/semente/summon.git
chmod +x summon/summon.sh
```
```
git clone https://github.com/leafhy/void-linux-installer.git
cd void-linux-installer
/path/to/summon.sh config
```
