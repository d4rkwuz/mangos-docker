FROM mysql:5.7
EXPOSE 3306

ARG DATABASE_VERSION=22a9020cabf7a691e4024f8f9e812676b0be3d7c

RUN apt-get update && apt-get install git -y && \
    git clone https://github.com/mangoszero/database.git -b master --depth 1 --recursive && \
    cd database && git checkout ${DATABASE_VERSION} && \
    apt-get remove --purge -y git && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /
COPY launch.sh .
RUN chmod +x ./launch.sh 

ENTRYPOINT ["./launch.sh"]
CMD ["mysqld"]

