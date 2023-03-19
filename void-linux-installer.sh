#!/bin/bash

# Exit on error 
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
# Installing with void-live-x86_64-musl-20221001-base.iso
# gawk fails to install due to chroot-gawk being already installed
# Need to install gawk manually "xbps-install gawk"
echo "ignorepkg=gawk" >> /etc/xbps.d/10-ignore.conf

# Prerequisites
prereqs='gptfdisk pam dosfstools'

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
' python3-pip'\
' fd'\
' sshuttle'\
' newsboat'\
' ffmpeg'\
' glances'\
' hddtemp'\
' inetutils'\
' inxi'\
' iproute2'\
' kbd'\
' exa'\
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
' mplayer'\
' mpv'\
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
' gnome-epub-thumbnailer'\
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
' gthumb'\
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
' minidlna'\
' ipmitool'

###################
##### Desktop #####
###################

username="void"
groups="wheel,storage,video,audio,lp,cdrom,optical,scanner,socklog"
services="caddy dnscrypt-proxy unbound cupsd cups-browsed sshd chronyd fcron iwd socklog-unix nanoklogd hddtemp popcorn tlp sndiod dbus statd rpcbind cgmanager polkitd"
hostname="void"

### /home/$USER/.bashrc
bashrc="$(cat <<'EOF'
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
eval "$(starship init bash)"
PATH="$HOME/.local/bin:$PATH"
alias poweroff='doas /sbin/poweroff'
alias reboot='doas /sbin/reboot'
EOF
)"

bashrcwm="$(cat <<'EOF'
sh buffquote
# export PS1="\n\[\e[0;32m\]\u@\h[\t]\[\e[0;31m\] \['\$PWD'\] \[\e[0;32m\]\[\e[0m\]\[\e[0;32m\]>>>\[\e[0m\]\n "
export TERMINAL=sakura
# Weather Check
alias weath='curl wttr.in/?0'
alias weather="curl wttr.in/~Adelaide"
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
# Uncomment startx after sym linking 'config/.config/herbstluftwm'
# 'exec startx' prevents 'ssh' login
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

usernamesrv="void-srv"
groupsrv="wheel,storage,cdrom,optical,socklog"
servicessrv="sshd acpid chronyd fcron socklog-unix nanoklogd hddtemp popcorn statd rpcbind smartd"
hostnamesrv="void-srv"

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

### Create directories /home/$USER/
dirs="exclusions src"

###################
##### Network #####
###################

### For dhcp leave ipstaticeth0 empty and install dhcpd ie ndhc
ipstaticeth0="192.168.1.10"
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
# xbps-install --repository $repo0..2 --download-only --cachedir $cachedir $pkg_list && cd $repopath && xbps-rindex --add *xbps
cachedir="/opt/void_pkgs"

### Repository Urls /etc/xbps.d/00-repository-{main.conf,nonfree.conf}
repo0="https://ftp.swin.edu.au/voidlinux/current/musl"
repo1="https://mirror.aarnet.edu.au/pub/voidlinux/current/musl" # connection tends to be flaky
repo2="http://alpha.de.repo.voidlinux.org/current/musl" # connection can be slow

###########################################
###########################################
#### [!] END OF USER CONFIGURATION [!] ####
###########################################
###########################################

echo ''
echo '************************************************'
echo -e '******************* \x1B[1;31m WARNING \x1B[0m ******************'
echo '************************************************'
echo '**** Script is preconfigured for UEFI & GPT ****'
echo '****                                        ****'
echo '**** Partition Layout : Fat-32 EFI of 550MB ****'
echo '****                  : / 100%              ****'
echo '************************************************'

# Detect if we're in UEFI or legacy mode
[[ -d /sys/firmware/efi ]] && UEFI=1

if [[ $UEFI ]]; then
  echo -e "\x1B[1;92m [!] Found UEFI [!] \x1B[0m" 
  pkg_list="$pkg_list efibootmgr"
else
  echo -e "\x1B[1;31m [!] UEFI Not found [!] \x1B[0m"
  exit 1
