FROM ubuntu:18.04 as builder

ENV TZ=Europe/Berlin
ENV DEBIAN_FRONTEND="noninteractive"

WORKDIR /builder/

RUN apt-get -y update && apt-get -y upgrade && \
    apt-get -y install curl autoconf automake cmake libbz2-dev libace-dev libssl-dev libmysqlclient-dev libtool build-essential git && \
    git clone https://github.com/mangoszero/server.git -b master --recursive

ARG SERVER_VERSION=a1022ae477bff5cde33ab4333c8dad7f2ca9635f

RUN cd server && git checkout ${SERVER_VERSION} && \
    mkdir build && cd build && cmake .. -DBUILD_REALMD=No -DBUILD_TOOLS=Yes -DPLAYERBOTS=Yes -DSCRIPT_LIB_ELUNA=Yes \
    -DCONF_INSTALL_DIR=/mangos/etc/ -DCMAKE_INSTALL_PREFIX=/mangos/ && make -j4 && make install

FROM ubuntu:18.04
EXPOSE 8085
WORKDIR /
COPY --from=builder /mangos /mangos
COPY launch.sh .
RUN apt-get -y update && apt-get -y update && \
    apt-get -y install libmysqlclient20 openssl && \
    apt-get autoclean && rm -rf /var/lib/apt/lists/*

RUN cp /mangos/etc/mangosd.conf.dist /mangos/etc/mangosd.conf.dist2 && \
    sed -i "s/^LoginDatabaseInfo            =.*$/LoginDatabaseInfo            = LOGIN_DATABASE_INFO/" /mangos/etc/mangosd.conf.dist2 && \
    sed -i "s/^WorldDatabaseInfo            =.*$/WorldDatabaseInfo            = WORLD_DATABASE_INFO/" /mangos/etc/mangosd.conf.dist2 && \
    sed -i "s/^CharacterDatabaseInfo        =.*$/CharacterDatabaseInfo        = CHARACTER_DATABASE_INFO/" /mangos/etc/mangosd.conf.dist2 && \
    sed -i "s/^DataDir[ \t]*=.*$/DataDir = \"\/mangos\/data\"/" /mangos/etc/mangosd.conf.dist2 && \
    sed -i "s/^LogsDir[ \t]*=.*$/LogsDir = \"\/mangos\/logs\"/" /mangos/etc/mangosd.conf.dist2 && \
    sed -i "s/^LogLevel[ \t]*=.*$/LogLevel = 1/" /mangos/etc/mangosd.conf.dist2 && \
    useradd -ms /bin/bash mangos && \
    chmod +x ./launch.sh && \
    chown -R mangos:mangos /mangos

USER mangos
CMD ["./launch.sh"]

