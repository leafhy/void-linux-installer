#!/bin/bash
########################################################################
############################## WARNING #################################
########################################################################
## Do Not install Grub if theres another operating system installed   ##
## even if it's on a separate hard drive as it will overwrite the mbr ##
## necessitating a re-install at least with Windows 10                ##
########################################################################
########################################################################
# References
# https://voidlinux.org
# http://www.troubleshooters.com/linux/void/index.htm
# https://alkusin.net/voidlinux/
# https://github.com/olivier-mauras/void-luks-lvm-installer/blob/master/install.sh
# https://github.com/NAGA1337/void/blob/master/void.sh
# https://github.com/alejandroliu/0ink.net/blob/master/snippets/void-installation/install.sh
# https://www.kernel.org/doc/Documentation/filesystems/f2fs.txt
# https://www.kernel.org/doc/Documentation/filesystems/xfs.txt
# https://www.kernel.org/doc/Documentation/filesystems/nilfs2.txt
# https://www.kernel.org/doc/Documentation/filesystems/ext4.txt
# aggressive nilfs config http://ix.io/1wIS
# https://www.shellcheck.net
# https://wiki.archlinux.org/index.php/unbound
# https://nlnetlabs.nl/documentation/unbound/ # some inaccurate options - version differences?
#
# Notes:
# Tested on Lenovo Thinkpad T420 in EFI only mode with "Dogfish 128GB" mSATA
# void-live-x86_64-musl-20191109.iso burnt to CD
# efi(bootmgr) is a little flaky as it can fail to change bootorder or wipe it completely
# IMPORTANT : Windows switches to Nvidia Optimus mode if enabled
#           :  
# grub works
# Updating Live CD kernel will result in "[*]" as an option to install
# Not checked if label can be set in efibootmgr-kernel-hook
# Not tested bluetooth
# /home/$user/.asoundrc - increases volume
# efibootmgr default label "Void Linux With Kernel 5.7"
# ATAPI CD0 = HL-DT-STDVDRAM GT33N
# efifb: mode is 640x480x32
# Not Required : kernel .efi extension
#              : efivarfs  /sys/firmware/efi/efivars efivarfs  0 0 >> /mnt/etc/fstab
#
# /boot/efi - appears to be optional
# 
# Bug? Appears / (nilfs) is trying to be mounted twice - drops to emergency shell
# Need to 'exit' twice to continue booting and 'enter' to display login prompt
# fat 32 failed to unmount properly
# Bash script buffquote initially only showed the first quote in bash (RANDOM couldn't be found)
# due to /bin/sh -> dash (works in dash) - needed to remove sh
##########################################################################################
##########################################################################################
####                      Preparatory Instructions                                    ####
##########################################################################################
# 8GB usb or larger required for repository (void repository = ~1TB)                     #
# Install void-live-x86_64-musl-20191109.iso to usb drive - ie. with PassMark imgUSB     #
# usb will have /dev/sdc1 and /dev/sdc2                                                  #
# format unallocated space - mkfs.f2fs /dev/sdc3                                         #
# use sdc3 for repository, *this* script et. al                                          #
# boot usb                                                                               #
# login as root                                                                          #
# mount /dev/sdc3 /opt                                                                   #
# run *this* script                                                                      #
##########################################################################################
##########################################################################################
# exit on error 
set -e

# Make terminal clean
clear

# Change font to be more legible
setfont Lat2-Terminus16

echo '*********************************************'
echo '*********************************************'
echo '**** VOID LINUX MUSL x86_64 INSTALLATION ****'
echo '****            EFI Stub Boot            ****'
echo '*********************************************'
echo '*********************************************'

