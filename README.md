# mangos-docker 

This a repository with Docker files I wrote for setting up a mangos zero server. There a dozens of different
Docker files for this use case, but I wanted to be able to lock on git commits and easily include the german translation. And that it "just works" :9
More translations can easily be added. Maybe I'll add support for other server versions, depending on my motivation (hint: demand).

## Build
Just dive into the subdir and start to build using the docker build command.

```
docker build -t m0db:<version> .
docker build -t m0realmd:<version> .
docker build -t m0mangosd:<version> .
```

## Example: Running the database
```
docker run --publish 3306:3306 -d --network mangos --name m0db -v m0db-data:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=mangos -e LOCALE=German d4rkwuz/m0db:latest
```
Volume "m0db-data" contains the mysql data files.


## Example: Running realmd
```
docker run --publish 3724:3724 --network mangos -v m0realmd-conf:/mangos/etc -d --name m0realmd -e "LOGIN_DATABASE_INFO=m0db;3306;root;mangos;realmd" d4rkwuz/m0realmd:latest
```
Volume "m0realmd-conf" contains the config file. Change accordingly.


## Example: Running mangosd
```
docker run -it --publish 8085:8085 --network mangos --name m0mangosd -e "WORLD_DATABASE_INFO=m0db;3306;root;mangos;mangos0" -e "CHARACTER_DATABASE_INFO=m0db;3306;root;mangos;character0" -e "LOGIN_DATABASE_INFO=m0db;3306;root;mangos;realmd" -v m0mangosd-logs:/mangos/logs -v m0mangosd-data:/mangos/data -v m0mangosd-conf:/mangos/etc d4rkwuz/m0mangosd:latest
```
Volume "m0mangosd-conf" contains the config files. Change accordingly.

Volume "m0mangosd-data" contains the map data. Put your map files here!

Volume "m0mangosd-logs" contains the server logfiles.
