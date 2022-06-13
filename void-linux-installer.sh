#!/bin/bash
##################################
########### References ###########
##################################
# https://voidlinux.org
# http://www.troubleshooters.com/linux/void/index.htm
# https://alkusin.net/voidlinux/
# https://github.com/olivier-mauras/void-luks-lvm-installer/blob/master/install.sh
# https://github.com/NAGA1337/void/blob/master/void.sh
# https://github.com/alejandroliu/0ink.net/blob/master/snippets/void-installation/install.sh
# https://github.com/addy-dclxvi/almighty-dotfiles
# https://github.com/adi1090x/polybar-themes
# https://github.com/adi1090x/rofi
# https://github.com/ntcarlson/dotfiles
# https://github.com/sdothum/dotfiles
# https://github.com/denysdovhan/bash-handbook
# https://gitlab.com/vahnrr/rofi-menus
# http://thedarnedestthing.com/colophon
# https://www.kernel.org/doc/Documentation/filesystems/f2fs.txt
# https://www.kernel.org/doc/Documentation/filesystems/xfs.txt
# https://www.kernel.org/doc/Documentation/filesystems/nilfs2.txt
# https://www.kernel.org/doc/Documentation/filesystems/ext4.txt
# http://ix.io/1wIS # aggressive nilfs config
# https://www.shellcheck.net
# https://wiki.archlinux.org/index.php/unbound
# https://nlnetlabs.nl/documentation/unbound
# https://www.funtoo.org/Keychain
# http://pinyinjoe.com/index.html # Chinese language setup in Microsoft Windows, Ubuntu Linux
# http://www.secfs.net/winfsp # mount remote folder on windows # root "\\sshfs.r\user@host/" # home '\\sshfs\user@host"
# https://github.com/billziss-gh/winfsp
# https://github.com/billziss-gh/sshfs-win
##############################
###### Symlink Managers ######
##############################
# https://github.com/anishathalye/dotbot
# https://github.com/lra/mackup
# https://github.com/kairichard/lace
# https://github.com/andsens/homeshick
# https://gitlab.com/grm-grm/ck
# https://gitlab.com/semente/summon
# https://www.gnu.org/software/stow
# https://www.chezmoi.io
###################################
### Hide/Unhide Terminal Cursor ###
###################################
# echo -en "\e[?25h" # unhide
# tput civis # hide
# tput cnorm # unhide
###################################
#
#    Notes: Void Linux is running on Lenovo Thinkpad T420 in EFI only mode with "Dogfish 128GB" mSATA
#         : Microsoft Windows switches to Nvidia Optimus mode if enabled
#         : Nvidia Optimus prevents external monitor (display port) from working, Need to set bios to use "discrete"
#         : Firefox is slow (10s) to start if /etc/hosts is incorrect (default hosts starts firefox ~5sec)
#         : if audio stops working restart Firefox
#         : Need to disable bitmap fonts "ln -s /usr/share/fontconfig/conf.avail/70-no-bitmaps.conf /etc/fonts/conf.avail/" or create ~/.config/fonts.conf so Firefox can use other fonts
#         : Bluetooth(bluez) - Can be slow to detect device - pairs ok - connects and imediately disconnects - bluetooth audio not tested
#         : For eSATA to work on T420 (tested with powered enclosure - usb not needed) place the folowing in bash script (rescan-scsi-bus.sh didn't work)
#           "for i in `ls /sys/class/scsi_host/`; do echo "- - -" > /sys/class/scsi_host/$i/scan; done"
#         : 'doas' is used instead of 'sudo'(can install as dependency)
#         : Using 'mv' via mergerfs mountpoint may fail to move all files (use rsync to clean up)
#         : Grub will overwrite the mbr of an aleady installed operating system even if it's on a separate hard drive
#         : Windows 10 will install efi and recovery data onto secondary hardrive
#         : Updating Live CD kernel will result in "[*]" as an option to install
#         : OSX 'finder' can truncate filenames on fat-32, trying to rename will error filename already exists. Need to rename via Terminal
#         : void ncurses installer is problematic - it may work or fail trying to format
#         : /home/$user/.asoundrc - increases volume
#         : efibootmgr default label "Void Linux With Kernel 5.7"
#         : ATAPI CD0 = HL-DT-STDVDRAM GT33N
#         : efifb: mode is 640x480x32
#         : alsa-utils >>> alsamixer is required to un-mute
#         : intel-ucode - dracut default is to include which makes early_microcode=yes >> /etc/dracut.conf.d/intel_ucode.conf redundant
#         : Not Required : kernel .efi extension
#                        : efivarfs  /sys/firmware/efi/efivars efivarfs  0 0 >> /mnt/etc/fstab
#         : Nilfs causes '/' to mount twice >> drops to emergency shell Need to 'exit' twice to continue booting and 'enter' to display login prompt
#         : Bash script buffquote initially only showed the first quote in bash as RANDOM couldn't be found due to /bin/sh -> dash (works in dash) - need to run buffquote with /bin/bash
######################################################################################
############################## Preparatory Instructions ##############################
######################################################################################
### Download ###
# wget https://ftp.swin.edu.au/voidlinux/live/current/sha256sum.sig
#      https://alpha.de.repo.voidlinux.org/live/current/sha256sum.sig
#
# wget https://ftp.swin.edu.au/voidlinux/live/current/sha256sum.txt
#      https://alpha.de.repo.voidlinux.org/live/current/sha256sum.txt
#
# wget https://ftp.swin.edu.au/voidlinux/live/current/void-live-x86_64-musl-20210218.iso
#      https://alpha.de.repo.voidlinux.org/live/current/void-live-x86_64-musl-20210218.iso
#
### Verify image ###
# xbps-install void-release-keys signify
# sha256sum -c --ignore-missing sha256sum.txt
# void-live-x86_64-musl-20210218.iso: OK
#
# signify -C -p /etc/signify/void-release-20210218.pub -x sha256sum.sig void-live-x86_64-musl-20210218.iso
# Signature Verified
# void-live-x86_64-musl-20210218.iso: OK
#
# Install void-live-x86_64-musl-20210218.iso to CD/usb
#
# Note: Void Linux repository = ~1TB
#     : fdisk can format iso9660/HYBRID USB
#     : rufus - creates one partition -> /run/initramfs/live/data-is-here
#     : passmark imgUSB - formating free space is not reliable (blkid sometimes fails to detect partition)
##########################################################################################
# base-voidstrap
# base-files ncurses coreutils findutils diffutils
# dash bash grep gzip file sed gawk less util-linux which tar man-pages
# mdocml>=1.13.3 shadow e2fsprogs btrfs-progs xfsprogs f2fs-tools dosfstools kbd
# procps-ng tzdata pciutils iana-etc eudev runit-void openssh dhcpcd
# iproute2 iputils iw xbps nvi sudo traceroute kmod
#################################################################
# base-system
# base-files>=0.77 ncurses coreutils findutils diffutils libgcc
# dash bash grep gzip file sed gawk less util-linux which tar man-pages
# mdocml>=1.13.3 shadow e2fsprogs btrfs-progs xfsprogs f2fs-tools dosfstools
# procps-ng tzdata pciutils usbutils iana-etc openssh dhcpcd
# kbd iproute2 iputils iw wpa_supplicant xbps nvi sudo wifi-firmware
# void-artwork traceroute ethtool kmod acpid eudev runit-void
#################################################################
# base-minimal
# base-files coreutils findutils diffutils dash grep gzip sed gawk
# util-linux which tar shadow procps-ng iana-etc xbps nvi tzdata
# runit-void
#################################################################
# Notes:
# Cron options >> fcron,hcron,dcron,bcron,scron,tinycron,cronie
# thinkfan - set fan temp thresholds
# mdocml=mandoc outputs man pages
# autox - caused login to loop switching monitor off & on (herbstluftwm)
# iwd - includes dhcp
# unbound - will not start if interface is wrong
# zathura - mupdf,poppler,djvu,epub (mupdf stand alone is faster)
# aucatctl - changes volume in sndiod
# bind-utils - dig (dns lookup), nslookup, host
# lsyncd - service failed to start # erred with listed option as unknown
# udevil - block mount only
# zeroconf/bonjour >> mDNSResponder,python3-zeroconf,python-zeroconf,avahi
# nemo >> gvfs,gvfs-afp,gvfs-cdda,gvfs-smb,gvfs-afc,gvfs-mtp,gvfs-gphoto2
#      >> Network Mount >> /home/user/.cache/gvfs/sftp\:host\=XXXXXXXXXXX
#      >> Archive Extract >> file-roller
#      >> Video Thumbnails >> ffmpegthumbnailer
# tumbler -  "D-Bus Thumbnailer service" >> unsure of difference with ffmpegthumbnailer
# cherrytree - https://www.giuspen.com/cherrytree - note taking application
# lsscsi - list drives
# autorandr - create monitor profiles
# audacity - fails to start via icon - starts via cli with errors then stops responding
# reaper - starts then freezes - need to poweroff
# testdisk - dependant on sudo (xbps-install fails if sudo not installed)
# attr-progs - Extended attributes # getfattr,setfattr
# imgcat - https://github.com/danielgatis/imgcat/releases/download/v1.0.8/imgcat_1.0.8_Linux_x86_64.tar.gz # Binary works
#        - https://github.com/eddieantonio/imgcat # failed to compile
##################################################################
####################### Siren Music Player #######################
##################################################################
# https://www.kariliq.nl/siren
# git clone https://www.kariliq.nl/git/siren.git
# git clone https://github.com/tbvdm/siren.git
# sed -i 's+.siren+.cache/siren+' siren.h
# ./configure aac=yes mad=no sndio=yes ffmpeg=yes mpg123=yes flac=yes opus=yes sndfile=yes vorbis=yes wavpack=yes sun=no oss=no ao=no portaudio=no pulse=no alsa=no
# make && make install
#
# wav,aiff = sndfile | mp3 = mad,mpg123 | ogg = ogg | wv = wavpack
# opus = opusfile | aac = faad | mp4 = mp4v2 | flac = flac
# ffmpeg = flac,ogg,mp3,mp4,m4a
#
# libid3tag-devel wavpack-devel libmad-devel libmp4v2-devel flac-devel
# libsndfile-devel libogg-devel mpg123-devel faad2-devel sndio-devel
# pulseaudio-devel libpulseaudio-devel libao-devel portaudio-devel ffmpeg-devel
# opusfile-devel pkg-config
#
# ~/.siren/config
# set active-fg blue # foreground
#################################################################
####################### Vuurmuur Firewall #######################
#################################################################
# https://www.vuurmuur.org
# https://github.com/inliniac/vuurmuur/releases/download/0.8/vuurmuur-0.8.tar.gz
# ./configure && make && make install 
#
# xbps-install libmnl-devel dialog libnetfilter_conntrack-devel libnetfilter_log-devel
#
# Note: unable to get git clone/install.sh version working
#
# vuurmuur_conf --wizard # create config
# vuurmuur_conf
#             >>> Rules >>> INS(ert) >>> [OUTGOING] Action [Accept] Log [x] Service [any] From [firewall] To [world.inet]
#                                    >>> [INCOMING] Action [Accept] Log [x] Service [any] From [lan] To [firewall]
#             >>> Iterfaces >>> inet-nic enp0s25 192.168.1.XX
#                           >>> lan-nic enp0s25 192.168.1.XX
#             >>> Vuurmuur Config >>> Interfaces >>> uncheck dynamic interfaces for changes
###########################################################################################
########################## Bitwarden - Vaultwarden(Bitwarden_rs) ##########################
###########################################################################################
# https://bitwarden.com
# ---------- Extract Vaultwarden binary and Web-vault from docker image ------------------
# https://github.com/jjlin/docker-image-extract
# wget https://raw.githubusercontent.com/jjlin/docker-image-extract/main/docker-image-extract
# chmod +x docker-image-extract
# docker-image-extract vaultwarden/server:alpine
# docker-image-extract bitwardenrs/server:testing-alpine
# mkdir -p vaultwarden/data
# mv output/vaultwarden /path/to/vaultwarden
# mv output/web-vault /path/to/vaultwarden
# rm -r output
# wget https://raw.githubusercontent.com/dani-garcia/vaultwarden/main/.env.template --output-document=/path/to/vaultwarden/.env
# fcrontab -e
# &bootrun,first(2) * * * * * cd /home/$USER/src/vaultwarden ./vaultwarden >> /var/log/vaultwarden.log 2>&1
# --------------------- Build ----------------------------
# curl https://sh.rustup.rs -sSf | sh # installs to $HOME
# select (1)
# rustup self uninstall
# -----------------
# .bashrc
# export RUSTUP_HOME=".local/share/rustup"
# export CARGO_HOME=".local/share/cargo"
# ------------------
# https://github.com/dani-garcia/vaultwarden
# git clone https://github.com/dani-garcia/bitwarden_rs && pushd bitwarden_rs
# cargo clean && cargo build --features sqlite --release
# mkdir ~/src/bitwarden_rs/target/release/data # needed for creation of rsa key
# source .cargo/env # or .bash_profile
# aria2c https://github.com/dani-garcia/bw_web_builds/releases/download/v2.15.1/bw_web_v2.15.1.tar.gz
# tar xf bw_web_v2.15.1.tar.gz
# mv web-vault bitwarden_rs/target/release
# cp bitwarden_rs/.env.template bitwarden_rs/target/release/.env
# ----------------- .env --------------------------------
# DISABLE_ICON_DOWNLOAD=true # prevents Segmentaion Fault - appears to have been fixed
# WEBSOCKET_ENABLED=true
# WEBSOCKET_ADDRESS=0.0.0.0
# WEBSOCKET_PORT=3012
# -------------------------------------------------------
# Bitwarden CLI
# xbps-install gcompat
# https://github.com/bitwarden/cli/releases/download/v1.11.0/bw-linux-1.11.0.zip
# chmod +x bw
# mv bw /usr/local/bin
# bw config server https://$HOSTNAME:2016
# Required for selfsigned certificate
# NODE_TLS_REJECT_UNAUTHORIZED=0 bw login # disable certifcate check
# NODE_EXTRA_CA_CERTS=<path to my ca> bw login
# ------------------------
# Caddy v2 Reverse Proxy https
# https://github.com/caddyserver/caddy
# https://github.com/caddyserver/caddy/releases/download/v2.2.0-rc.1/caddy_2.2.0-rc.1_linux_amd64.tar.gz
# tar xf caddy_2.2.0-rc.1_linux_amd64.tar.gz
# mv caddy /usr/bin/
# Start Caddy with fcron or /etc/rc.local (displays caddy startup messages)
#
# /home/$USER/.config/caddy/Caddyfile
# ---------------------------
# #$HOSTNAME
# :2016 {
# tls /home/$USER/PATH/TO/cert.crt /home/$USER/PATH/TO/cert.key
#
# reverse_proxy 127.0.0.1:8000
# 
# log {
#     output file /var/log/caddy.log 
# }
# :2015 {
# root * /path/to/blog/
# file_server
# log {
#     output file /var/log/caddy.log
#    }
# }
# ----------------------------
# create certificates
# openssl req -new -newkey rsa:2048 -sha256 -days 365 -nodes -x509 -keyout /path/to/cert.key -out /path/to/cert.crt
# ----------------------------
# Note: Do not install cargo/rust with xbps-install # Bitwarden_rs will not build
#       rustup & cargo install size >1GB & ~3GB packages for vaultwarden
#       0.0.0.0:8000 # connection is not secure
#       127.0.0.1:8000 # this page is stored on your computer
#       http://192.168.1.4:8000, https://$HOSTNAME:2016, https://$HOSTNAME # Lan access
#
# Caddy Log (Errors occured when using $HOSTNAME in Caddyfile - missing braces?)
# ---------------------------------------
# WARN pki.ca.local installing root certificate (you might be prompted for password) {“path”: “storage:pki/authorities/local/root.crt”}
# 2020/09/08 not NSS security databases found
# 2020/09/08 define JAVA_HOME environment variable to use the Java trust
# 2020/09/08 ERROR pki.ca.local failed to install root certificate {“error”: “install is not supported on this system”, “certificate_file”: “storage:pki/authorities/local/root.crt”}
# certificates did install to ~/.local/share/caddy/pki/authorities/local/caddy
# -----------------------
# 'caddy stop' errors if already stopped
# 2021/07/25 22:28:56.270    WARN    failed using API to stop instance    {"error": "performing request: Post \"http://localhost:2019/stop\": dial tcp [::1]:2019: connect: connection refused"}
# stop: performing request: Post "http://localhost:2019/stop": dial tcp [::1]:2019: connect: connection refused
##############################################################################
# SSHFS
# xbps-install fuse-sshfs
# sshfs user@server:/ /mnt/server
# /etc/fstab
# sshfs#$USER@$SERVER:/mnt/storage /home/user/server fuse reconnect,_netdev,idmap=user,delay_connect,defaults,allow_other 0 0
#################################################################
# NFS Mount
# /etc/exports
# /path/here 'ip of OSX'(insecure,rw,sync,no_root_squash)
# exportfs -a
# mount -t nfs 192.168.1.4:/path /Users/$USER/mountpoint # OSX
# Note: make sure permissions are correct or 'finder' will not not write
#     : unable to get nfs or autofs to work (void client > void server)
#################################################################
# Alock (Pauses dunst notifications)
# xbps-install automake imlib2-devel pam-devel libgcrypt-devel libXrender-devel
# git clone https://github.com/Arkq/alock.git
# cd alock
# $ autoreconf --install
# $ mkdir build && cd build
# $ ../configure --enable-pam --enable-hash --enable-xrender --enable-imlib2 \
#    --with-dunst --with-xbacklight
# $ make && make install
###################################################
# Dmenu-Extended
# git clone https://github.com/MarkHedleyJones/dmenu-extended.git
# python setup.py install
# .config/dmenu-extended/config/dmenuExtended_preferences.txt
# "menu": "rofi",
# "menu_arguments": [
# "-dmenu",
#  "-i"
# ],
# Note: '-b' # moves window to bottom of screen
#####################################################
# Java
# xbps-install openjdk8-jre
# https://www.java.com/en/download/linux_manual.jsp
# ~/.bashrc
# JAVA_HOME=/home/user/src/jre1.8.0_261
# export PATH=$JAVA_HOME/bin:$PATH
# export LD_LIBRARY_PATH=/usr/lib/jvm/java-1.8-openjdk/jre/lib/amd64/server
#####################################################
# DirSync Pro - requires LD_LIBRARY_PATH=/usr/lib/jvm/java-1.8-openjdk/jre/lib/amd64/server
# https://www.dirsyncpro.org
# https://downloads.sourceforge.net/project/directorysync/DirSync%20Pro%20%28stable%29/1.53/DirSyncPro-1.53-Linux.tar.gz
#####################################################
# Clipboard Manaqers
# https://sourceforge.net/projects/copyq
# https://hluk.github.io/CopyQ
# xbps-install CopyQ
#
# Keepboard (MacOs,Win,Linux) - Java
# https://sourceforge.net/projects/keepboard
# https://downloads.sourceforge.net/project/keepboard/Keepboard_Linux_5.5.zip
# atool -x Keepboard_Linux_5.5.zip
# Keepboard_Linux_5.5/start.sh
#
# https://github.com/erebe/greenclip
# https://github.com/gilbertw1/roficlip
##################################################################
# Osync
# https://github.com/deajan/osync
# Note: Usb may need to removed/reinserted for osync --on-changes to work 
##################################################################
# Fonts
# fc-list # /usr/share/fonts
# https://github.com/be5invis/Iosevka
# https://overpassfont.org
# https://mplus-fonts.osdn.jp
# http://www.fial.com/~scott/tamsyn-font/download/tamsyn-font-1.11.tar.gz
# Firefox requires: "noto-fonts-cjk" (Not required for Chromium)
#                 : ~/.config/fontconfig/fonts.conf
###################################################################
####################### Encrypt USERS $HOME #######################
###################################################################
# xbps-install gocryptfs pam-mount
# Stop $USER processess & logout then login as root
# mv /home/$USER /home/$USER.old
# mkdir /home/$USER.cipher # encrypted
# mkdir /home/$USER # empty mount
# correct $user,$user.cipher permissions # mount will fail if incorrect
#
# gocryptfs -init $USER.CIPHER
# mount $user.cipher onto $user
# gocryptfs $USER.CIPHER $USER
# cp -r $USER.OLD $USER
# 
# The following (3) files allow $HOME to auto mount
# ------------------------------------
# /etc/security/pam_mount.conf.xml
# < volume user="$USER" fstype="fuse" options="nodev,nosuid,quiet,nonempty,allow_other"
# path="/usr/local/bin/gocryptfs#/home/%(USER).cipher" mountpoint="/home/%(USER)" />
# ------------------------------------
# /etc/pam.d/system-login
# #%PAM-1.0
#
# auth       required   pam_tally.so         onerr=succeed file=/var/log/faillog
# auth       required   pam_shells.so
# auth       requisite  pam_nologin.so
# auth       optional   pam_mount.so <<<< add this <<<<
# auth       include    system-auth
#
# account    required   pam_access.so
# account    required   pam_nologin.so
# account    include    system-auth
# password   optional   pam_mount.so <<<< add this <<<<
# password   include    system-auth
#
# session    optional   pam_loginuid.so
# session    optional   pam_mount.so <<<< add this <<<<<
# session    include    system-auth
# session    optional   pam_motd.so          motd=/etc/motd
# session    optional   pam_mail.so          dir=/var/mail standard quiet
# -session   optional   pam_elogind.so
# -session   optional   pam_ck_connector.so  nox11
# session    required   pam_env.so
# session    required   pam_lastlog.so       silent
# ------------------------------------
# /etc/fuse.conf
# user_allow_other # uncomment
######################################
# Mopidy Music Server
# xbps-install mopidy snapserver snapclient snapcast python3-pip
# ln -s /etc/sv/mopidy /etc/runit/runsvdir/default
# ln -s /etc/sv/snapserver /etc/runit/runsvdir/default
# python3 -m pip install Mopidy-Iris
# /etc/mopidy.conf
# -----------------
# [audio]
# mixer = software
# mixer_volume = 100
# output = audioconvert ! audio/x-raw,rate=48000,channels=2,format=S16LE ! wavenc ! filesink location=/tmp/snapfifo
# ---------------
# Note: mopidy needs output server mpd,snapcast 
#     : scan notification appears to never end
#######################################
# Nohang - prevent out of memory 
# git clone https://github.com/hakavlad/nohang.git
# nohang --monitor -c /usr/local/etc/nohang/nohang-desktop.conf
#                     /usr/local/etc/nohang/nohang.conf
#######################################
# Spacemacs
# xbps-install emacs-x11
# git clone -b develop https://github.com/syl20bnr/spacemacs ~/.emacs.d
#######################################
# =====================================
# [!] IMPORTANT - POST INSTALLATION [!]
# =====================================
# Dnscrypt-Proxy
# /etc/dnscrypt-proxy.toml
# server_names = ['scaleway-fr', 'google', 'yandex', 'cloudflare']
# listen_addresses = ['127.0.0.1:5335']
# ## Enable a DNS cache to reduce latency and outgoing traffic
# cache = false
# ----------------------------------------
# Unbound
# unbound-checkconf
# unbound-anchor # /etc/dns/root.key
# unbound-control-setup # certificates
# ----------------------------------------
# Borg Backup
# Note: see /etc/fstab for borg mounts
# borg init --encryption=none /mnt/borg-backup::borg
# ----------------------------------------
# fcrontab -e
# Borg Backup - Hourly 
# 0 * * * * /home/$USER/scripts/borg-backup.sh >> /var/log/borg-backup.log 2>&1
# Unbound - Monthly
# @ 1m cd /etc/unbound/unbound-updater && ./unbound-update-blocklist.sh 2>&1
# Bitwarden_rs - 2m after boot
# &bootrun,first(2) * * * * * cd /home/$USER/src/bitwarden_rs/target/release ./bitwarden_rs >> /var/log/bitwarden_rs.log 2>&1
# Vuurmuur - start as daemon
# &bootrun,first(1) * * * * * vuurmuur -D && vuurmuur_log 2>&1
# Osync 2m after boot
# &bootrun,first(2) * * * * * /usr/local/bin/osync.sh /etc/osyncsync.conf --on-changes --silent
#
# Note: fcron 3.3.0 @reboot unknown option
#       fcron 3.2.1 @reboot works # SalixOs(Slackware)
# ---------------------
# /etc/fcron/fcron.conf
# editor = /usr/bin/mle
# ---------------------
# Network - WIFI
# xbps-install iwd openresolv iproute2 
# sv start iwd
# iw dev wlan0 scan | grep SSID
# iwctl --passphrase="password-goes-here" station wlan0 connect "$routerssid"
# password file >> /var/lib/iwd/routerssid
# -------------
# /etc/iwd/main.conf
# [General]
# EnableNetworkConfiguration=true
# UseDefaultInterface=true
#
# [Network]
# NameResolvingService=resolvconf
# ------------
# Openresolv
# /etc/resolvconf.conf
# name_servers=127.0.0.1 # default
# resolv_conf_options=edns0
# ---------------
# resolvconf -u # updates /etc/resolv.conf
# --------------------
# Mpv
# mpv --audio-device=sndio video.mkv
# .config/mpv/mpv.conf
# audio-device=sndio
# Notes: mpv will run slowly if mpv.conf is missing
#      : mpv,smplayer will have video/audio desynchronization errors if Audio output driver is not set to sndio
#      : sndio no longer supported
# ---------------------------
# OpenAL
# cp /usr/share/examples/libopenal/alsoftrc.sample ~/.alsoftrc
# [ general ]
# drivers = sndio
# ---------------------------
# Printer
# Notes:
#       test page doesn't print correctly - zathura prints pdf ok 
#       system-config-printer # gui glitchy fails to render # only tested with herbstluftwm
# 
# xbps-install cups cups-filters gutenprint
# ln -s /etc/sv/cupsd /etc/runit/runsvdir/default
# ln -s /etc/sv/cups-browsed /etc/runit/runsvdir/default
# Cups Administration 127.0.0.1:631 # login as root
#                               >>> Advanced >> Advertise web interface
#                                            >> Allow remote admin
# -----------------------------------------------------------------
# Scanner
# xbps-install simple-scan skanlite sane
# sane-find-scanner
# scanimage -L
#
# Notes: imagescan(EPSON Image Scan v3) fails to detect scanner(epson v700)
#        12800dpi >> Empty filename passed to function, sane_start= Invalid argument
#        simple-scan >> 2400dpi
#        skanlite >> 9600dpi
# ----------------------------
# Blank screen 1m turn off 2m
# setterm --blank 1 --powerdown 2
# -------------------------------
#########################################
################# Email #################
#########################################
# xbps-install isync notmuch afew astroid aerc
# ----------------------
# Mbsync
# Notes: isync(mbsync) is faster then offlineimap
# .mbsyncrc
# -----------
# IMAPAccount email
# Host mail.server
# User
# Pass *********
# PassCmd "bw get password 'xxx xxx'" # bitwarden cli
# SSLType IMAPS
# CertificateFile /etc/ssl/certs/ca-certificates.crt
#
# IMAPStore email-remote
# Account email
#
# MaildirStore email-local
# Path ~/.mail/email/
# Inbox ~/.mail/email/Inbox
# Subfolders Verbatim
#
# Channel email
# Master :email-remote:
# Slave :email-local:
# Patterns *
# Create Both
# Sync Pull
# SyncState *
# -----------------
# Aerc
# .config/aerc/accounts.conf
# -----------------
# [title]
# source = imaps://email%40address:password@mail.server
# outgoing = smtps+plain://email%40address:password@mail.server
# default = Inbox
# from = name <email@address>
# copy-to =
# -------------------
# Lieer - Gmail
# git clone https://github.com/gauteh/lieer.git
# xbps-install python3-pip python3-google-api-python-client notmuch python3-tqdm python3-yarl python3-oauth2client
# cd lieer && pip install .
# -----------------------------
# Ripmime - Extract Email Attachments - Requires glibc to build - binary will run on musl
# https://pldaniels.com/ripmime/
# git clone https://github.com/inflex/ripMIME.git
# make
# make install
# ripmime -i file . # extract to current directory
# ripmime -i file -d /tmp
##############################
# Femtomail
# xbps-install make gcc git
# git clone https://git.lekensteyn.nl/femtomail.git
# cd femtomail
# make USERNAME=root MAILBOX_PATH=/var/mail
# make install install-link-sendmail setcap
# mkdir -p /var/mail/new/
#### [!] Warning [!] ####
# make uninstall - will delete symbolic link /usr/sbin and not femtomail
#### email-test.sh
# #!/bin/bash
# (echo Subject: testING; echo) | sendmail $USER
##########################################################
# Nvidia
# https://nouveau.freedesktop.org/wiki/VideoAcceleration/
# $ mkdir /tmp/nouveau
# $ cd /tmp/nouveau
# $ wget https://raw.github.com/envytools/firmware/master/extract_firmware.py
# $ wget http://us.download.nvidia.com/XFree86/Linux-x86/325.15/NVIDIA-Linux-x86-325.15.run
# $ sh NVIDIA-Linux-x86-325.15.run --extract-only
# $ python2 extract_firmware.py  # this script is for python 2 only
# mkdir /lib/firmware/nouveau
# cp -d nv* vuc-* /lib/firmware/nouveau/
#
# List gpu driver in use
# lshw -class video | grep driver=
# configuration: driver=nouveau latency=0
#
# Note: NVIDIA-Linux-x86-390.138 Latest
#       Nvidia driver not compatible with Musl
#       vuc-* files don't exist
#       chromium browser errors without /lib/firmware/nouveau
# -------------------
# Chromium
# Error: /etc/machine-id contains 0 characters (32 were expected).
# doas ln -s /var/lib/dbus/machine-id /etc/
# --------------------
# VLC
# settings to prevent/mitigate TS discontinuity errors
#      | disable "Trust in-stream PCR"
#      | enable "Seek based on percent not time"
# w_scan -c AU -L >> channels.xspf
# Note: installing xset prevents screensaver error
# ---------------------
# Gparted
# xbps-install gparted polkit-gnome
# Note: polkit-gnome allows gparted to be started by $USER via icon
#       xhost allows ROOT to open display
# -------------
# xhost +si:localuser:root # add user
# doas gparted
# xhost -si:localuser:root # remove user
# -------------
# doas env DISPLAY=$DISPLAY XAUTHORITY=$XAUTHORITY gparted
##################################################################
##################################################################
# exit on error 
set -e