#############################################
#### [!] START OF USER CONFIGURATION [!] ####
#############################################
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
# Cron options >> fcron,dcron,bcron,scron,tinycron,cronie
# thinkfan - set fan temp thresholds
# mdocml=mandoc outputs man pages
# autox - caused login to loop switching monitor off & on (herbstluftwm)
# adom - installs ARM on x86_64 - has been removed from repo
# iwd - includes dhcp
# unbound - will not start if interface is wrong
# zathura - mupdf,poppler,djvu,epub (mupdf stand alone is faster)
# aucatctl - changes volume in sndiod
# bind-utils - dig (dns lookup), nslookup, host
# ---
# grafana - failed to start due to no permission to mkdir /var/log/grafana
# Create /var/log/grafana manually
# login admin/admin
# ---
# [!] IMPORTANT [!] alsa-utils >>> alsamixer is required to un-mute 
# alsamixer - changes volume in drivers - gui AlsaMixer.app  
# intel-ucode - dracut default is to include
# early_microcode=yes >> /etc/dracut.conf.d/intel_ucode.conf seems redundant
# intel-ucode failed to install (efibootmgr was installed, strangely no pkg in cache)
# verify efibootmgr and intel-ucode did install if not install manually
#################################################################
##################  Siren Music Player ##########################
#################################################################
# https://www.kariliq.nl/siren
# git clone https://www.kariliq.nl/git/siren.git
#
# wav,aiff = sndfile | mp3 = mad,mpg123 | ogg = ogg | wv = wavpack
# opus = opusfile aac = faad | mp4 = mp4v2 | flac = flac
# ffmpeg = flac,ogg,mp3,mp4
#
# libid3tag-devel wavpack-devel libmad-devel libmp4v2-devel flac-devel
# libsndfile-devel libogg-devel mpg123-devel faad2-devel sndio-devel
# pulseaudio-devel libpulseaudio-devel libao-devel portaudio-devel ffmpeg-devel
# opusfile-devel pkg-config
#
# .siren/config
# set active-fg colour-name # foreground
##################################################################
# Fonts
# https://github.com/be5invis/Iosevka/releases
# https://overpassfont.org
# https://mplus-fonts.osdn.jp/about-en.html
# http://www.fial.com/~scott/tamsyn-font/download/tamsyn-font-1.11.tar.gz
################################################################## 
  pkg_list='base-minimal'\
' aria2'\
' atool'\
' bash'\
' bwm-ng'\
' chromium'\
' chrony'\
' dosfstools'\
' dracut'\
' exfat-utils'\
' fcron'\
' fd'\
' ffmpeg'\
' filezilla'\
' firefox'\
' glances'\
' hddtemp'\
' herbstluftwm'\
' inetutils'\
' inxi'\
' iproute2'\
' iwd'\
' kbd'\
' kid3'\
' libinput-gestures'\
' linux-firmware'\
' linux-firmware-nvidia'\
' linux-firmware-intel'\
' lm_sensors'\
' lnav'\
' lr'\
' micro'\
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
' smplayer'\
' sndio'\
' socklog-void'\
' tlp'\
' tree'\
' vsv'\
' wget'\
' xf86-input-wacom'\
' xorg-minimal'\
' sakura'\
' man-pages'\
' mdocml'\
' mesa'\
' mesa-demos'\
' mesa-vulkan-intel'\
' mesa-vaapi'\
' xterm'\
' autorandr'\
' gcc'\
' w3m-img'\
' sxiv'\
' xwallpaper'\
' dtach'\
' make'\
' git'\
' mupdf'\
' aerc'\
' bind-utils'\
' unbound'\
' dnscrypt-proxy'\
' pkg-config'\
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
' curl'\
' gptfdisk'\
' aucatctl'\
' sox'\
' unzip'\
' polybar'\
' font-tamsyn'

  username="vade"
  groups="wheel,storage,audio,lp,cdrom,optical,scanner,xbuilder,socklog"
