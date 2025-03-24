#!/bin/sh

printenv | grep -E 'AWS_ACCESS_KEY_ID|AWS_SECRET_ACCESS_KEY|GPG_KEY|PASSPHRASE|AWS_REGION|SOURCE|DEST|WALG_S3_PREFIX|DUPLICITY_BACKUP_EXTRA' >> /etc/environment

# Delete filestore
rm -rf /mnt/odoo/data/*

# Restore from backup
duplicity --force restore \$DEST /mnt/odoo/data

# Change owner on files
chown -R 101:101 /mnt/odoo/data
