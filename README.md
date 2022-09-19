# cron-backup

POSTGRES_USER=odoo
POSTGRES_PASSWORD=odoo
POSTGRES_DB=postgres
AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
GPG_KEY=
PASSPHRASE=
AWS_REGION=eu-north-1
DEST=s3://s3.eu-north-1.amazonaws.com/a67616f5-2216-4710-8aa1-b44b02964f59/test.docker/filestore
WALG_S3_PREFIX=s3://a67616f5-2216-4710-8aa1-b44b02964f59/test.domain.com/odoo_db


# To start docker container use
docker run --hostname backup --env-file docker-env-file -v /mnt:/mnt -v /root/.gnupg:/root/.gnupg -d mycron
