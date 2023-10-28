# Proyecto de Sistemas de Bases de Datos 2 - Universidad de San Carlos de Guatemala 2023 Segundo Semestre

## Descripción
Este proyecto se centra en cargar información relacionada con el negocio de los videojuegos desde el sitio web [https://www.igdb.com/](https://www.igdb.com/). Los datos se almacenan en una base de datos relacional y en una base de datos NoSQL (MongoDB). Además, se implementan consultas y procedimientos almacenados para acceder y mostrar información específica de los juegos.

## Fases del Proyecto

### Fase 1

#### a) Modelo de Datos
Se presenta el modelo de datos utilizado para la carga de los datos, que incluye tablas, relaciones y atributos. Este modelo se ha definido conforme a las reuniones en clase y a los requisitos del proyecto.

#### b) Extracción y Carga de Datos
Para extraer los datos del sitio [https://www.igdb.com/](https://www.igdb.com/), utilizamos las APIs disponibles y los cargamos en una base de datos relacional de elección. A continuación, se proporciona una guía de los pasos necesarios para lograr esto:

##### b.1) Paso 1: Regístrese en Twitch Developers y Registre una Aplicación

Primero, debe registrarse en el sitio de Twitch Developers y crear una nueva aplicación para obtener credenciales de API. Aquí hay una captura de pantalla de cómo registrar una aplicación:

![Registrar App](images/RegistrarApp.png)

Una vez que haya completado este paso, obtendrá un ID de Cliente y una Secret Key, como se mencionó en la parte anterior.

#### b.2) Paso 2: Generar una Secret Key

Necesitará la Secret Key para autenticar su solicitud a la API de Twitch. Aquí hay una captura de pantalla de cómo generar la Secret Key:

![Generar Secret Key](images/generarSecretKey.png)

Por ejemplo:

- ID del Cliente: 4a39rzmpjiy0m9dsne174j7rs2v0li
- ID de la Secret Key: 57481gm1vpobu1sknj3s9opb2soult

#### b.3) Autenticación y Acceso a la API de Twitch

Después de obtener sus credenciales de API de Twitch, puede utilizarlas para autenticar y acceder a la API. A continuación, se muestra un ejemplo de cómo hacer una solicitud POST con curl para obtener un token de acceso:

```bash
curl -X POST "https://id.twitch.tv/oauth2/token" \
-d "client_id=4a39rzmpjiy0m9dsne174j7rs2v0li" \
-d "client_secret=57481gm1vpobu1sknj3s9opb2soult" \
-d "grant_type=client_credentials"
```

Este comando curl realiza una solicitud POST a la URL "https://id.twitch.tv/oauth2/token" con los datos requeridos en el cuerpo de la solicitud, lo que resulta en un token de acceso que se utiliza para autenticar sus solicitudes a la API de Twitch.

La respuesta tendrá un formato JSON, y debería verse algo así:

```json
{"access_token":"gu2tf2uczypq8lwaar86kkmimf3o1jsuadad","expires_in":5070743,"token_type":"bearer"}
```

Luego, puede utilizar el token de acceso y las credenciales de cliente para realizar solicitudes a los puntos finales de la API de Twitch, como se muestra en la parte final de tu documento.

#### b.4) Conexión y Solicitud a los Endpoints

Una vez que haya obtenido el token de acceso y las credenciales de cliente de Twitch, puede utilizarlos para conectarse y realizar solicitudes a los endpoints de la API. A continuación, se muestra un ejemplo de cómo construir una solicitud y realizarla:

```javascript
const headers = {
  'Client-ID': `${apiKey}`,
  'Authorization': `Bearer ${accessToken}`,
  'Accept': 'application/json',
};

// Crea la cláusula WHERE utilizando los límites
const whereClause = `where id >= ${lowerLimit}`;

// Crea el cuerpo de la solicitud incluyendo la cláusula WHERE
const body = `${endpoint.fieldsName} ${whereClause}; limit 500; sort id asc;`;
const response = await fetch(endpoint.url, {
  method: 'POST',
  headers: headers,
  body: body
});
```

En este ejemplo, hemos definido un objeto `headers` que contiene las credenciales de cliente y el token de acceso necesarios para autenticar la solicitud. Luego, hemos construido una cláusula `WHERE` basada en los límites que deseamos aplicar a la consulta.

El cuerpo de la solicitud se compone de la información necesaria para la consulta, incluida la selección de campos (`endpoint.fieldsName`) y la cláusula `WHERE`. La solicitud se realiza utilizando el método `POST` y se incluyen los encabezados y el cuerpo en la solicitud.

También se proporciona un ejemplo de cómo definir endpoints para diferentes tipos de datos, como juegos (Game), que incluye la URL del endpoint, el mapeo de campos y el nombre de la tabla correspondiente en la base de datos.

```javascript
const endpoints = {
  game: {
    url: 'https://api.igdb.com/v4/games',
    fieldsMapping: {
      'idGame': 'id',
      'name': 'name',
      // ... Otros campos mapeados
    },
    fieldsName: "fields id, name, summary, storyline, rating, rating_count, ...", // Campos que deseas recuperar
    tableName: "Game" // Nombre de la tabla en la base de datos relacional
  },
  // Otros endpoints para diferentes tipos de datos
};
```

Con esta estructura, puedes definir fácilmente endpoints para diferentes tipos de datos y realizar solicitudes a la API de acuerdo con tus necesidades.

#### c) Stored Procedure
Se ha implementado un stored procedure que recibe el nombre del juego o su ID como parámetro y muestra información relacionada con el mismo, siguiendo el formato mínimo requerido.

### Fase 2

#### SQL
a) Se realiza la restauración de un backup de la base de datos relacional creada en la Fase 1, utilizando scripts.

b) Se efectúa la truncación de la bitácora, se obtiene el collation de las tablas y columnas, y se verifica la fragmentación de los índices. Todo esto se realiza mediante scripts SQL.

