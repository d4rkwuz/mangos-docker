FROM ubuntu:18.04 as builder

ENV TZ=Europe/Berlin
ENV DEBIAN_FRONTEND="noninteractive"

WORKDIR /builder/

RUN apt-get -y update && apt-get -y upgrade && \
    apt-get -y install curl autoconf automake cmake libbz2-dev libace-dev libssl-dev libmysqlclient-dev libtool build-essential git && \
    git clone https://github.com/mangoszero/server.git -b master --recursive

ARG SERVER_VERSION=a1022ae477bff5cde33ab4333c8dad7f2ca9635f

RUN cd server && git checkout ${SERVER_VERSION} && \
    mkdir build && cd build && cmake .. -DBUILD_MANGOSD=No -DBUILD_TOOLS=No -DCONF_INSTALL_DIR=/mangos/etc/ -DCMAKE_INSTALL_PREFIX=/mangos/ && \
    make -j4 && make install

FROM ubuntu:18.04
EXPOSE 8085
WORKDIR /
COPY --from=builder /mangos /mangos
COPY launch.sh .
RUN apt-get -y update && apt-get -y update && \
    apt-get -y install libmysqlclient20 openssl && \
    apt-get autoclean && rm -rf /var/lib/apt/lists/*

RUN cp /mangos/etc/realmd.conf.dist /mangos/etc/realmd.conf.dist2 && \
    sed -i 's/^LoginDatabaseInfo[ \t]*=.*$/LoginDatabaseInfo            = LOGIN_DATABASE_INFO/' /mangos/etc/realmd.conf.dist2 && \
    useradd -ms /bin/bash realm && \
    chmod +x ./launch.sh && \
    chown -R realm:realm /mangos

USER realm
CMD ["./launch.sh"]

