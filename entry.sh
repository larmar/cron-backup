#!/bin/sh

printenv | grep -E 'AWS_ACCESS_KEY_ID|AWS_SECRET_ACCESS_KEY|GPG_KEY|PASSPHRASE|AWS_REGION|SOURCE|DEST|WALG_S3_PREFIX' >> /etc/environment
# start cron
/usr/sbin/cron -f -L 8