doasconf="$(cat <<'EOF'
permit persist :wheel
permit nopass :wheel as root cmd /sbin/poweroff
permit nopass :wheel as root cmd /sbin/reboot
EOF
)"
bashprofile="$(cat <<'EOF'
scripts/buffquote
export PS1="\[\e[35;0m\]\u@\h[\t] \W #>\n\[\e[0m\]"
export MANPATH="/usr/local/man:$MANPATH"
# Weather Check
alias w="curl wttr.in/~Adelaide"
alias poweroff='doas /sbin/poweroff'
EOF
)"
  # For dhcp leave ipstaticeth0 empty and install dhcpd ie ndhc
  ipstaticeth0="192.168.1.XX"
  # For dhcp leave ipstaticwlan0 empty, iwd includes dhcp
  ipstaticwlan0="192.168.1.XX"
  routername="XXXX"
  gateway="192.168.1.1"
  wifipassword=""
  # nameserver0 is for unbound & dnscrypt-proxy
  nameserver0="127.0.0.1"
  #nameserver1="1.0.0.1"
  #nameserver2="1.1.1.1"
  labelroot="VOID_LINUX"
  labelfat="EFI"
  # repopath is local and is optional  - actual repository is /var/cache/xbps 
  repopath="/opt/void-linux-xbps-repository"
  repo0="http://alpha.de.repo.voidlinux.org/current/musl"
  repo1="https://mirror.aarnet.edu.au/pub/voidlinux/current/musl"
  repo2="https://ftp.swin.edu.au/voidlinux/current/musl" 
  services="sshd acpid chronyd fcron iwd socklog-unix nanoklogd hddtemp popcorn tlp nfs-server sndiod dbus"
  HOSTNAME="voidlinux"
  KEYMAP="us"
  TIMEZONE="Australia/Adelaide"
  HARDWARECLOCK="UTC"
  FONT="Tamsyn8x16r"
  TTYS="2"
  # Download various scripts/whatever to /home/$username/scripts
  urlscripts=('http://plasmasturm.org/code/rename/rename' 'https://raw.githubusercontent.com/leafhy/buffquote/master/buffquote')
  # Run script manually or add to fcron - make executable - chmod +x
  urlup="https://github.com/leafhy/unbound-dns-resolver-blocklist-updater/blob/master/unbound-update-blocklist.sh"
  # Add font to /usr/share/kbd/consolefonts
  urlfont=""
###########################################
#### [!] END OF USER CONFIGURATION [!] ####
###########################################

# Detect if we're in UEFI or legacy mode
[ -d /sys/firmware/efi ] && UEFI=1
if [ $UEFI ]; then
  pkg_list="$pkg_list efibootmgr"
fi

# Detect if we're on an Intel system
cpu_vendor=$(grep vendor_id /proc/cpuinfo | awk '{print $3}')
if [ "$cpu_vendor" = "GenuineIntel" ]; then
  pkg_list="$pkg_list intel-ucode"
fi
 
# Option to select the device type/name
# /dev/mmcblk0 is SDCARD on Lenovo Thinkpad T420 & T520
echo ''
echo '************************************************'
echo -e '******************* \x1B[1;31m WARNING \x1B[0m ******************'
echo '************************************************'
echo '**** Script is preconfigured for UEFI & GPT ****'
echo '****                                        ****'
echo '**** Partition Layout : Fat-32 EFI of 100MB ****'
echo '****                  : / 100%              ****'
echo '************************************************'
echo ''
echo '******************************************'
echo '[!] Rerun script if xbps-install fails [!]'
echo '******************************************'
echo ''
lsblk -f -l | grep -e sd -e mmcblk
echo ''
echo '****************************************'
echo '[!] Verify Connected Drive Is Listed [!]'
echo '****************************************'
# Generate drive options dynamically
PS3="Select drive to format: "
echo ''
# use sed to remove 'p' and the single partition number: 
# mmcblk0p1 >>> mmcblk01 >>> mmcblk0
# sda1 >>> sda
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
#      'sdc')
#      devname='/dev/sdc'
#      break
#      ;;
#    *)
#      echo 'This option is invalid.'
#      ;;
#  esac
# done
# clear

############################
#### FORMAT & PARTITION ####
############################
# Install Prerequisite/s
xbps-install -S
# possible bug? pkg does not install - however it does update base files
xbps-install -Sy gptfdisk 
xbps-install -Sy gptfdisk 