#### MongoDB
c) Se carga toda la información recopilada en la Fase 1 en una base de datos NoSQL (MongoDB). Se garantiza la capacidad de navegar y extraer cualquier dato necesario.

d) Se documenta el proceso de carga en MongoDB, utilizando las herramientas disponibles.
Agregué la información que proporcionaste a las secciones correspondientes:

###### d.1) Proceso de Carga en MongoDB con Mongo Relational Migrator

En esta sección, se documenta el proceso de carga de datos en MongoDB utilizando la herramienta Mongo Relational Migrator. Este proceso incluye la transferencia de datos desde una base de datos relacional (como MySQL u otra instancia SQL) hacia MongoDB. A continuación, se detallan los pasos y se proporciona una imagen ilustrativa.

###### d.1.1) Paso 1: Conexión a la Base de Datos Relacional

El primer paso implica la conexión a la base de datos relacional desde la cual se transferirán los datos. Para ello, se debe proporcionar la información de conexión necesaria, como la dirección del servidor, el nombre de usuario y la contraseña.

###### d.1.2) Paso 2: Establecimiento de la Conexión a MongoDB

Una vez que se ha establecido la conexión con la base de datos relacional, se procede a establecer una conexión con la base de datos MongoDB de destino. Se debe proporcionar la información de conexión de MongoDB, que incluye la dirección del servidor y las credenciales de acceso. La cadena de conexión típica para conectarse a MongoDB en un servidor local es:

```
mongodb://admin:admin@localhost:27017/fase2?authSource=admin
```

###### d.1.3) Paso 3: Ajuste de Tablas y Creación de Nuevas Colecciones

Antes de iniciar la transferencia de datos, es importante ajustar la estructura de las tablas de la base de datos relacional para que se adapten a las colecciones de MongoDB. Esto puede incluir la definición de campos adicionales o la adaptación de la estructura de los datos.

###### d.1.4) Paso 4: Inicio de la Sincronización

Una vez que las tablas se han ajustado correctamente, se inicia el proceso de sincronización de datos. Mongo Relational Migrator comienza a transferir los datos desde la base de datos relacional hacia las colecciones de MongoDB.

###### d.1.5) Paso 5: Espera de los Datos