# Make terminal clean
clear

echo '*********************************************'
echo '*********************************************'
echo '**** VOID LINUX MUSL x86_64 INSTALLATION ****'
echo '****            EFI Stub Boot            ****'
echo '*********************************************'
echo '*********************************************'

#############################################
#############################################
#### [!] START OF USER CONFIGURATION [!] ####
#############################################
#############################################

# Change font to be more legible
setfont Lat2-Terminus16

# Ignored Packages
echo "ignorepkg=sudo" > /etc/xbps.d/10-ignore.conf

# System Packages
pkg_listsys='base-minimal'\
' void-repo-nonfree'\
' void-release-keys'\
' signify'

# Common Packages
  pkg_listc='aria2'\
' atool'\
' bash'\
' bwm-ng'\
' chrony'\
' dosfstools'\
' dracut'\
' exfat-utils'\
' ntfs-3g'\
' fcron'\
' fd'\
' ffmpeg'\
' glances'\
' hddtemp'\
' inetutils'\
' inxi'\
' iproute2'\
' kbd'\
' linux-firmware'\
' linux-firmware-intel'\
' lm_sensors'\
' lnav'\
' lr'\
' mle'\
' nano'\
' ncurses'\
' ncurses-devel'\
' nfs-utils'\
' opendoas'\
' openssh'\
' p7zip'\
' pciutils'\
' PopCorn'\
' rsnapshot'\
' smartmontools'\
' socklog-void'\
' tree'\
' vsv'\
' wget'\
' xterm'\
' gcc'\
' dtach'\
' make'\
' git'\
' pkg-config'\
' man-pages'\
' mdocml'\
' curl'\
' gptfdisk'\
' unzip'\
' unrar'\
' zstd'\
' ranger'\
' font-tamsyn'\
' starship'\
' xz'\
' lshw'\
' fuse-sshfs'\
' borg'\
' restic'\
' ncdu'\
' lsscsi'\
' lsof'\
' pam'\
' detox'

