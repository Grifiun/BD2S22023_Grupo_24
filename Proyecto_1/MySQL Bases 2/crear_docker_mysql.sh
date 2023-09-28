#!/bin/bash

# Construir la imagen Docker
docker build -t my-mysql-container-bd2 .
echo "Se creo la imagen"

# Crear y ejecutar la instancia Docker
docker run -p 3306:3306 --name bd2_p1_mysql -d my-mysql-container-bd2
echo "Se creo la instancia"

docker start bd2_p1_mysql 
echo "Se inicia la instancia"

docker ps -a
