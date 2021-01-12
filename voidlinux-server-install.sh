#!/bin/bash
#########################################################
############## VOID LINUX SERVER INSTALL ################
#########################################################
# This script is a cutdown version of void-linux-installer.sh
#
#########################################################
#################### WARNING ############################
#########################################################
# Note: If drive order changes ie USB
# efibootmgr --disk defaults to /dev/sda
# efibootmgr-kernel-hook
# Replace OPTIONS=root="/dev/sda"
# with 
# OPTIONS=root="UUID=$rootuuid" 
#########################################################
#########################################################
#########################################################
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
echo 'Creating ramfs for repo....'
mount -t ramfs ramfs /opt
cp /media/voidrepo/voidlinux-setup/voidlinux-xbps-repo/* /opt

# Change font to be more legible
setfont Lat2-Terminus16

  pkg_list='base-minimal'\
' aria2'\
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
' micro'\
' mle'\
' nano'\
' ncurses'\
' rsync'\
' nfs-utils'\
' opendoas'\
' openssh'\
' p7zip'\
' pciutils'\
' PopCorn'\
' smartmontools'\
' socklog-void'\
' tree'\
' vsv'\
' wget'\
' man-pages'\
' mdocml'\
' xterm'\
' dtach'\
' xfsprogs'\
' e2fsprogs'\
' curl'\
' gptfdisk'\
' unzip'\
' ranger'\
' font-tamsyn'\
' starship'\
' xz'\
' lshw'\
' snapraid'\
' mergerfs'

  username="voidser"
  groups="wheel,storage,lp,cdrom,optical,scanner,socklog"

doasconf="$(cat <<'EOF'
permit persist :wheel
permit nopass :wheel as root cmd /sbin/poweroff
permit nopass :wheel as root cmd /sbin/reboot
EOF
)"

# .bashrc
bashrc="$(cat <<'EOF'
# scripts/buffquote
eval "$(starship init bash)"
# export PS1="\n\[\e[0;32m\]\u@\h[\t]\[\e[0;31m\] \['\$PWD'\] \[\e[0;32m\]\[\e[0m\]\[\e[0;32m\]>>>\[\e[0m\]\n "
export PATH=".local/bin:$PATH"
export MANPATH="/usr/local/man:$MANPATH"
# Weather Check
alias weather='curl wttr.in/?0'
alias w="curl wttr.in/~Adelaide"
alias poweroff='doas /sbin/poweroff'
alias reboot='doas /sbin/reboot'
alias bmount='doas /sbin/mount /mnt/backup'
alias bumount='doas /sbin/umount /mnt/backup'
EOF
)"

# For dhcp leave ipstaticeth0 empty and install dhcpd ie ndhc
  ipstaticeth0="192.168.1.52"
  # For dhcp leave ipstaticwlan0 empty, iwd includes dhcp
  ipstaticwlan0=""
  routerssid=""
  gateway="192.168.1.1"
  # Ethernet - eno1 (intel server) - enp0s25 (lenovo thinkpad)
  eth="eno1"
  wifipassword=""
  # nameserver0 is for unbound & dnscrypt-proxy
  # nameserver0="127.0.0.1"
  nameserver1="1.0.0.1"
  nameserver2="1.1.1.1"
  labelroot="VOID_LINUX"
  labelfat="EFI"
  
  ### Use this if packages have already been downloaded ###
  # xbps-install --download-only $repopath $pkg_list && cd $repopath && xbps-rindex *xbps
  # xbps-install --repository $repopath 
  repopath="/opt"
  
  ### Use this to save packages to somewhere other then live disk ###
  # xbps-install -R $repo0..2 --download-only --cachedir $cachedir $pkg_list && cd $repopath && xbps-rindex *xbps
  # xbps-install --repository $cachedir
  cachedir=""
  
  ### Leave $repopath & $cachedir empty to use default repository /var/cache/xbps
  # xbps-install --repository $repo0
  repo0="http://alpha.de.repo.voidlinux.org/current/musl"
  repo1="https://mirror.aarnet.edu.au/pub/voidlinux/current/musl"
  repo2="https://ftp.swin.edu.au/voidlinux/current/musl" 
  
  services="sshd acpid chronyd fcron socklog-unix nanoklogd hddtemp popcorn nfs-server statd rpcbind"
  HOSTNAME="voidserver"
  KEYMAP="us"
  TIMEZONE="Australia/Adelaide"
  HARDWARECLOCK="UTC"
  FONT="Tamsyn8x16r"
  TTYS="2"
  # Create $HOME directories
  dirs="exclusions scripts" 
# Download various scripts/whatever to /home/$username/scripts
# urlscripts=('http://plasmasturm.org/code/rename/rename' 'https://raw.githubusercontent.com/leafhy/buffquote/master/buffquote')
# Run unbound-update-blocklist.sh manually or add to fcron - make executable - chmod +x
# urlup="https://raw.githubusercontent.com/leafhy/void-linux-installer/master/etc/unbound/unbound-updater/unbound-update-blocklist.sh"
# Add font(.tar.gz) to /usr/share/kbd/consolefonts
  urlfont=""
# Install to ~/.local/bin
# bin=('https://' 'https://')
###########################################
###########################################
#### [!] END OF USER CONFIGURATION [!] ####
###########################################
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
 
# /dev/mmcblk0 is SDCARD on Lenovo Thinkpad T420 & T520
echo ''
echo '************************************************'
echo -e '*******************\x1B[1;31m WARNING \x1B[0m******************'
echo '************************************************'
echo '**** Script is preconfigured for UEFI & GPT ****'
echo '****                                        ****'
echo '**** Partition Layout : Fat-32 EFI of 100MB ****'
echo '****                  : / 100%              ****'
echo '****                                        ****'
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
# Install Prerequisites
if [[ $repopath != "" ]]; then
xbps-install -S -R $repopath
xbps-install -Su -R $repopath -y
xbps-install -R $repopath -y gptfdisk
fi

if [[ $cachedir != "" ]]; then
xbps-install -R $repo0 --download-only --cachedir $cachedir || xbps-install -R $repo1 --download-only --cachedir $cachedir || xbps-install -R $repo2 --download-only --cachedir $cachedir
cd $cachedir
xbps-rindex *xbps
xbps-install -R $cachedir -y gptfdisk
fi

if [[ $cachedir = "" ]] && [[ $repopath = "" ]]; then
xbps-install -S -R $repo1 || xbps-install -S -R $repo2 || xbps-install -S -R $repo0
xbps-install -R $repo1 gptfdisk || xbps-install -S -R $repo2 gptfdisk || xbps-install -S -R $repo0 gptfdisk
fi

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
echo -e '*******************\x1B[1;31m WARNING \x1B[0m******************'
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
      xbps-install -R $repopath -y btrfs-progs
      break
      ;;
    'xfs')
      fsys1='xfs'
      pkg_list="$pkg_list xfsprogs"
      xbps-install -R $repopath -y xfsprogs
      break
      ;;
    'nilfs2')
      fsys1='nilfs2'
      pkg_list="$pkg_list nilfs-utils"
      xbps-install -R $repopath -y nilfs-utils
      break
      ;;
    'ext4')
      fsys2='ext4'
      pkg_list="$pkg_list e2fsprogs"
      xbps-install -R $repopath -y e2fsprogs
      break
      ;;
    'f2fs')
      fsys3='f2fs'
      pkg_list="$pkg_list f2fs-tools"
      xbps-install -R $repopath -y f2fs-tools
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

if [[ $fsys3 ]] ; then
echo "Encrypt = encrypt,extra_attr,sb_checksum,inode_checksum,lost_found"
echo "No Encryption = extra_attr,sb_checksum,inode_checksum,lost_found"
echo "No Checksums = lost_found"
echo "None = No Options"
echo "*encrypt does not work with 'casefold/utf8'"
echo "f2fs-tools v1.14 casefold doesn't work without utf8 -> keyboard momentarily stopped working - compression unknown option"

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
select kernel in $(xbps-query --repository=$repopath --regex -Rs '^linux[0-9.]+-[0-9._]+' | sed -e 's/\[-\] //' -e 's/_.*$//' | cut -d - -f 1)
do
if [[ $kernel = "" ]]; then
echo "$REPLY is not valid"
continue
fi
break
done

pkg_list="$pkg_list $kernel"

# Import keys from live image to prevent prompt for key confirmation
mkdir -p /mnt/var/db/xbps/keys/
cp -a /var/db/xbps/keys/* /mnt/var/db/xbps/keys/

# Package Installation
if [[ $repopath != "" ]]; then
xbps-install -R $repopath -r /mnt void-repo-nonfree -y
xbps-install -R $repopath -r /mnt $pkg_list -y
# make sure intel-ucode is installed
xbps-install -R $repopath -r /mnt intel-ucode -y
fi

if [[ $cachedir != "" ]]; then
xbps-install -R $cachedir -r /mnt void-repo-nonfree -y
xbps-install -R $cachedir-r /mnt $pkg_list -y
# make sure intel-ucode is installed
xbps-install -R $cachedir -r /mnt intel-ucode -y
fi

if [ $cachedir = "" ] && [ $repopath = "" ]; then
# Run second/third command if first one fails
 xbps-install -y -S -R $repo1 -r /mnt void-repo-nonfree || xbps-install -y -S -R $repo2 -r /mnt void-repo-nonfree || xbps-install -y -S -R $repo0 -r /mnt void-repo-nonfree
 xbps-install -y -S -R $repo1 -r /mnt $pkg_list || xbps-install -y -S -R $repo2 -r /mnt $pkg_list || xbps-install -y -S -R $repo0 -r /mnt $pkg_list
 # Make sure everything was installed
 xbps-install -y -S -R $repo1 -r /mnt $pkg_list || xbps-install -y -S -R $repo2 -r /mnt $pkg_list || xbps-install -y -S -R $repo0 -r /mnt $pkg_list
fi

echo
  
# Get / UUID
rootuuid=$(blkid -s UUID -o value ${device}2 | cut -d = -f 3 | cut -d " " -f 1 | grep - | tr -d '"')

# Configure efibootmgr
# efibootmgr -c -d /dev/sda -p 1 -l '\vmlinuz-5.7.7_1' -L 'Void' initrd=\initramfs-5.7.7_1.img root=/dev/sda2
cp /etc/default/efibootmgr-kernel-hook /mnt/etc/default/efibootmgr-kernel-hook.bak

if [[ $device != /dev/mmcblk0 ]]; then
tee /mnt/etc/default/efibootmgr-kernel-hook <<EOF
MODIFY_EFI_ENTRIES=1
OPTIONS=root="UUID=$rootuuid loglevel=4 Page_Poison=1"
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
if [[ $UEFI ]] && [[ $device = /dev/mmcblk0 ]]; then
     echo "${device}p1   /boot/efi   vfat    defaults     0 0" >> /mnt/etc/fstab
   elif [[ UEFI ]] && [[ $device != /dev/mmcblk0 ]]; then
     echo "LABEL=$labelfat   /boot/efi   vfat    defaults     0 0" >> /mnt/etc/fstab
fi
# echo "LABEL=root  /       ext4    rw,relatime,data=ordered,discard    0 0" > /mnt/etc/fstab
# echo "LABEL=boot  /boot   ext4    rw,relatime,data=ordered,discard    0 0" >> /mnt/etc/fstab

if [[ $fsys3 ]]; then
# disable fsck.f2fs otherwise boot fails
echo "UUID=$rootuuid   /       f2fs   defaults           0 0" >> /mnt/etc/fstab 
else
echo "UUID=$rootuuid   /       $fsys1 $fsys2   defaults    0 1" >> /mnt/etc/fstab 
fi
# echo "tmpfs           /tmp    tmpfs   size=1G,noexec,nodev,nosuid     0 0" >> /mnt/etc/fstab

# Add borg backup to /etc/fstab
echo "/mnt/void-backup/borg /mnt/backup fuse.borgfs defaults,noauto,user,uid=1000,allow_other 0 0" >> /mnt/etc/fstab

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
#eth=$(ip link | grep enp | cut -d : -f 2)
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
echo $HOSTNAME > /mnt/etc/hostname

# hosts
# mv /mnt/etc/hosts /mnt/etc/hosts.bak
# echo "127.0.0.1 $HOSTNAME localhost" > /mnt/etc/hosts

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
echo "$doasconf" > /mnt/etc/doas.conf

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

chroot /mnt useradd -G $groups $username
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

# Check $pkg_list installed
xbps-query -r /mnt --list-pkgs > /mnt/home/$username/void-pkgs.log

echo '********************************************'
echo -e "****\x1B[1;32m See /home/$username/void-pkgs.log \x1B[0m****"
echo -e "****\x1B[1;32m for a list of installed packages \x1B[0m****"
echo '********************************************'
echo ''

# Activate services
for srv in $services; do
chroot /mnt ln -s /etc/sv/$srv /etc/runit/runsvdir/default/
done

# Install Extras
if [ $urlscripts ] || [ $urlfont ] || [ $bin ] && [ $repopath != "" ] || [ $cachedir != "" ] ; then
     xbps-install -R $repopath $cachedir -y aria2
fi
  
if [ $urlscripts ]; then
     echo '**** Installing Scripts ****'
     for file in "${urlscripts[@]}"; do
     chroot  --userspec=$username:users /mnt aria2c "$file" -d home/$username/scripts
     done
     echo "**** Scripts have been installed to /home/$username/scripts ****"
     sleep 3s
fi

if [ $urlup ]; then
echo '**** Downloading unbound updater ****'
aria2c $urlup -d /mnt/etc/unbound/unbound-updater
fi

echo

if [ $urlfont ]; then
     echo '**** Installing Font ****'
     aria2c "$urlfont" -d /mnt/usr/local/src
     cd /mnt/usr/local/src && tar zxf $(echo $urlfont | cut -d d -f 3 | tr -d /)
     cp $(echo $urlfont | cut -d d -f 3 | tr -d / | sed 's/.tar.gz$//')/*gz /mnt/usr/share/kbd/consolefonts
     echo "**** $FONT has been installed to /usr/share/kbd/consolefonts ****"
     sleep 3s
fi 

if [ $bin ]; then
     echo '**** Installing Bin ****'
     for file in "${bin[@]}"; do
     chroot  --userspec=$username:users /mnt aria2c "$bin" -d home/$username/.local/bin
     done
fi

# Setup $HOME
echo "$bashrc" > /mnt/home/$username/.bashrc
# echo "$bashprofile" > /mnt/home/$username/.bash_profile
# echo "$xinitrc" > /mnt/home/$username/.xinitrc

# Create $HOME directories
for dire in $dirs; do
chroot --userspec=$username:users /mnt mkdir -p home/$username/$dire
done

# Borg Backup
# exclusions directory will NOT be backed up by borg

# create mount point for borg repo
chroot /mnt mkdir mnt/borg-backup
# create mount point to access borg repo
chroot /mnt mkdir mnt/backup

chroot --userspec=$username:users /mnt tee home/$username/scripts/borg-backup.sh <<EOF
#!/bin/sh
# https://superuser.com/questions/1361971/how-do-i-automate-borg-backup

DATE=$(date)
echo "Starting backup for $DATE\n"

# setup script variables
# export BORG_PASSPHRASE="secret-passphrase-here!"
export BORG_UNKNOWN_UNENCRYPTED_REPO_ACCESS_IS_OK=yes
export BORG_REPO="/mnt/void-backup/borg"
export BACKUP_TARGETS="/"
# export BACKUP_NAME="$HOSTNAME"
BORG_OPTS="--stats --one-file-system"

# create borg backup archive
borg create -e "/dev" -e "/tmp" -e "/proc" -e "/sys" -e "/run" -e "/home/$username/exclusions" $BORG_OPTS ::{now:%Y-%m-%d_T%H-%M-%S}_{hostname} $BACKUP_TARGETS

# prune old archives to keep disk space in check
borg prune -v --list --keep-daily=7 --keep-weekly=4 --keep-monthly=6

# all done!
echo "Backup complete at $DATE\n";
EOF

clear
 
echo '**********************************************************'
echo -e "****\x1B[1;92m [!] Check BootOrder: is correct [!] \x1B[1;0m****"
echo '**********************************************************'
echo '**** Resetting BIOS will restore default boot order   ****'
echo '**********************************************************'
echo '**********************************************************'
efibootmgr -v
echo ''
echo '**********************************************************' 
echo '**********************************************************'
echo -e "*************\x1B[1;32m VOID LINUX INSTALL IS COMPLETE \x1B[0m*************"
echo '**********************************************************'
echo '**********************************************************'
echo '**** Verify 'intel-ucode' did install ****'
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
    s|S)
        umount -l -R /mnt && poweroff;;
    e|E)
        exit;;
    u|U)
       umount -l -R /mnt && exit  
esac