# xbps-install -y -S -f parted

# Erase partition table
# wipefs -a /dev/$devname
# dd if=/dev/zero of=/dev/$devname bs=1M count=100

# Create partitions
# if [ $UEFI ]; then
  # parted /dev/${DEVNAME} mklabel gpt
  # parted -a optimal /dev/${devname} mkpart primary 2048s 100M
  # parted -a optimal /dev/${devname} mkpart primary 100M 100%
  
# else
  # parted /dev/${devname} mklabel msdos
  # parted -a optimal /dev/${devname} mkpart primary 2048s 512M
  # parted -a optimal /dev/${devname} mkpart primary 512M 100%
# fi
# parted /dev/${devname} set 1 boot on

# CREATE PARTITIONS
# sgdisk creates GPT by default
echo
sgdisk --zap-all $device
sgdisk -n 1:2048:100M -t 1:ef00 $device
sgdisk -n 2:0:0 -t 2:8300 $device
sgdisk --verify $device
echo

# Option to select the file system type to format partitions
echo ''
echo '************************************'
echo '**** FILE SYSTEM TYPE SELECTION ****'
echo '************************************'
echo ''
echo -e '******************* \x1B[1;31m WARNING \x1B[0m ******************'
echo 'Nilfs2 on '/' will error on every boot'
echo 'Need to 'exit' twice to continue'
echo '**************************************'
echo ''
echo '[!] Retry if valid selection fails [!]'
echo ''
PS3='Select file system to format partition: '
filesystems=('btrfs' 'ext4' 'xfs' 'f2fs' 'nilfs2')
select filesysformat in "${filesystems[@]}"
do
  case $filesysformat in
    'btrfs')
      fsys1='btrfs'
      pkg_list="$pkg_list btrfs-progs"
      break
      ;;
    'xfs')
      fsys1='xfs'
      pkg_list="$pkg_list xfsprogs"
      break
      ;;
    'nilfs2')
      fsys1='nilfs2'
      xbps-install -y nilfs-utils
      pkg_list="$pkg_list nilfs-utils"
      break
      ;;
    'ext4')
      fsys2='ext4'
      pkg_list="$pkg_list e2fsprogs"
      break
      ;;
      'f2fs')
      fsys3='f2fs'
      pkg_list="$pkg_list f2fs-tools"
      break
      ;;
    *)
      echo 'This option is invalid.'
      
  esac
done
clear

# Format filesystems
# fat-32
if [ $UEFI ] && [[ $device = /dev/mmcblk0 ]]; then
     mkfs.vfat -F 32 -n EFI ${device}p1
   
   elif [[ $device != /dev/mmcblk0 ]]; then
     mkfs.vfat -F 32 -n $labelfat ${device}1
fi

# ${fsys1} -f -L
# btrfs
# xfs
# nilfs2
if [[ "$fsys1" ]] && [[ $device = /dev/mmcblk0 ]]; then
     mkfs.$fsys1 -f -L $labelroot ${device}p2
   
   elif [[ "$fsys1" ]] && [[ $device != /dev/mmcblk0 ]]; then
     mkfs.$fsys1 -f -L $labelroot ${device}2
fi 

# ${fsys2} -F -L
# ext4 
if [[ "$fsys2" ]] && [[ $device = /dev/mmcblk0 ]]; then
     mkfs.$fsys2 -F -L $labelroot ${device}p2
   
   elif [[ "$fsys2" ]] && [[ $device != /dev/mmcblk0 ]]; then
     mkfs.$fsys2 -F -L $labelroot ${device}2
fi

# ${fsys3} -f -l
# f2fs  
if [[ "$fsys3" ]] && [[ $device = /dev/mmcblk0 ]]; then
     mkfs.$fsys3 -f -l $labelroot ${device}p2
   
   elif [[ "$fsys3" ]] && [[ $device != /dev/mmcblk0 ]]; then
     mkfs.$fsys3 -f -l $labelroot ${device}2
fi