# Desktop Packages
  pkg_list='chromium'\
' filezilla'\
' firefox'\
' herbstluftwm'\
' iwd'\
' ddrescue'\
' zpaq'\
' kid3'\
' libinput-gestures'\
' linux-firmware-nvidia'\
' micro'\
' smplayer'\
' sndio'\
' tlp'\
' xf86-input-wacom'\
' xorg-minimal'\
' sakura'\
' mesa'\
' mesa-demos'\
' mesa-vulkan-intel'\
' mesa-nouveau-dri'\
' mesa-intel-dri'\
' mesa-dri'\
' mesa-vaapi'\
' mesa-vdpau'\
' autorandr'\
' w3m-img'\
' sxiv'\
' xwallpaper'\
' mupdf'\
' aerc'\
' bind-utils'\
' unbound'\
' dnscrypt-proxy'\
' imlib2-devel'\
' pam-devel'\
' libgcrypt-devel'\
' libXrender-devel'\
' ffmpeg-devel'\
' libavcodec'\
' libavformat'\
' libavutil'\
' wavpack-devel'\
' libmp4v2-devel'\
' libflac-devel'\
' libsndfile-devel'\
' libvorbis-devel'\
' mpg123-devel'\
' faad2-devel'\
' sndio-devel'\
' opusfile-devel'\
' papirus-icon-theme'\
' aucatctl'\
' sox'\
' polybar'\
' vlc'\
' w_scan'\
' xset'\
' fontmanager'\
' libmnl-devel'\
' dialog'\
' ghostwriter'\
' dunst'\
' udiskie'\
' keychain'\
' nemo'\
' nemo-fileroller'\
' ffmpegthumbnailer'\
' gvfs'\
' gvfs-afp'\
' gvfs-cdda'\
' gvfs-smb'\
' gvfs-afc'\
' gvfs-mtp'\
' gvfs-gphoto2'\
' gconf-editor'\
' alsa-utils'\
' libopenal'\
' upower'\
' gtk+3'\
' qalculate'\
' xclip'\
' rofi'\
' rofi-calc'\
' fzy'\
' fzf'\
' xwininfo'\
' redshift-gtk'\
' xbanish'\
' arc-theme'\
' arc-icon-theme'\
' faience-icon-theme'\
' faenza-icon-theme'\
' xsetroot'\
' recoll'\
' i3lock-color'\
' dbus-elogind-x11'\
' elogind'\
' asciiquarium'\
' astroid'\
' nerd-fonts'\
' noto-fonts-cjk'\
' overpass-otf'\
' google-fonts-ttf'\
' font-iosevka'\
' emacs-x11'\
' autocutsel'\
' shellcheck'\
' caddy'\
' automake'

