#!/bin/bash

# Construir la imagen Docker
# docker build -t mongo-localhost-server .
# echo "Se creo la imagen"

# En este caso haremos la imagen a partir del docker image del proyecto 1 fase 2

# Crear y ejecutar la instancia Docker
#docker run -p 3307:3306 --name bd2_p1_f2_mysql -d -v /home/denilson/Documents/Proyectos/Bases\ 2/BD2S22023_Grupo_24/Proyecto_1_Fase_2/backups:/backups my-mysql-image-proyecto-1
docker run -p 27017:27017 --name mongodb-f2 -d -v "/home/denilson/Documents/Proyectos/Bases\ 2/BD2S22023_Grupo_24/Proyecto_1_Fase_2/backups":/backups mongo-localhost-server

echo "Se creo la instancia"

docker start mongodb-f2 
echo "Se inicia la instancia"

docker ps -a