fi

lsblk -f -l | grep -e sd -e mmcblk

echo ''
echo '****************************************'
echo '[!] Verify Connected Drive Is Listed [!]'
echo '****************************************'
# /dev/mmcblk0 is SDCARD on Lenovo Thinkpad T420 & T520

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
      pkg_list="$pkg_list $pkg_listc $pkg_listsys $prereqs"
      username="$username"
      services="$services"
      groups="$groups"
      hostname="$hostname"
      bashrc="$bashrc $bashrcwm"
      break
      ;;
    'Server')
      pkg_list="$pkg_listsrv $pkg_listc $pkg_listsys $prereqs"
      username="$usernamesrv"
      services="$servicessrv"
      groups="$groupsrv"
      hostname="$hostnamesrv"
      bashrc="$bashrc"
      break
      ;;
    *)
      echo 'This option is invalid.'
      ;;
esac
done

# Add repositories to live USB/Cd
tee /etc/xbps.d/00-repository-main.conf <<-EOF
  repository=$repo0 
  repository=$repo1
  repository=$repo2
EOF

tee /etc/xbps.d/10-repository-nonfree.conf <<-EOF
  repository=$repo0/nonfree
  repository=$repo1/nonfree
  repository=$repo2/nonfree
EOF

# Detect if we're on an Intel system
cpu_vendor=$(grep vendor_id /proc/cpuinfo | awk '{print $3}')

if [[ $cpu_vendor = GenuineIntel ]]; then
  pkg_list="$pkg_list intel-ucode"
fi

if [[ $openresolv = YES ]]; then
  pkg_list="$pkg_list openresolv"
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

# Install Prerequisites to Live USB/Cd
# setting password requires pam

if [[ $repopath != "" ]]; then
  cd $repopath
  xbps-rindex -a *xbps
  xbps-install -u -y xbps -R $repopath
  xbps-install -R $repopath -y $prereqs $fstype
else
  xbps-install -S
  xbps-install -u -y xbps
  xbps-install -S
  xbps-install -y $prereqs $fstype
fi

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
  echo "       | keyboard functioned intermittently (casefold was used)"

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

  [[ $device = /dev/mmcblk0 ]] && \
  mount ${device}p1 /mnt/boot/efi

  [[ $device != /dev/mmcblk0 ]] && \
  mount ${device}1 /mnt/boot/efi
fi

# Create Chroot Gaol
mkdir /mnt/{dev,proc,sys}

mount -o bind /dev /mnt/dev
mount -o bind /proc /mnt/proc
  
# EFI varibles
# /sys/firmware/efi/efivars/ 
mount --rbind /sys /mnt/sys

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
select kernel in $(xbps-query --regex -Rs '^linux[0-9.]+-[0-9._]+' | sed -e 's/\[-\] //' -e 's/_.*$//' | cut -d - -f 1 | sort | uniq)
do
if [[ $kernel = "" ]]; then
  echo "$REPLY is not valid"
continue
fi
break
done

pkg_list="$pkg_list $kernel"

# Add repositories
mkdir -p /mnt/etc/xbps.d
# cp /mnt/usr/share/xbps.d/*-repository-*.conf /mnt/etc/xbps.d
cp /etc/xbps.d/10-ignore.conf /mnt/etc/xbps.d
cp /etc/xbps.d/00-repository-main.conf /mnt/etc/xbps.d
cp /etc/xbps.d/10-repository-nonfree.conf /mnt/etc/xbps.d

# Package Installation
if [[ $repopath != "" ]]; then
  cd $repopath
  xbps-rindex -a *xbps
  xbps-install -R $repopath -r /mnt $pkg_list -y

elif [[ $cachedir != "" ]]; then
  xbps-install --download-only --cachedir $cachedir $pkg_list -y
  cd $cachedir
  xbps-rindex -a *xbps
  xbps-install -R $cachedir -r /mnt $pkg_list -y