# Server Packages
  pkg_listsrv='lftp'\
' xfsprogs'\
' e2fsprogs'\
' snapraid'\
' mergerfs'\
' castget'\
' newsboat'\
' minidlna'\
' ipmitool'

###################
##### Desktop #####
###################
username="vade"
groups="wheel,storage,video,audio,lp,cdrom,optical,scanner,socklog"
services="caddy dnscrypt-proxy unbound cupsd cups-browsed sshd chronyd fcron iwd socklog-unix nanoklogd hddtemp popcorn tlp sndiod dbus statd rpcbind cgmanager polkitd"
hostname="void"

### /home/$USER/.bashrc
bashrc="$(cat <<'EOF'
# ---------------------
# Eternal bash history.
# ---------------------
# Undocumented feature which sets the size to "unlimited".
# http://stackoverflow.com/questions/9457233/unlimited-bash-history
export HISTFILESIZE=
export HISTSIZE=
export HISTTIMEFORMAT="[%F %T] "
# Change the file location because certain bash sessions truncate .bash_history file upon close.
# http://superuser.com/questions/575479/bash-history-truncated-to-500-lines-on-each-login
export HISTFILE=~/.bash_eternal_history
# Force prompt to write history after every command.
# http://superuser.com/questions/20900/bash-history-loss
PROMPT_COMMAND="history -a; $PROMPT_COMMAND"
# ---------------------
scripts/buffquote
eval "$(starship init bash)"
# export PS1="\n\[\e[0;32m\]\u@\h[\t]\[\e[0;31m\] \['\$PWD'\] \[\e[0;32m\]\[\e[0m\]\[\e[0;32m\]>>>\[\e[0m\]\n "
# Rust pkg path ".local/bin"
# Python3 pkg path "~/.local/bin"
export PATH=".local/bin:$PATH"
export TERMINAL=sakura
# Weather Check
alias weather='curl wttr.in/?0'
alias w="curl wttr.in/~Adelaide"
alias poweroff='doas /sbin/poweroff'
alias reboot='doas /sbin/reboot'
alias clips="clipster -o -n 10000 -0 | fzf --read0 --no-sort --reverse --preview='echo {}' | sed -ze 's/\n$//' | clipster"
alias clipsr="clipster --delete"
alias clipsc="clipster --erase-entire-board"
alias key="grep Mod ~/.config/herbstluftwm/autostart | sed 's/hc\ keybind\ / /' | sed 's/hc\ / /' | rofi -dmenu"
# Firefox has a habit of not responding and 'killall' doesn't always work
alias kf="pgrep -f firefox | xargs kill -9"
EOF
)"

