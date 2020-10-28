# **Caution Ahead**
I know next to nothing about bash so there could be dragons and possibly a few trolls so use at your own risk.

## Void Linux Installer
This partially interarctive bash script is setup to *install void linux x86_64-musl, herbstluftwm & polybar.

### Install dotfiles
```
git clone https://gitlab.com/semente/summon.git
chmod +x summon/summon.sh
```
```
git clone https://github.com/leafhy/void-linux-installer.git
cd void-linux-installer
../summon/summon.sh dirname
```

#### Requirement (glibc version not tested)
https://alpha.de.repo.voidlinux.org/live/current/void-live-x86_64-musl-20191109.iso

\* Does not include rice
