#!/bin/sh
# https://superuser.com/questions/1361971/how-do-i-automate-borg-backup

DATE=$(date)

echo "Starting backup at $DATE"
# Bitwarden database backup
cd /home/$USER/src/bitwarden_rs/target/release/data
rm backup.sqlite3
sqlite3 db.sqlite3 ".backup 'backup.sqlite3'"

# setup script variables
# export BORG_PASSPHRASE="secret-passphrase-here!"
export BORG_UNKNOWN_UNENCRYPTED_REPO_ACCESS_IS_OK=yes
export BORG_REPO="/mnt/void-backup/borg"
export BACKUP_TARGETS="/"
#export BACKUP_NAME="voidlinux.local"
BORG_OPTS="--stats --one-file-system"

if [ -d "/mnt/void-backup/borg" ]; then
# create borg backup archive
borg create $BORG_OPTS -e "/dev" -e "/tmp" -e "/proc" -e "/sys" -e "/run" -e "/home/$USER/exclusions" ::{now:%Y-%m-%d_T%H-%M-%S}_{hostname} $BACKUP_TARGETS

# prune old archives to keep disk space in check
borg prune -v --list --keep-daily=7 --keep-weekly=4 --keep-monthly=6

# all done!
notify-send "Borg Backup complete at $DATE"
else
notify-send "ERROR Borg Backup FAILED at $DATE"
fi
