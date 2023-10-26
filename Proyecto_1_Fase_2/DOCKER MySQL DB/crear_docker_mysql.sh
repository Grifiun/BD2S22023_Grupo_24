#!/bin/bash

# Construir la imagen Docker
# docker build -t my-mysql-container-bd2 .
# echo "Se creo la imagen"

# En este caso haremos la imagen a partir del docker image del proyecto 1
# docker stop bd2_p1_mysql
# docker commit bd2_p1_mysql my-mysql-image-proyecto-1
docker run -d --name bd2_p1_f2_mysql_server -e MYSQL_ROOT_PASSWORD=admin -p 3307:3306 -d -v /home/denilson/Documents/Proyectos/Bases\ 2/BD2S22023_Grupo_24/Proyecto_1_Fase_2/backups:/backups mysql/mysql-server:latest

# Crear y ejecutar la instancia Docker
#docker run -p 3307:3306 --name bd2_p1_f2_mysql -d -v /home/denilson/Documents/Proyectos/Bases\ 2/BD2S22023_Grupo_24/Proyecto_1_Fase_2/backups:/backups my-mysql-image-proyecto-1

echo "Se creo la instancia"

docker start bd2_p1_f2_mysql_server 
echo "Se inicia la instancia"

docker ps -a

