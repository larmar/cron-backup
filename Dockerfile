FROM golang:1.21 as build

ARG WALG_RELEASE=v2.0.1

RUN apt-get update -qq && apt-get install -qqy --no-install-recommends --no-install-suggests cmake liblzo2-dev libsodium23 && \
    cd /go/src/ && \
    git clone -b $WALG_RELEASE --recurse-submodules https://github.com/wal-g/wal-g.git && \
    cd wal-g && \
    GOBIN=/go/bin USE_LIBSODIUM=1 USE_LZO=1 make install_and_build_pg

FROM python:3.12
MAINTAINER Linserv AB <info@linserv.se>

RUN apt-get update  && apt-get install -y \
    cron \
    duplicity \
    python3-boto \
    && rm -rf /var/lib/apt/lists/*

#    apt-get install -qqy curl ca-certificates libsodium23 vim

COPY --from=build /go/src/wal-g/main/pg/wal-g /usr/local/bin/wal-g

ADD crontab.txt /crontab.txt
ADD backup.sh /backup.sh
COPY entry.sh /entry.sh
RUN chmod 755 /entry.sh /backup.sh
RUN /usr/bin/crontab /crontab.txt

VOLUME ["/root/.gnupg","/mnt"]

CMD ["/entry.sh"]