# Mount them
if [[ $device = /dev/mmcblk0 ]]; then
     mount ${device}p2 /mnt
   elif [[ $device != /dev/mmcblk0 ]]; then 
   mount ${device}2 /mnt
fi

for dir in dev proc sys boot; do
  mkdir /mnt/${dir}
done

if [ $UEFI ]; then
     mkdir -p /mnt/boot/efi
     else
     echo -e "\x1B[1;31m [!] UEFI Not found [!] \x1B[0m"  
fi

if [[ $device = /dev/mmcblk0 ]]; then
     mount ${device}p1 /mnt/boot/efi
  
  elif [[ $device != /dev/mmcblk0 ]]; then
     mount ${device}1 /mnt/boot/efi
fi

# Create Chroot Gaol
for fs in dev proc sys; do
  mount -o bind /$fs /mnt/$fs
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

echo ''
echo '**********************************'
echo '**** CHECKING KERNEL VERSIONS ****'
echo '**********************************'
echo ''
# Get currently running kernel version
echo 'Live CD kernel version'
xbps-query linux | awk '$1 == "pkgver:" { print $2 }' | sed -e 's/linux-//' -e 's/_.*$//'
echo ''
echo '**************************'
echo 'Choose a kernel to install'
echo '**************************'
echo '' 
PS3="Select kernel: " 
select kernel in $(xbps-query --regex -Rs '^linux[0-9.]+-[0-9._]+' | sed -e 's/\[-\] //' -e 's/_.*$//' | cut -d - -f 1)
do
if [[ $kernel = "" ]]; then
echo "$REPLY is not valid"
continue
fi
break
done

# Install latest kernel
if [ $kernel ]; then
pkg_list="$pkg_list $kernel"
fi