Durante la sincronización, se debe esperar a que se completen todas las operaciones de transferencia. La duración de este proceso dependerá del volumen de datos y la velocidad de conexión entre las bases de datos.

###### d.1.6) Imagen Ilustrativa

A continuación, se muestra una imagen ilustrativa que representa el proceso de transferencia de datos desde la base de datos relacional hacia MongoDB utilizando Mongo Relational Migrator:

![Transferencia de Datos](images/mongo-transfer.png)

Este proceso garantiza que los datos se carguen con éxito en MongoDB, lo que permite realizar consultas y operaciones en una base de datos NoSQL eficiente y escalable.

##### d.2) Configuración de MongoDB en Localhost y Conexión a un Host Remoto

###### d.2.1) Crear una Base de Datos y un Usuario en MongoDB

Para configurar MongoDB en localhost y crear una base de datos con un usuario, sigue estos pasos:

###### d.2.2) Crear una Base de Datos en MongoDB

Abre una terminal y ejecuta el siguiente comando para crear una base de datos llamada "fase2":

```bash
$ use fase2
```

###### d.2.3) 2. Crear un Usuario en MongoDB

A continuación, crea un usuario en la base de datos "fase2" con roles de lectura y escritura:

```javascript
$ db.createUser({
  user: "user",
  pwd: "admin",
  roles: [
    {
      role: "readWrite",
      db: "fase2"
    }
  ]
})
```

###### d.2.4) Conexión a MongoDB en un Host Remoto

Si deseas conectar MongoDB a un host remoto, utiliza una cadena de conexión que incluye la dirección del servidor remoto y las credenciales de acceso. Por ejemplo, la cadena de conexión para conectarse a un host remoto podría ser similar a esta:

```
mongodb+srv://user:*****@mongocluster.***.****.net/
```

Asegúrate de proporcionar la dirección del servidor y las credenciales correctas según la configuración de tu host remoto.

Estos pasos te permitirán configurar MongoDB en localhost, crear una base de datos y un usuario, y conectarte a un host remoto si es necesario.

e) Se presenta el diseño de la base de datos NoSQL, explicando la estructura de los documentos y colecciones utilizados.

A continuación, presento el diseño de la base de datos NoSQL, explicando la estructura de los documentos y colecciones utilizados:

**Colección: `game`**
- **Descripción:** Esta es la entidad principal de la base de datos y contiene información detallada sobre los juegos.
- **Estructura del Documento:**
  - `idGame`: ID único del juego.
  - `name`: Nombre del juego.
  - `rating`: Valoración del juego.
  - `ratingCount`: Cantidad de valoraciones.
  - `aggregatedRating`: Valoración agregada.
  - `aggregatedRatingCount`: Cantidad de valoraciones agregadas.
  - `artworks`: Imágenes relacionadas al juego.
  - `coverImage`: Imagen de portada del juego.
  - `firstReleaseDate`: Fecha de lanzamiento del juego.
  - `keywords`: Palabras clave relacionadas al juego.
  - `storyline`: Sinopsis del juego.
  - `summary`: Resumen del juego.
  - `totalRating`: Valoración total.
  - `totalRatingCount`: Cantidad total de valoraciones.
  - `websites`: Sitios web relacionados al juego.
  - `nameCategory`: Categoría principal del juego.
  - `gameGenres`: Lista de géneros a los que pertenece el juego.
  - `nameStatus`: Estado del juego.
  - `languageGames`: Información sobre los idiomas compatibles con el juego en diferentes modos (audio, subtítulos, interfaz).
  - `platformGames`: Plataformas en las que se lanzó el juego.

**Colección: `genre`**
- **Descripción:** Esta colección almacena información sobre los géneros de los juegos y contiene una lista de juegos relacionados para cada género.
- **Estructura del Documento:**
  - `idGenre`: ID único del género.
  - `nameTheme`: Nombre del género.
  - `games`: Lista de juegos relacionados a este género. Cada entrada en la lista incluirá información básica sobre el juego, como el `idGame` y el `name`.

