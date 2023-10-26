#!/bin/bash

# Detener y eliminar la instancia Docker
docker stop bd2_p1_f2_mysql
docker rm bd2_p1_f2_mysql
echo "Se elimino la instancia"

# Eliminar la imagen Docker
docker rmi my-mysql-image-proyecto-1
echo "Se elimino la imagen"
docker ps -a