# Import keys from live image to prevent prompt for key confirmation
mkdir -p /mnt/var/db/xbps/keys/
cp -a /var/db/xbps/keys/* /mnt/var/db/xbps/keys/

if [[ $repopath != "" ]]; then
xbps-install --download-only $pkg_list -c $repopath
cd $repopath
# unsure if xbps-rindex is actually needed (did resolve package not found)
xbps-rindex -a *xbps
xbps-install -R $repopath -r /mnt void-repo-nonfree -y
xbps-install -R $repopath -r /mnt $pkg_list -y
else 
# xbps-install -y -S -R https://mirror.aarnet.edu.au/pub/voidlinux/current/musl -r /mnt $pkg_list
# Run second/third command if first one fails
 xbps-install -y -S -R $repo1 -r /mnt void-repo-nonfree || xbps-install -y -S -R $repo2 -r /mnt void-repo-nonfree || xbps-install -y -S -R $repo0 -r /mnt void-repo-nonfree
 xbps-install -S -R $repo1 -r /mnt || xbps-install -S -R $repo2 -r /mnt || xbps-install -S -R $repo0 -r /mnt
 xbps-install -y -S -R $repo1 -r /mnt $pkg_list || xbps-install -y -S -R $repo2 -r /mnt $pkg_list || xbps-install -y -S -R $repo0 -r /mnt $pkg_list
 # Make sure everything was installed
 xbps-install -y -S -R $repo1 -r /mnt $pkg_list || xbps-install -y -S -R $repo2 -r /mnt $pkg_list || xbps-install -y -S -R $repo0 -r /mnt $pkg_list
fi

echo
  
# Configure efibootmgr
# efibootmgr -c -d /dev/sda -p 1 -l '\vmlinuz-5.7.7_1' -L 'Void' initrd=\initramfs-5.7.7_1.img root=/dev/sda2
cp /etc/default/efibootmgr-kernel-hook /mnt/etc/default/efibootmgr-kernel-hook.bak

if [[ $device != /dev/mmcblk0 ]]; then
tee /mnt/etc/default/efibootmgr-kernel-hook <<EOF
MODIFY_EFI_ENTRIES=1
OPTIONS=root="${device}2 loglevel=4 Page_Poison=1"
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

# Get / UUID
rootuuid=$(blkid -s UUID -o value ${device}2 | cut -d = -f 3 | cut -d " " -f 1 | grep - | tr -d '"')

# Add fstab entries
if [[ $UEFI ]] && [[ $device = /dev/mmcblk0 ]]; then
     echo "${device}p1   /boot/efi   vfat    defaults     0 0" >> /mnt/etc/fstab
   elif [[ UEFI ]] && [[ $device != /dev/mmcblk0 ]]; then
     echo "LABEL=$labelfat   /boot/efi   vfat    defaults     0 0" >> /mnt/etc/fstab
fi
# echo "LABEL=root  /       ext4    rw,relatime,data=ordered,discard    0 0" > /mnt/etc/fstab
# echo "LABEL=boot  /boot   ext4    rw,relatime,data=ordered,discard    0 0" >> /mnt/etc/fstab

if [[ $fsys3 ]]; then
# disable fsck.f2fs otherwise boot fails
echo "UUID=$rootuuid   /       $fsys3   defaults           0 0" >> /mnt/etc/fstab 
else
echo "UUID=$rootuuid   /       $fsys1 $fsys2   defaults    0 1" >> /mnt/etc/fstab 
fi
# echo "tmpfs           /tmp    tmpfs   size=1G,noexec,nodev,nosuid     0 0" >> /mnt/etc/fstab

# Reconfigure kernel and create initramfs (dracut) and efi boot entry (efibootmgr)
xbps-reconfigure -fa -r /mnt ${kernel}
cp /mnt/boot/initramfs* /mnt/boot/efi
cp /mnt/boot/vmlinuz* /mnt/boot/efi
# Add repositories
cp -a /usr/share/xbps.d/* /mnt/etc/xbps.d
echo "repository=$repo1" > /mnt/etc/xbps.d/00-repository-main.conf
echo "repository=$repo2" >> /mnt/etc/xbps.d/00-repository-main.conf
echo "repository=$repo0" >> /mnt/etc/xbps.d/00-repository-main.conf

# Networking
cp /etc/resolv.conf /mnt/etc
if [[ $nameserver0 ]]; then
echo "nameserver $nameserver0" >> /mnt/etc/resolv.conf
# Options for dnscrypt-proxy
echo "options edns0" >> /mnt/etc/resolv.conf
fi
# Google
# echo "nameserver 8.8.8.8" >> /etc/resolv.conf
# echo "nameserver 8.8.4.4" >> /etc/resolv.conf
# Cloudflare
if [[ $nameserver1 ]]; then
echo "nameserver $nameserver1" >> /mnt/etc/resolv.conf
fi
if [[ $nameserver2 ]]; then
echo "nameserver $nameserver2" >> /mnt/etc/resolv.conf
fi

# Static IP configuration via iproute2
cp /etc/rc.local /mnt/etc
eth=$(ip link | grep enp | cut -d : -f 2)
echo "ip link set dev $eth up" >> /mnt/etc/rc.local
echo "ip addr add $ipstaticeth0/24 brd + dev $eth" >> /mnt/etc/rc.local
echo "ip route add default via $gateway" >> /mnt/etc/rc.local

# Use static Wifi (dynamic is default)
if [ "$ipstaticwlan0" ]; then
tee /mnt/etc/iwd/main.conf <<EOF
[General]
EnableNetworkConfiguration=true
EOF
fi

# Set static ip address for wifi
if [ "$ipstaticwlan0" ]; then 
tee /mnt/var/lib/iwd/${routername}.psk <<EOF
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
echo $HOSTNAME > /mnt/etc/hostname

echo "TIMEZONE=$TIMEZONE" >> /mnt/etc/rc.conf
echo "HARDWARECLOCK=$HARDWARECLOCK" >> /mnt/etc/rc.conf
echo "KEYMAP=$KEYMAP" >> /mnt/etc/rc.conf
echo "FONT=$FONT" >> /mnt/etc/rc.conf
echo "TTYS=$TTYS" >> /mnt/etc/rc.conf

# set "DOAS(root)" privileges
# test doas.conf
# $ doas -C /etc/doas.conf
# check permission of command
# $ doas -C /etc/doas.conf command
# echo "permit persist :wheel" > /mnt/etc/doas.conf
echo "$doasconf" > /mnt/etc/doas.conf
# persist password
# echo "permit persist :wheel" > /mnt/etc/doas.conf
# no password
# echo "permit nopass :wheel" > /mnt/etc/doas.conf

# Configure user accounts
echo ''
# Add ansi colour codes
echo -e "[!] Setting \x1B[1;31m root \x1B[0m password [!]"
echo ''

while true; do
  passwd -R /mnt root && break
  echo 'Password did not match. Please try again'
  sleep 3s
  echo ''
done

chroot /mnt useradd -g users -G $groups $username
# [Bug?] useradd -R /mnt 
# error: configuration error unknown item 'HOME_MODE' (notify administrator)
# home directory is still created
#
# groups: cdrom=CD
#         optical=DVD/CD-RW # optical is not used by other distros
#         storage=removeable
echo ''
echo -e "[!] Create password for user \x1B[01;96m $username \x1B[0m [!]"
echo ''

while true; do
  passwd -R /mnt $username && break
  echo 'Password did not match. Please try again'
  sleep 3s
  echo ''
done

# Setup bash_profile
echo "$bashprofile" >> /mnt/home/$username/.bash_profile

# Check $pkg_list installed
xbps-query -r /mnt --list-pkgs > /mnt/home/$username/void-pkgs.log
echo '********************************************'
echo -e "**** \x1B[1;32m See /home/$username/void-pkgs.log \x1B[0m ****"
echo -e "**** \x1B[1;32m for a list of installed packages \x1B[0m  ****"
echo '********************************************'
echo ''

# Activate services
for srv in $services; do
chroot /mnt ln -s /etc/sv/$srv /etc/runit/runsvdir/default/
done

# Install Extras
if [ $urlscripts ] || [ $urlfont ]; then
     xbps-install -S -y aria2
fi
  
if [ $urlscripts ]; then
     echo '**** Installing Scripts ****'
     for file in "${urlscripts[@]}"; do
     aria2c "$file" -d /mnt/home/$username/scripts
     chroot /mnt  chown $username:users home/$username/scripts/*
     done
     echo "**** Scripts have been installed to /home/$username/scripts ****"
     echo "**** Correct permissions if needed ****"
     echo "**** chown $username:users /home/$username/scripts/* ****"
fi

if [ urlup ]; then
echo '**** Downloading unbound updater ****'
mkdir /mnt/etc/unbound/unbound-updater
aria2c $urlup -d /mnt/etc/unbound/unbound-updater
fi

echo

if [ $urlfont ]; then
     echo '**** Installing Font ****'
     aria2c "$urlfont" -d /mnt/usr/local/src
     cd /mnt/usr/local/src && tar zxf $(echo $urlfont | cut -d d -f 3 | tr -d /)
     cp $(echo $urlfont | cut -d d -f 3 | tr -d / | sed 's/.tar.gz$//')/*gz /mnt/usr/share/kbd/consolefonts
     echo "**** $FONT has been installed to /usr/share/kbd/consolefonts ****"  
fi 

# Audio Configuration
tee /mnt/home/$username/.asoundrc <<EOF
pcm.sndio {
type asym
playback.pcm "sndio-play"

hint {
	    show on description "OpenBSD sndio"
	    }
	    }
	    
	    pcm.sndio-play {
	    type plug
	    slave {
	    pcm "sndio-raw"
	    rate 48000
	    format s16_le
	    channels 2
}
}
	    
 pcm.sndio-raw {
 type file
 slave.pcm null
	    
 format raw
 file "| aucat -f snd/0 -i -"
}
pcm.default sndio
EOF

sleep 3s

# Herbstluftwm
chroot -u $username -g users /mnt mkdir -p home/$username/.config/herbstluftwm
chroot -u $username -g users /mnt cp etc/xdg/herbstluftwm/autostart home/$username/.config/herbstluftwm
echo "exec herbstluftwm" >> /mnt/home/$username/.xinitrc

# Unbound Configuration
tee /mnt/etc/unbound/unbound.conf <<EOF
server:
    use-syslog: yes
    interface: 127.0.0.1
    
    # Need chroot to prevent fatal error: trust-anchor-file: does not exist
    chroot: ""
#interface: ::0
  #   access-control: 127.0.0.0/8 allow
#     access-control: 192.168.0.0/24 allow
 #  access-control: 192.168.1.0/24 allow
#interface: ::1
 #   access-control: ::1 allow
       include: /etc/unbound/unbound-blocked.conf
# Ports other then default (53) don't appear to work 
# port 53

# wget https://www.internic.net/domain/named.cache -o /etc/unbound/root.hints
    root-hints: root.hints
# auto-trust-anchor-file: unbound restarts on using dig/ping
    trust-anchor-file: /etc/dns/root.key
#local-zone: "192.in-addr.arpa." transparent
    do-not-query-localhost: no
# Removal of forward zone uses ISP
forward-zone:
        name: "."
        forward-addr: 127.0.0.1@5335
#        forward-addr: 8.8.8.8
#        forward-addr: 1.1.1.1
# enable remote-control
remote-control:
    control-enable: yes
control-interface: 0.0.0.0
# Test unbound
# $ unbound-host -C /etc/unbound/unbound.conf -v sigok.verteiltesysteme.net
#  (secure)
#  $ unbound-host -C /etc/unbound/unbound.conf -v sigfail.verteiltesysteme.net
#  (servfail)
EOF

clear
 
echo '**********************************************************'
echo -e "**** [!] Check \x1B[1;92m BootOrder: \x1B[1;0m is correct [!] ****"
echo '**********************************************************'
echo '**** Resetting BIOS will restore default boot order   ****'
echo '**********************************************************'
echo '**********************************************************'
efibootmgr -v
echo ''
echo '**********************************************************' 
echo '**********************************************************'
echo -e "************* \x1B[1;32m VOID LINUX INSTALL IS COMPLETE \x1B[0m *************'
echo '**********************************************************'
echo '**********************************************************'
echo ''
echo "(U)mount $device and exit"
echo ''
echo '(E)xit'
echo '' 
echo '(R)eboot'
echo ''
echo '(S)hutdown'
echo ''
read -n 1 -p "[ U | E | R | S ]: " ans
# Chroot may fail to unmount hence -l
case $ans in
    r|R)
        umount -l -R /mnt && reboot;;
    s|S)
        umount -l -R /mnt && poweroff;;
    e|E)
        exit;;
    u|U)
       umount -l -R /mnt && exit  
esac

######################################################################
# POST INSTALL SETUP
######################################################################
# Network - WIFI
# iwctl --passphrase="password-goes-here" station wlan0 connect "routername"
# password file >> /var/lib/iwd/routername
#
# Xwallpaper
# Add to >> ~/.config/herbstluftwm/autostart
# xwallpaper --output LVDS1 --stretch "Snow Leopard Prowl.jpg" --output VGA1 --stretch "Snow Leopard Prowl.jpg"
#
# Turn off screen
# xrandr --output LVDS-1 --off
# Turn on screen
# xrandr --output LVDS-1 --auto
# Blank screen 1m turn off 2m
# setterm --blank 1 --powerdown 2
# Save/Load monitor profile
# autorandr --save 'profile'
# Automatically reload
# autorandr --change
# autorandr 'profile'
#
# List fonts /usr/share/fonts
# fc-list 
#
# DNSCrypt-Proxy
# /etc/dnscrypt-proxy.toml >> 127.0.0.1:5353
#
# Unbound
# $ unbound-host -C /etc/unbound/unbound.conf -v sigok.verteiltesysteme.net
#  (secure)
# $ unbound-host -C /etc/unbound/unbound.conf -v sigfail.verteiltesysteme.net
# (servfail)