**Colección: `company`**
- **Descripción:** Esta colección almacena información sobre las compañías y contiene una lista de juegos relacionados para cada compañía.
- **Estructura del Documento:**
  - `idCompany`: ID único de la compañía.
  - Otros campos relacionados con la información de la compañía.
  - `games`: Lista de juegos relacionados a esta compañía. Cada entrada en la lista incluirá información básica sobre el juego, como el `idGame` y el `name`.

**Imágenes Relacionadas al Diseño de la Base de Datos:**
- Se proporcionan imágenes (`mongo-game.png`, `mongo-genre.png`, `mongo-company.png`) que representan gráficamente la estructura de las colecciones `game`, `genre` y `company`, respectivamente.

![Game Collection](images/mongo-game.png)
![Genre Collection](images/mongo-genre.png)
![Company Collection](images/mongo-company.png)

Este diseño de base de datos NoSQL se ha creado para almacenar información detallada sobre juegos, géneros y compañías, lo que facilita la realización de diversas consultas y búsquedas en la base de datos. La estructura de documentos y colecciones se ha diseñado de manera eficiente para satisfacer los requerimientos de la aplicación.

f) Las consultas definidas en la Fase 1 se replican en MongoDB, utilizando métodos o funciones en lugar de stored procedures. Se proporciona el código utilizado.

## Instrucciones de Uso
Se proporcionan instrucciones claras sobre cómo utilizar y ejecutar las consultas, stored procedures y otros elementos del proyecto.

### Consultas

**0. Stored Procedure para Mostrar Información de un Juego**
   - Descripción: Este stored procedure recibe el nombre del juego o su ID como parámetro y muestra toda la información relacionada con el juego.
   - Parámetros: 
     - `@nombreJuego` (nombre del juego) - Puede ser una palabra clave o un ID.
   - Formato de Salida: El formato de salida se define en clase.

**1. Vista de los 100 Mejores Juegos Evaluados por Rating**
   - Descripción: Esta vista muestra los 100 mejores juegos según su valoración en el sitio web. Muestra el nombre del juego, la plataforma, el rating y el género.
   - Formato de Salida: Nombre del juego, plataforma, rating, género.

**2. Stored Procedure para Buscar Juegos por Nombre**
   - Descripción: Este stored procedure recibe un parámetro alfanumérico para buscar juegos por nombre (palabras o aproximaciones).
   - Parámetros:
     - `@busqueda` (cadena alfanumérica) - La palabra clave o aproximación para buscar juegos.
   - Formato de Salida: El formato de salida se define en clase.

**3. Stored Procedure para Mostrar Información de Juegos Agrupada por Plataforma**
   - Descripción: Este stored procedure recibe el nombre del juego como parámetro y busca y muestra la información del juego agrupada por plataforma.
   - Parámetros:
     - `@nombreJuego` (nombre del juego) - Puede ser una palabra clave o un ID del juego.
   - Formato de Salida: El formato de salida se define en clase.

**4. Vista de los 100 Juegos que Soportan Más Idiomas**
   - Descripción: Esta vista muestra los 100 juegos que admiten la mayor cantidad de idiomas, incluyendo subtítulos y audio. Los juegos se ordenan por rating, nombre y se muestra la información de los idiomas admitidos.
   - Formato de Salida: Nombre del juego, rating, idiomas admitidos.

**5. Consulta para Mostrar los Mejores Juegos por Género**
   - Descripción: Esta consulta muestra los juegos más valorados por género. Los juegos se ordenan por rating.
   - Formato de Salida: Género, nombre del juego, rating.

Estas consultas y stored procedures están diseñados para proporcionar información específica sobre los juegos en la base de datos. Los formatos de salida y otros detalles específicos pueden ser definidos durante la implementación.


Asegúrate de que la documentación sea clara, concisa y esté bien organizada. Proporciona ejemplos y ejecute las consultas y procedimientos para demostrar su funcionamiento.

Este es solo un esbozo y puedes adaptarlo según tus necesidades específicas y los detalles de tu proyecto. Asegúrate de cumplir con todos los requisitos del proyecto y de que la documentación sea completa y fácil de entender.