### /home/$USER/.bash_profile
bashprofile="$(cat <<'EOF'
# Get the aliases and functions
[ -f $HOME/.bashrc ] && . $HOME/.bashrc
# exec startx prevents 'ssh' login
# exec startx
EOF
)"

### /home/$USER/.xinitrc
xinitrc="$(cat <<'EOF'
# [!] 'startx' will exit immediately if program cannot be found
#
# xss-lock -- ~/.config/i3/lock.sh -l &
# xss-lock -- sakura -s -x asciiquarium & alock -bg none; xdotool key --clearmodifiers q
# polkit-gnome needed to start gparted as $USER
/usr/libexec/polkit-gnome-authentication-agent-1 &
exec dbus-launch --exit-with-session --sh-syntax herbstluftwm --locked
EOF
)"

##################
##### Server #####
##################
usernamesrv="void"
groupsrv="wheel,storage,cdrom,optical,socklog"
srvservices="sshd acpid chronyd fcron socklog-unix nanoklogd hddtemp popcorn statd rpcbind smartd"
hostnamesrv="void2"

### /home/$USER/.bashrc
bashrcsrv="$(cat <<'EOF'
# --------------------
# Eternal bash history.
# ---------------------
# Undocumented feature which sets the size to "unlimited".
# http://stackoverflow.com/questions/9457233/unlimited-bash-history
export HISTFILESIZE=
export HISTSIZE=
export HISTTIMEFORMAT="[%F %T] "
# Change the file location because certain bash sessions truncate .bash_history file upon close.
# http://superuser.com/questions/575479/bash-history-truncated-to-500-lines-on-each-login
export HISTFILE=~/.bash_eternal_history
# Force prompt to write history after every command.
# http://superuser.com/questions/20900/bash-history-loss
PROMPT_COMMAND="history -a; $PROMPT_COMMAND"
# --------------------
scripts/buffquote
eval "$(starship init bash)"
export PATH="~/.local/bin:$PATH"
alias poweroff='doas /sbin/poweroff'
alias reboot='doas /sbin/reboot'
EOF
)"

