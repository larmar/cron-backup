FROM golang:1.23 AS build

ARG WALG_RELEASE=v3.0.1

ENV GO_BUILD_TAGS="libsodium lzo"

RUN apt-get update -qq && apt-get install -qqy --no-install-recommends --no-install-suggests git curl cmake build-essential liblzo2-dev libsodium-dev && \
    cd /go/src/ && \
    git clone -b $WALG_RELEASE --recurse-submodules https://github.com/wal-g/wal-g.git && \
    cd wal-g && \
    sed -i '/install_and_build_pg:/s/link_libsodium //' Makefile && \
    go mod tidy && \
    make BUILD_TAGS="$GO_BUILD_TAGS" install_and_build_pg

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

#    apt-get install -qqy curl ca-certificates libsodium23 vim

COPY --from=build /go/src/wal-g/main/pg/wal-g /usr/local/bin/wal-g

ADD crontab.txt /crontab.txt
ADD backup.sh /backup.sh
ADD restore.sh /restore.sh
ADD noop.sh /noop.sh
COPY entry.sh /entry.sh
RUN chmod 755 /entry.sh /backup.sh /restore.sh /noop.sh
# RUN /usr/bin/crontab /crontab.txt # Moved to entry.sh

VOLUME ["/root/.gnupg","/mnt"]

CMD ["/entry.sh"]
