FROM golang:1.23 AS build

ARG WALG_RELEASE=v3.0.5
ENV USE_LIBSODIUM=1

RUN apt-get update -qq && apt-get install -qqy --no-install-recommends --no-install-suggests git curl cmake build-essential libsodium-dev && \
    cd /go/src/ && \
    git clone -b $WALG_RELEASE --recurse-submodules https://github.com/wal-g/wal-g.git && \
    cd wal-g && \
    go mod tidy && \
    make pg_clean && \
    make deps && \
    GOBIN=/go/bin make pg_install

FROM python:3.12
LABEL maintainer="Linserv AB <info@linserv.se>"

# Install Borg backup and duplicity
RUN apt-get update  && apt-get install -y \
    cron \
    duplicity \
    borgbackup \
    python3-boto \
    python3-boto3 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY --from=build /go/bin/wal-g /usr/local/bin/wal-g

ADD crontab.txt /crontab.txt
ADD backup.sh /backup.sh
ADD restore.sh /restore.sh
ADD noop.sh /noop.sh
COPY entry.sh /entry.sh
RUN chmod 755 /entry.sh /backup.sh /restore.sh /noop.sh

VOLUME ["/root/.gnupg","/root/.ssh","/mnt"]

CMD ["/entry.sh"]