##################
##### System #####
##################
### /etc/doas.conf
doasconf="$(cat <<'EOF'
permit persist :wheel
permit nopass :wheel as root cmd /sbin/poweroff
permit nopass :wheel as root cmd /sbin/reboot
EOF
)"

### Hardrive Label
labelroot="VOID_LINUX"
labelfat="EFI"

### /etc/rc.conf
KEYMAP="us"
TIMEZONE="Australia/Adelaide"
HARDWARECLOCK="UTC"
FONT="Tamsyn8x16r"
TTYS="2"

### Create directories /home/$USER/
dirs="exclusions src"

###################
##### Network #####
###################
### For dhcp leave ipstaticeth0 empty and install dhcpd ie ndhc
ipstaticeth0="192.168.1.X"
### For dhcp leave ipstaticwlan0 empty (iwd includes dhcp)
ipstaticwlan0=""
routerssid=""
gateway="192.168.1.1"
wifipassword=""
### openresolv is required for iwd (wifi) to access internet
# and uses /etc/resolvconf.conf with optional /etc/resolv.conf
openresolv="YES" # any other value if not used
### nameserver0 is for dnscrypt-proxy (not needed if using openresolv)		
nameserver0="127.0.0.1"
### nameserver{1,2} is for /etc/resolv.conf or resolvconf.conf
# Cloudflare "1.0.0.1" "1.1.1.1" # Google "8.8.4.4" "8.8.8.8"
nameserver1="1.0.0.1"
nameserver2="1.1.1.1" 

######################
##### Repository #####
######################

### [!] Leave repopath & cachedir empty to use default repository /var/cache/xbps [!]

### Path to packages that have already been downloaded
# xbps-install --repository $repopath $pkg_list
repopath=""  

### Save packages to somewhere other then /var/cache/xbps
# xbps-install -R $repo0..2 --download-only --cachedir $cachedir $pkg_list && cd $repopath && xbps-rindex --add *xbps
cachedir="/opt/void_pkgs"

### Repository Urls /etc/xbps.d/00-repository-{main.conf,nonfree.conf}
repo0="https://ftp.swin.edu.au/voidlinux/current/musl"
repo1="https://mirror.aarnet.edu.au/pub/voidlinux/current/musl" # connection tends to be flaky
repo2="http://alpha.de.repo.voidlinux.org/current/musl"

###########################################
###########################################
#### [!] END OF USER CONFIGURATION [!] ####
###########################################
###########################################

# /dev/mmcblk0 is SDCARD on Lenovo Thinkpad T420 & T520
echo ''
echo '************************************************'
echo -e '******************* \x1B[1;31m WARNING \x1B[0m ******************'
echo '************************************************'
echo '**** Script is preconfigured for UEFI & GPT ****'
echo '****                                        ****'
echo '**** Partition Layout : Fat-32 EFI of 550MB ****'
echo '****                  : / 100%              ****'
echo '************************************************'
echo ''
lsblk -f -l | grep -e sd -e mmcblk
echo ''
echo '****************************************'
echo '[!] Verify Connected Drive Is Listed [!]'
echo '****************************************'
# Generate drive options dynamically
PS3="Select drive to format: "
echo ''
select device in $(blkid | grep -e sd -e mmcblk0 | cut -d : -f 1 | sed -e 's/\p//g' -e 's/[1-9]\+$//' | uniq | sort)
do
if [[ $device = "" ]]; then
echo "try again"
continue
fi
break
done
echo "$device has been selected"
echo
# PS3='Select your device: '
# options=('sda' 'sdb' 'sdc')
# select opt in "${options[@]}"
# do
# case $opt in
#    'sda')
#      devname='/dev/sda'
#      break
#      ;;
#    'sdb')
#      devname='/dev/sdb'
#      break
#      ;;
#    'sdc')
#      devname='/dev/sdc'
#      break
#      ;;
#    *)
#      echo 'This option is invalid.'
#      ;;
#  esac
# done

PS3="Select installation type : "
options=('Desktop' 'Server')
select opt in "${options[@]}"
do
case $opt in
    'Desktop')
      pkg_list="$pkg_list $pkg_listc $pkg_listsys"
      username="$username"
      services="$services"
      groups="$groups"
      hostname="$hostname"
      bashrc="$bashrc"
      break
      ;;
    'Server')
      pkg_list="$pkg_listsrv $pkg_listc $pkg_listsys"
      username="$usernamesrv"
      services="$srvservices"
      groups="$groupsrv"
      hostname="$hostnamesrv"
      bashrc="$bashrcsrv"
      break
      ;;
    *)
      echo 'This option is invalid.'
      ;;
esac
done

# Add repositories to live USB/Cd
tee /etc/xbps.d/00-repository-main.conf <<EOF
repository=$repo0 
repository=$repo1
repository=$repo2
EOF

tee /etc/xbps.d/10-repository-nonfree.conf <<EOF
repository=$repo0/nonfree
repository=$repo1/nonfree
repository=$repo2/nonfree
EOF

# Detect if we're in UEFI or legacy mode
[[ -d /sys/firmware/efi ]] && UEFI=1
if [[ $UEFI ]]; then
echo -e "\x1B[1;92m ************ [!] Found UEFI [!] ************ \x1B[0m" 
pkg_list="$pkg_list efibootmgr"
else
echo -e "\x1B[1;31m ************ [!] UEFI Not found [!] ************ \x1B[0m"
fi

# Detect if we're on an Intel system
cpu_vendor=$(grep vendor_id /proc/cpuinfo | awk '{print $3}')
if [[ $cpu_vendor = GenuineIntel ]]; then
pkg_list="$pkg_list intel-ucode"
fi

if [[ $openresolv = YES ]]; then
pkg_list="$pkg_list openresolv"
fi

# Install Prerequisites to Live USB/Cd
# setting password requires pam

if [[ $repopath != "" ]]; then
xbps-install -u -y xbps -R $repopath
xbps-install -R $repopath -y gptfdisk pam $fstype dosfstools

elif [[ $cachedir != "" ]]; then
mkdir -p $cachedir
xbps-install -S -y --download-only --cachedir $cachedir $pkg_list $fstype
cd $cachedir
xbps-rindex -a *xbps
xbps-install -u -y xbps -R $cachedir
xbps-install -S -R $cachedir
xbps-install -R $cachedir -y gptfdisk pam $fstype dosfstools

elif [[ $cachedir = "" && $repopath = "" ]]; then
xbps-install -S
xbps-install -u -y xbps
xbps-install -S
xbps-install -y gptfdisk pam $fstype dosfstools
fi

echo ''
echo '************************************'
echo '**** FILE SYSTEM TYPE SELECTION ****'
echo '************************************'
echo ''
echo '[!] Retry if valid selection fails [!]'
echo ''
PS3='Select file system to format partition: '
filesystems=('btrfs' 'ext4' 'xfs' 'f2fs')
select filesysformat in "${filesystems[@]}"
do
  case $filesysformat in
    'btrfs')
      fsys1='btrfs'
      pkg_list="$pkg_list btrfs-progs"
      fstype="btrfs-progs"
      break
      ;;
    'xfs')
      fsys1='xfs'
      pkg_list="$pkg_list xfsprogs"
      fstype="xfsprogs"
      break
      ;;
    'ext4')
      fsys2='ext4'
      pkg_list="$pkg_list e2fsprogs"
      fstype="e2fsprogs"
      break
      ;;
      'f2fs')
      fsys3='f2fs'
      pkg_list="$pkg_list f2fs-tools"
      fstype="f2fs-tools"
      break
      ;;
    *)
      echo 'This option is invalid.'

