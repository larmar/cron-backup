#!/bin/bash

trace () {
  stamp=`date +%Y-%m-%d_%H:%M:%S`
  echo "$stamp: $*"
}

# Backups older than this will be removed
OLDER_THAN="3M"
SOURCE=/mnt/odoo/data

# Check if a full backup is necessary, Saturdays day 6 we perform that.
FULL=
  if [ $(date +%u) -eq 6 ]; then
    FULL="--full-if-older-than=6D"
  fi;

trace "Backup of filesystem started"
trace "... removing old backups"

# Remove old backups.
duplicity remove-older-than --force ${OLDER_THAN} ${DEST} 2>&1
trace "... backing up filesystem"

# Full backup run
duplicity \
${FULL} \
${DUPLICITY_BACKUP_EXTRA} \
--encrypt-key=${GPG_KEY} \
--sign-key=${GPG_KEY} \
--include=/mnt/odoo/data/addons \
--include=/mnt/odoo/data/filestore \
--exclude=/** \
${SOURCE} ${DEST} 2>&1 

# And we’re done
trace "Backup of filesystem complete"
trace "----------------------------------"
