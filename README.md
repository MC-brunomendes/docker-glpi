# GLPI on Docker
## Yet another docker container
I've started this project as a hobby to learn a little bit of docker and GitHub management. I've based all my work on a container from [diouxx](https://hub.docker.com/u/diouxx) 

# How to use
## Running with no persistence data

Create a container with a MySQL instance

```
docker run --name db-mysql -e MYSQL_DATABASE=glpidb -e MYSQL_ROOT_PASSWORD=r00tpassw20rd  -e MYSQL_USER=glpi_user -e MYSQL_PASSWORD=glpi -d mysql
```

Create the GLPI container

```
docker run --name app-glpi --link db-mysql:mysql -p 80:80 -d brusilva/glpi
```

## Running with persistence data
This should be used when running production environments

Create a container with a MySQL instance with a shared volume
```
docker run --name db-mysql -e MYSQL_DATABASE=glpidb -e MYSQL_ROOT_PASSWORD=r00tpassw20rd  -e MYSQL_USER=glpi_user -e MYSQL_PASSWORD=glpi --volume <localpath>:/var/lib/mysql -d mysql
```

Create the GLPI container linked with the MySQL

```
docker run --name app-glpi --link db-mysql:mysql --volume <localpath>:/var/www/html/glpi  -p 80:80 -d brusilva/glpi
```


## Forcing GLPI Version
Please note that currently the GLPI team published [version 9.5.0-Rc1](https://forum.glpi-project.org/viewtopic.php?id=278487) which still is a RC and therefore has many bugs. I suggest you force the version to version 9.4.6 that is the latest stable version avaiable

```
docker run --name app-glpi --link db-mysql:mysql --volume <localpath>:/var/www/html/glpi  -p 80:80 --env "VERSION_GLPI=9.4.6" -d brusilva/glpi
```