esac
done

# Erase partition table
# wipefs -a /dev/$devname
# dd if=/dev/zero of=/dev/$devname bs=1M count=100

# Create partitions
# xbps-install -y -S -f parted
# if [[ $UEFI ]]; then
  # parted /dev/${DEVNAME} mklabel gpt
  # parted -a optimal /dev/${devname} mkpart primary 2048s 100M
  # parted -a optimal /dev/${devname} mkpart primary 100M 100%
# else
  # parted /dev/${devname} mklabel msdos
  # parted -a optimal /dev/${devname} mkpart primary 2048s 512M
  # parted -a optimal /dev/${devname} mkpart primary 512M 100%
# fi
# parted /dev/${devname} set 1 boot on

# Create GPT partition table
echo ''
if [[ $UEFI ]]; then
sgdisk --zap-all $device
sgdisk -n 1:2048:550M -t 1:ef00 $device
sgdisk -n 2:0:0 -t 2:8300 $device
sgdisk --verify $device
fi
echo ''

clear

# Format filesystems
# fat-32
if [[ $UEFI && $device = /dev/mmcblk0 ]]; then
mkfs.vfat -F 32 -n EFI ${device}p1
 
elif [[ $UEFI && $device != /dev/mmcblk0 ]]; then
mkfs.vfat -F 32 -n $labelfat ${device}1
fi

# ${fsys1} -f -L
# btrfs
# xfs
if [[ $fsys1 && $device = /dev/mmcblk0 ]]; then
mkfs.$fsys1 -f -L $labelroot ${device}p2

elif [[ $fsys1 && $device != /dev/mmcblk0 ]]; then
mkfs.$fsys1 -f -L $labelroot ${device}2
fi 

# ${fsys2} -F -L
# ext4 
if [[ $fsys2 && $device = /dev/mmcblk0 ]]; then
mkfs.$fsys2 -F -L $labelroot ${device}p2

elif [[ $fsys2 && $device != /dev/mmcblk0 ]]; then
mkfs.$fsys2 -F -L $labelroot ${device}2
fi

if [[ $fsys3 ]]; then
echo "1) Encrypt = encrypt,extra_attr,sb_checksum,inode_checksum,lost_found"
echo "2) No Encryption = extra_attr,sb_checksum,inode_checksum,lost_found"
echo "3) No Checksums = lost_found"
echo "4) None = No Options"
echo
echo "Notes: f2fs-tools v1.14"
echo "       | encrypt does not work with 'casefold/utf8'"
echo "       | casefold doesn't work without utf8"
echo "       | compression unknown option"
echo "       | keyboard momentarily stopped working (casefold was used)"

PS3='Select f2fs options to use: '
select opts in "Encrypt" "No Encryption" "No Checksums" "None"; do
    case $opts in
    'Encrypt')
      fsys3="$fsys3 -O encrypt,extra_attr,sb_checksum,inode_checksum,lost_found"
      break
      ;;
    'No Encryption')
      fsys3="$fsys3 -O extra_attr,sb_checksum,inode_checksum,lost_found"
      break
      ;;
    'No Checksums')
      fsys3="$fsys3 -O lost_found"
      break
      ;;
    'None')
      fsys3="$fsys3"
      break
      ;;
*) echo Try again

esac
done
fi

# ${fsys3} -f -l
# f2fs
if [[ $fsys3 && $device = /dev/mmcblk0 ]]; then
mkfs.$fsys3 -f -l $labelroot ${device}p2
 
elif [[ $fsys3 && $device != /dev/mmcblk0 ]]; then
mkfs.$fsys3 -f -l $labelroot ${device}2
fi

# Mount them
if [[ $device = /dev/mmcblk0 ]]; then
mount ${device}p2 /mnt

elif [[ $device != /dev/mmcblk0 ]]; then 
mount ${device}2 /mnt
fi

if [[ $UEFI ]]; then
mkdir -p /mnt/boot/efi
fi

if [[ $device = /dev/mmcblk0 ]]; then
mount ${device}p1 /mnt/boot/efi

elif [[ $device != /dev/mmcblk0 ]]; then
mount ${device}1 /mnt/boot/efi
fi

# Create Chroot Gaol
for dir in dev proc sys; do
 mkdir /mnt/$dir
 mount -o bind /$dir /mnt/$dir
done

# Alternative mount options 
# Conflicting information abounds
# mount -t proc proc /mnt/proc
# mount -t sysfs sys /mnt/sys
# mount -o bind /dev /mnt/dev
# mount -t devpts pts /mnt/dev/pts
#
# mount -t proc /proc proc/
# mount --rbind /sys sys/
# mount --rbind /dev dev/
#
# mount --rbind /sys /mnt/sys && mount --make-rslave /mnt/sys
# mount --rbind /dev /mnt/dev && mount --make-rslave /mnt/dev
# mount --rbind /proc /mnt/proc && mount --make-rslave /mnt/proc

