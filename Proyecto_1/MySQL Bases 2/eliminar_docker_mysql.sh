#!/bin/bash

# Detener y eliminar la instancia Docker
docker stop bd2_p1_mysql
docker rm bd2_p1_mysql
echo "Se elimino la instancia"

# Eliminar la imagen Docker
docker rmi my-mysql-container-bd2
echo "Se elimino la imagen"
docker ps -a
