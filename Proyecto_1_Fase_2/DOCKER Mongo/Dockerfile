# Utiliza la imagen oficial de MongoDB como base
FROM mongo:latest

# Establece la variable de entorno MONGO_INITDB_ROOT_USERNAME con el nombre de usuario de administrador
ENV MONGO_INITDB_ROOT_USERNAME=admin

# Establece la variable de entorno MONGO_INITDB_ROOT_PASSWORD con la contraseña del usuario de administrador
ENV MONGO_INITDB_ROOT_PASSWORD=admin

# Expón el puerto 27017 para las conexiones de MongoDB
EXPOSE 27017

# Copia un archivo JavaScript con los comandos de inicialización de la base de datos
# COPY init-mongo.js /docker-entrypoint-initdb.d/

# Permite conexiones desde cualquier IP (esto es inseguro y se debe utilizar en entornos de desarrollo o pruebas)
CMD ["mongod", "--bind_ip_all"]

# Restringe el acceso a la base de datos desde IPs específicas en un entorno de producción