elif [[ $cachedir = "" && $repopath = "" ]]; then
  xbps-install -S -r /mnt $pkg_list -y
fi

# Activate services
for srv in $services; do
  chroot /mnt ln -s /etc/sv/$srv /etc/runit/runsvdir/default/
done

# Get / UUID
rootuuid=$(blkid -s UUID -o value ${device}2 | cut -d = -f 3 | cut -d " " -f 1 | grep - | tr -d '"')

# Configure efibootmgr
# efibootmgr -c -d /dev/sda -p 1 -l '\vmlinuz-5.7.7_1' -L 'Void' initrd=\initramfs-5.7.7_1.img root=/dev/sda2
cp /etc/default/efibootmgr-kernel-hook /mnt/etc/default/efibootmgr-kernel-hook.orig

# Pressure Stall Information (PSI)
# OPTIONS=root="${device}2" >> boot will fail if OS is on /dev/sdb and /dev/sda is removed
if [[ $device != /dev/mmcblk0 ]]; then
  tee /mnt/etc/default/efibootmgr-kernel-hook <<-EOF
  MODIFY_EFI_ENTRIES=1
  OPTIONS="root=UUID=$rootuuid loglevel=4 Page_Poison=1 psi=1"
  DISK="$device"
  PART=1
EOF

elif [[ $device = /dev/mmcblk0 ]]; then
  tee /mnt/etc/default/efibootmgr-kernel-hook <<-EOF
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
  echo "# /Volumes/data* /Volumes/storage fuse.mergerfs category.create=mfs,defaults,allow_other,minfreespace=20G,fsname=mergerfsPool	0 0" >> /mnt/etc/fstab
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
  tee /mnt/etc/iwd/main.conf <<-EOF
  [General]
  EnableNetworkConfiguration=true
EOF
fi

# Set static ip address for wifi
if [[ $ipstaticwlan0 ]]; then 
  tee /mnt/var/lib/iwd/${routerssid}.psk <<-EOF
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
# mv /mnt/etc/hosts /mnt/etc/hosts.orig
# Adding hostname to hosts is not needed
# echo "127.0.0.1 $HOSTNAME localhost" > /mnt/etc/hosts

echo "TIMEZONE=$TIMEZONE" >> /mnt/etc/rc.conf
echo "HARDWARECLOCK=$HARDWARECLOCK" >> /mnt/etc/rc.conf
echo "KEYMAP=$KEYMAP" >> /mnt/etc/rc.conf
echo "FONT=$FONT" >> /mnt/etc/rc.conf

# set "root" privileges
# test doas.conf
# $ doas -C /etc/doas.conf
# check permission of command
# $ doas -C /etc/doas.conf command
echo "$doasconf" > /mnt/etc/doas.conf

# Configure user accounts
echo ''
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
useradd --root /mnt --user-group --groups $groups --create-home $username
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
  echo "$bashprofile" >> /mnt/home/$username/.bash_profile
  echo "$xinitrc" > /mnt/home/$username/.xinitrc
  chown 1000:1000 /mnt/home/$username/.xinitrc
fi

# Herbstluftwm
# chroot --userspec=$username:users /mnt mkdir -p home/$username/.config/herbstluftwm
# chroot --userspec=$username:users /mnt cp etc/xdg/herbstluftwm/autostart home/$username/.config/herbstluftwm

# Create $HOME directories
for dir in $dirs; do
  chroot --userspec=$username:$username /mnt mkdir -p home/$username/$dir
done

# Create list of installed packages
xbps-query -r /mnt --list-pkgs > /mnt/home/$username/void-pkgs.log
 
echo '**********************************************************'
echo -e "[!] Check \x1B[1;92m BootOrder: \x1B[1;0m is correct [!]"
echo ' Boot entry needs to be towards the top of list otherwise '
echo '       it will not appear in the boot menu                '
echo '**********************************************************'
echo '**********************************************************'
echo '      Resetting BIOS will restore default boot order      '
echo '**********************************************************'
sleep 5
clear
efibootmgr
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
