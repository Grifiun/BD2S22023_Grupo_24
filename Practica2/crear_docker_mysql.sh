#!/bin/bash

# Construir la imagen Docker
docker build -t my-mysql-container-bd2-p2 .
echo "Se creo la imagen"

# Crear y ejecutar la instancia Docker
# docker run -p 3306:3306 --name bd2_p2_mysql -d my-mysql-container-bd2-p2  -v /home/denilson/Documents/Proyectos/Bases\ 2/BD2S22023_Grupo_24/Practica2/backups:/backups
docker run -p 3306:3306 --name bd2_p2_mysql -d -v /home/denilson/Documents/Proyectos/Bases\ 2/BD2S22023_Grupo_24/Practica2/backups:/backups my-mysql-container-bd2-p2

echo "Se creo la instancia"

docker start bd2_p2_mysql 
echo "Se inicia la instancia"

# Copiar archivos al contenedor
# docker cp '/home/denilson/Documents/Proyectos/Bases 2/BD2S22023_Grupo_24/Practica2/backups' bd2_p2_mysql:/backups
# echo "Se copió la carpeta backups"
# docker container update --v '/home/denilson/Documents/Proyectos/Bases 2/BD2S22023_Grupo_24/Practica2/backups':/backups bd2_p2_mysql