# Import keys from live image to prevent prompt for key confirmation
mkdir -p /mnt/var/db/xbps/keys/
cp -a /var/db/xbps/keys/* /mnt/var/db/xbps/keys/

echo '**********************************'
echo '**** CHECKING KERNEL VERSIONS ****'
echo '**********************************'
# Get currently running kernel version
kver=$(xbps-query linux | awk '$1 == "pkgver:" { print $2 }' | sed -e 's/linux-//' -e 's/_.*$//')
echo "Live CD kernel version $kver"
echo '**************************'
echo 'Choose a kernel to install'
echo '**************************'
PS3="Select kernel: " 
select kernel in $(xbps-query --repository=$repopath --regex -Rs '^linux[0-9.]+-[0-9._]+' | sed -e 's/\[-\] //' -e 's/_.*$//' | cut -d - -f 1 | sort | uniq)
do
if [[ $kernel = "" ]]; then
echo "$REPLY is not valid"
continue
fi
break
done

pkg_list="$pkg_list $kernel"

# Package Installation
if [[ $repopath != "" ]]; then
xbps-install -R $repopath -r /mnt $pkg_list -y

elif [[ $cachedir != "" ]]; then
xbps-install -S --download-only --cachedir $cachedir $pkg_list -y
cd $cachedir
xbps-rindex -a *xbps
xbps-install -R $cachedir -r /mnt $pkg_list -y

elif [[ $cachedir = "" && $repopath = "" ]]; then
xbps-install -S -r /mnt $pkg_list -y
fi

# Add repositories
# cp /mnt/usr/share/xbps.d/*-repository-*.conf /mnt/etc/xbps.d
cp /etc/xbps.d/10-ignore.conf /mnt/etc/xbps.d
cp /etc/xbps.d/00-repository-main.conf /mnt/etc/xbps.d
cp /etc/xbps.d/10-repository-nonfree.conf /mnt/etc/xbps.d

# Activate services
for srv in $services; do
 chroot /mnt ln -s /etc/sv/$srv /etc/runit/runsvdir/default/
done

# Get / UUID
rootuuid=$(blkid -s UUID -o value ${device}2 | cut -d = -f 3 | cut -d " " -f 1 | grep - | tr -d '"')

# Configure efibootmgr
# efibootmgr -c -d /dev/sda -p 1 -l '\vmlinuz-5.7.7_1' -L 'Void' initrd=\initramfs-5.7.7_1.img root=/dev/sda2
cp /etc/default/efibootmgr-kernel-hook /mnt/etc/default/efibootmgr-kernel-hook.bak

# Pressure Stall Information (PSI)
#       Add "psi=1" to enable
# OPTIONS=root="${device}2" >> boot will fail if OS is on /dev/sdb and /dev/sda is removed
if [[ $device != /dev/mmcblk0 ]]; then
tee /mnt/etc/default/efibootmgr-kernel-hook <<EOF
MODIFY_EFI_ENTRIES=1
OPTIONS="root=UUID=$rootuuid loglevel=4 Page_Poison=1 psi=1"
DISK="$device"
PART=1
EOF

elif [[ $device = /dev/mmcblk0 ]]; then
tee /mnt/etc/default/efibootmgr-kernel-hook <<EOF
MODIFY_EFI_ENTRIES=1
OPTIONS=root="${device}p2 loglevel=4 Page_Poison=1"
DISK="$device"
PART=1
EOF
fi

# Add fstab entries
if [[ $UEFI && $device = /dev/mmcblk0 ]]; then
echo "${device}p1   /boot/efi   vfat    defaults     0 0" >> /mnt/etc/fstab

elif [[ $UEFI && $device != /dev/mmcblk0 ]]; then
echo "LABEL=$labelfat   /boot/efi   vfat    defaults     0 0" >> /mnt/etc/fstab
fi
# echo "LABEL=root  /       ext4    rw,relatime,data=ordered,discard    0 0" > /mnt/etc/fstab
# echo "LABEL=boot  /boot   ext4    rw,relatime,data=ordered,discard    0 0" >> /mnt/etc/fstab

if [[ $fsys3 ]]; then
echo "# Boot fails if fsck.f2fs <pass> is enabled" >> /mnt/etc/fstab
echo "UUID=$rootuuid   /       f2fs   defaults           0 0" >> /mnt/etc/fstab 
else
echo "UUID=$rootuuid   /       $fsys1 $fsys2   defaults    0 1" >> /mnt/etc/fstab
fi

if [[ $opt = Server ]]; then
echo "/Volumes/data* /Volumes/storage fuse.mergerfs category.create=mfs,defaults,allow_other,minfreespace=20G,fsname=mergerfsPool	0 0" >> /mnt/etc/fstab
echo "# /mnt/storage/$USER		/home/$USER		none	bind,rw		0 0" >> /mnt/etc/fstab
fi

# Reconfigure kernel and create initramfs (dracut) and efi boot entry (efibootmgr)
xbps-reconfigure -fa -r /mnt $kernel
cp /mnt/boot/initramfs* /mnt/boot/efi
cp /mnt/boot/vmlinuz* /mnt/boot/efi

# Networking
# iwd requires openresolv to connect to internet which interns uses /etc/resolvconf.conf
# resolvconf -u # updates /etc/resolv.conf
if [[ -f /mnt/etc/resolvconf.conf && -f /mnt/sbin/dnscrypt-proxy ]]; then
echo "resolv_conf_options=edns0" >> /mnt/etc/resolvconf.conf

elif [[ ! -f /mnt/etc/resolvconf.conf && -f /mnt/sbin/dnscrypt-proxy ]]; then
echo "nameserver $nameserver0" >> /mnt/etc/resolv.conf
echo "options edns0" >> /mnt/etc/resolv.conf

elif [[ ! -f /mnt/etc/resolvconf.conf && ! -f /mnt/sbin/dnscrypt-proxy ]]; then
echo "nameserver $nameserver1" >> /mnt/etc/resolv.conf
echo "nameserver $nameserver2" >> /mnt/etc/resolv.conf

elif [[ -f /mnt/etc/resolvconf.conf && ! -f /mnt/sbin/dnscrypt-proxy ]]; then
echo "nameserver $nameserver1" >> /mnt/etc/resolvconf.conf
echo "nameserver $nameserver2" >> /mnt/etc/resolvconf.conf
fi

# Static IP configuration via iproute2
eth=$(ip link | grep enp | cut -d : -f 2)
echo "ip link set dev $eth up" >> /mnt/etc/rc.local
echo "ip addr add $ipstaticeth0/24 brd + dev $eth" >> /mnt/etc/rc.local
echo "ip route add default via $gateway" >> /mnt/etc/rc.local

# Use static Wifi (dynamic is default)
if [[ $ipstaticwlan0 ]]; then
tee /mnt/etc/iwd/main.conf <<EOF
[General]
EnableNetworkConfiguration=true
EOF
fi

# Set static ip address for wifi
if [[ $ipstaticwlan0 ]]; then 
tee /mnt/var/lib/iwd/${routerssid}.psk <<EOF
[IPv4]
Address="${ipstaticwlan0}"
#Netmask=255.255.255.0
Gateway="$gateway"
#Broadcast=192.168.1.255
#DNS=""
EOF
fi

# Overwrite LIVE ISO hostname
# [!] Not changing hostname will fail at boot with the following error:
# [!] Kernel Panic - not syncing: VFS: Unable to mount root fs on unknown-block(0,0)
echo $hostname > /mnt/etc/hostname

# hosts
# cp /mnt/etc/hosts /mnt/etc/hosts.bak
# Apparenty adding hostname to hosts is unnecessary
# echo "127.0.0.1 $HOSTNAME localhost" > /mnt/etc/hosts

echo "TIMEZONE=$TIMEZONE" >> /mnt/etc/rc.conf
echo "HARDWARECLOCK=$HARDWARECLOCK" >> /mnt/etc/rc.conf
echo "KEYMAP=$KEYMAP" >> /mnt/etc/rc.conf
echo "FONT=$FONT" >> /mnt/etc/rc.conf
echo "TTYS=$TTYS" >> /mnt/etc/rc.conf

# set "root" privileges
# test doas.conf
# $ doas -C /etc/doas.conf
# check permission of command
# $ doas -C /etc/doas.conf command
echo "$doasconf" > /mnt/etc/doas.conf

# Configure user accounts
echo ''
# Add ansi colour codes
echo -e "[!] Create \x1B[1;31m root \x1B[0m password [!]"
echo ''

while true; do
  passwd -R /mnt root && break
  echo 'Password did not match. Please try again'
  sleep 3s
  echo ''
done

echo -e "[!] Create password for user \x1B[01;96m $username \x1B[0m [!]"
echo ''
chroot /mnt useradd -g users -G $groups $username
# Bug? useradd -R /mnt 
# error: configuration error unknown item 'HOME_MODE' (notify administrator)
# home directory is still created

while true; do
  passwd -R /mnt $username && break
  echo 'Password did not match. Please try again'
  sleep 3s
  echo ''
done

# Setup $HOME
echo "$bashrc" > /mnt/home/$username/.bashrc

if [[ $opt = Desktop ]]; then
echo "$bashprofile" > /mnt/home/$username/.bash_profile
echo "$xinitrc" > /mnt/home/$username/.xinitrc
fi

# Herbstluftwm
# chroot --userspec=$username:users /mnt mkdir -p home/$username/.config/herbstluftwm
# chroot --userspec=$username:users /mnt cp etc/xdg/herbstluftwm/autostart home/$username/.config/herbstluftwm

# Create $HOME directories
for dir in $dirs; do
 chroot --userspec=$username:users /mnt mkdir -p home/$username/$dir
done

# Create list of installed packages
xbps-query -r /mnt --list-pkgs > /mnt/home/$username/void-pkgs.log
clear
 
echo '**********************************************************'
echo -e "[!] Check \x1B[1;92m BootOrder: \x1B[1;0m is correct [!]"
echo ' Boot entry needs to be towards the top of list otherwise '
echo '       it will not appear in the boot menu                '
echo '**********************************************************'
echo '**********************************************************'
echo '      Resetting BIOS will restore default boot order      '
echo '**********************************************************'
sleep 5
efibootmgr -v
echo '**********************************************************'
echo '**********************************************************'
echo -e "\x1B[1;32m [!] VOID LINUX INSTALL IS COMPLETE [!] \x1B[0m"
echo '**********************************************************'
echo '**********************************************************'
echo ''
echo "(U)nmount $device and exit"
echo ''
echo '(E)xit'
echo '' 
echo '(R)eboot'
echo ''
echo '(P)oweroff'
echo ''
read -n 1 -p "[ U \ E \ R \ P ]: " ans
# Chroot may fail to unmount hence -l
case $ans in
   r|R)
      umount -l -R /mnt && reboot;;
   p|P)
      umount -l -R /mnt && poweroff;;
   e|E)
      exit;;
   u|U)
      umount -l -R /mnt && exit
esac

#########################
# FIN
#########################
