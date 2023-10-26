Aquí tienes el texto formateado con formato Markdown:

```markdown
### Creación de Copias de Seguridad

#### MySQL

**Crear una copia de seguridad de la base de datos MySQL en el contenedor Docker `bd2_p1_mysql`.**

```bash
# Crear copia de seguridad del esquema completo
time mysqldump -u root -p mydb > /backups/backup-proyecto-1-fase-2.sql

# Crear copia de seguridad de la tabla Company
time mysqldump -u root -p mydb Company > /backups/backup-proyecto-1-fase-2-Company.sql
```

**Copiar la copia de seguridad desde el contenedor al host local.**

```bash
# Copiar archivo de copia de seguridad del esquema completo
docker cp bd2_p1_mysql:/backup-proyecto-1-fase-2.sql "/home/denilson/Documents/Proyectos/Bases 2/BD2S22023_Grupo_24/Proyecto_1/backups/"

# Copiar archivo de copia de seguridad de la tabla Company
docker cp bd2_p1_mysql:/backups/backup-proyecto-1-fase-2-Company.sql "/home/denilson/Documents/Proyectos/Bases 2/BD2S22023_Grupo_24/Proyecto_1_Fase_2/backups/"
```

**Recuperar la copia de seguridad en el contenedor Docker `bd2_p1_f2_mysql_server`.**

```bash
# Crear una nueva base de datos 'Calificacion_Fase2' (si no existe)
time mysql -u root -p -e "CREATE DATABASE IF NOT EXISTS Calificacion_Fase2;"

# Restaurar la copia de seguridad del esquema completo
time mysql -u root -p Calificacion_Fase2 < /backups/backup-proyecto-1-fase-2.sql

# Crear una nueva base de datos 'Fase2' (si no existe)
time mysql -u root -p -e "CREATE DATABASE IF NOT EXISTS Fase2;"

# Restaurar la copia de seguridad de la tabla Company
time mysql -u root -p fase2 < /backups/backup-proyecto-1-fase-2.sql
time mysql -u root -p mydb Company < /backups/backup-proyecto-1-fase-2-Company.sql
```
#### MongoDB

**Copiar la copia de seguridad de MongoDB `fase2` desde el contenedor al host local.**

```bash
docker cp mongodb-f2:/backups/fase2 "/home/denilson/Documents/Proyectos/Bases 2/BD2S22023_Grupo_24/Proyecto_1_Fase_2/backups/"
```

**Crear diferentes copias de seguridad en MongoDB, incluyendo todas las colecciones y colecciones individuales.**

```bash
# Crear una copia de seguridad de la base de datos 'fase2' incluyendo todas las colecciones
time mongodump --host localhost --port 27017 --username admin --password admin --authenticationDatabase admin --db fase2 --out /backups/

# Crear una copia de seguridad de la colección 'genre'
time mongodump --host localhost --port 27017 --username admin --password admin --authenticationDatabase admin --db fase2 --collection genre --out /backups/

# Crear una copia de seguridad de la colección 'game'
time mongodump --host localhost --port 27017 --username admin --password admin --authenticationDatabase admin --db fase2 --collection game --out /backups/

# Crear una copia de seguridad de la colección 'company'
time mongodump --host localhost --port 27017 --username admin --password admin --authenticationDatabase admin --db fase2 --collection company --out /backups/
```

**Para recuperar una copia de seguridad de MongoDB en una base de datos y/o colección específica:**

```bash
# Restaurar una colección específica en una base de datos
mongorestore -d db_name -c collection_name /path/file.bson
```


```java
Este Markdown explica cómo crear y recuperar copias de seguridad tanto en MySQL como en MongoDB, incluyendo copias de seguridad de bases de datos completas y colecciones individuales.
```
```java
-- Create Backup from Docker bd2_p1_mysql
crear backup de sql
time mysqldump -u root -p mydb > /backups/backup-proyecto-1-fase-2.sql
time mysqldump -u root -p mydb Company > /backups/backup-proyecto-1-fase-2-Company.sql

Copiar backup hacia el host
docker cp bd2_p1_mysql:/backup-proyecto-1-fase-2.sql "/home/denilson/Documents/Proyectos/Bases 2/BD2S22023_Grupo_24/Proyecto_1/backups/" 
docker cp bd2_p1_mysql:/backups/backup-proyecto-1-fase-2-Company.sql "/home/denilson/Documents/Proyectos/Bases 2/BD2S22023_Grupo_24/Proyecto_1_Fase_2/backups/" 

docker cp "/home/denilson/Documents/Proyectos/Bases 2/BD2S22023_Grupo_24/Proyecto_1_Fase_2/backups/backup-proyecto-1-fase-2-Company.sql" bd2_p1_mysql:/backups/


-- Recuperar en docker bd2_p1_f2_mysql_server
time mysql -u root -p -e "CREATE DATABASE IF NOT EXISTS Calificacion_Fase2;"
time mysql -u root -p Calificacion_Fase2 < /backups/backup-proyecto-1-fase-2.sql

time mysql -u root -p -e "CREATE DATABASE IF NOT EXISTS Fase2;"
time mysql -u root -p fase2 < /backups/backup-proyecto-1-fase-2.sql
time mysql -u root -p mydb Company < /backups/backup-proyecto-1-fase-2-Company.sql


----------- MONGO
Copiar el backup de fase2 hacia afuera del contenedor
```js
    docker cp mongodb-f2:/backups/fase2 "/home/denilson/Documents/Proyectos/Bases 2/BD2S22023_Grupo_24/Proyecto_1_Fase_2/backups/" 

```
Diferentes backups, hacia todo y hacia collections
time mongodump --host localhost --port 27017 --username admin --password admin --authenticationDatabase admin --db fase2 --collection genre --out /backups/
time mongodump --host localhost --port 27017 --username admin --password admin --authenticationDatabase admin --db fase2 --collection game --out /backups/
time mongodump --host localhost --port 27017 --username admin --password admin --authenticationDatabase admin --db fase2 --collection company --out /backups/
time mongodump --host localhost --port 27017 --username admin --password admin --authenticationDatabase admin --db fase2 --out /backups/

Para recuperar
restore
mongorestore -d db_name -c collection_name /path/file.bson