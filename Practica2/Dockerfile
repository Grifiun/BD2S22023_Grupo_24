# Utiliza la imagen base de MySQL desde Docker Hub
FROM mysql:latest

# Configura las variables de entorno para la base de datos
ENV MYSQL_ROOT_PASSWORD=admin
ENV MYSQL_DATABASE=mydb


# Copia los archivos SQL personalizados a la carpeta /docker-entrypoint-initdb.d
COPY sql-scripts/ /docker-entrypoint-initdb.d/

