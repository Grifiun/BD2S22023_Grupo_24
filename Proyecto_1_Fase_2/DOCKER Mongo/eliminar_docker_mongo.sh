#!/bin/bash

# Detener y eliminar la instancia Docker
docker stop mongodb-f2
docker rm mongodb-f2
echo "Se elimino la instancia"

# Eliminar la imagen Docker
# docker rmi my-mysql-image-proyecto-1
# echo "Se elimino la imagen"
docker ps -a
