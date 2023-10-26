# Store Procedure principal

```js
// Define la función que toma el nombre o ID del juego como parámetro
function findGameInfo(nameOrId) {
  // Realiza una consulta para encontrar el juego basado en el nombre o ID
  var game = db.game.findOne({
    $or: [
      { name: nameOrId },
      { idGame: parseInt(nameOrId) }
    ]
  });

  // Si se encontró un juego, muestra la información relacionada
  if (game) {    
    // Puedes definir el formato de salida según tus preferencias
    print("Información del juego:");
    print("ID del juego: " + game.idGame);
    print("Nombre: " + game.name);
    print("Resumen: " + game.summary);
    print("Sinopsis: " + game.storyline);
    print("Calificacion: " + game.rating);
    print("Cantidad de calificaciones: " + game.ratingCout);
    print("Calificaciones totales: " + game.totalRating);
    print("Cantidad de Calificaciones totales: " + game.totalRatingCount);
    print("Estado: " + game.nameStatus);
    print("Categoria: " + game.nameCategory);
    // Agrega más campos según sea necesario

    // Muestra información sobre los idiomas soportados
    if (Array.isArray(game.languageGames)) {
      print("Idiomas Soportados:");
      game.languageGames.forEach(function (language) {
        print(" - " + language.language.nameLanguage + " : " + language.languageSupportType.supportType);
        // Agrega más detalles sobre el idioma si es necesario
      });
    } else {
      print("No hay información sobre idiomas soportados.");
    }

    // Muestra información sobre los generos
    if (Array.isArray(game.gameGenres)) {
      print("Generos: ");
      game.gameGenres.forEach(function (gameGenre) {
        print(" - " + gameGenre.nameTheme);
        // Agrega los generos
      });
    } else {
      print("No hay información sobre generos.");
    }

    // Muestra información sobre las plataformas
    if (Array.isArray(game.platformGames)) {
      print("Plataformas: ");
      game.platformGames.forEach(function (platformGame) {
        print(" - " + platformGame.namePlatform);
        // Agrega las plataforas
      });
    } else {
      print("No hay información sobre plataformas.");
    }

    // Muestra información sobre las companias
    if (Array.isArray(game.involvedCompanies)) {
      print("Companias: ");
      game.involvedCompanies.forEach(function (involvedCompany) {
        print(" - " + involvedCompany.nameCompany);
        // Agrega las plataforas
      });
    } else {
      print("No hay información sobre companias.");
    }

    // Agrega más información adicional si es necesario

  } else {
    print("No se encontró un juego con el nombre o ID especificado.");
  }
}
```
```js
// Llama a la función y pasa el nombre o ID del juego como parámetro
findGameInfo("Dark Souls"); // Reemplaza con el nombre o ID del juego que desees buscar
```

# CONSULTA 1: Top juegos por rating

Vista que muestre el top 100 de los juegos evaluado por Rating o
valoración según el sitio web. (nombre, plataforma, rating, genero).

```js
db.createView("Consulta_1_top_100_games", "game", [
  {
    $sort: { rating: -1 } // Ordena por rating en orden descendente
  },
  {
    $limit: 100 // Limita los resultados a los 100 mejores juegos
  },
  {
    $project: {
      _id: 0, // Excluye el campo _id del resultado
      // Top: { $add: [ { $indexOfArray: [ [], [] ] }, 1 ] }, // Calcula el número de fila como un valor constante
      Nombre: "$name", // Renombra el campo name a Nombre
      Plataforma: {
        $reduce: {
          input: "$platformGames",
          initialValue: "",
          in: {
            $concat: [
              "$$value",
              { $cond: [ { $gt: [ { $strLenCP: "$$value" }, 0 ] }, ", ", "" ] },
              "$$this.namePlatform"
            ]
          }
        }
      },
      Rating: { $ifNull: ["$rating", Decimal128("0")] }, // Establece el valor predeterminado a 0 si rating es nulo
      Cantidad_de_calificaciones: { $ifNull: ["$ratingCount", 0] }, // Establece el valor predeterminado a 0 si ratingCount es nulo
      Genero: {
        $reduce: {
          input: "$gameGenres",
          initialValue: "",
          in: {
            $concat: [
              "$$value",
              { $cond: [ { $gt: [ { $strLenCP: "$$value" }, 0 ] }, ", ", "" ] },
              "$$this.nameTheme"
            ]
          }
        }
      }
    }
  }
]);

  
// Sin filtros
  db.game.aggregate([
    {
      $sort: { rating: -1 } // Ordena por rating en orden descendente
    },
    {
      $limit: 100 // Limita los resultados a los 100 mejores juegos
    }
  ]);
  
```

Ejecutar: Llama a la vista con find
```js
db.Consulta_1_top_100_games.find()
```

# CONSULTA 2: Buscar juegos por parámetro alfanumérico
Stored procedure que reciba un parámetro alfanumérico para
buscar juegos por nombre (palabras o aproximaciones).

```js
function Consulta_2_buscarJuegosPorNombre(nombreJuego) {// Nombre del juego a buscar
  const regexPattern = new RegExp(nombreJuego, "i"); // 'i' indica que la búsqueda es insensible a mayúsculas y minúsculas

  return db.game.find({ name: { $regex: regexPattern } }).toArray();
}
  
```

Ejecutar: Llama a la función y pasa el nombre del juego como parámetro
```js
Consulta_2_buscarJuegosPorNombre("nombre del juego"); 
```

Ejemplos:
```js
// Llama a la función y pasa el nombre del juego como parámetro
Consulta_2_buscarJuegosPorNombre("Dark Souls"); 
```

# CONSULTA 3: Buscar juegos y agrupar por plataforma
Stored procedure que reciba un parámetro el juego, que busque y
muestre la información y agrupe por plataforma
```js
function Consulta_3_buscarJuegosPorNombre(nombreJuego) {
  return db.game.aggregate([
    {
      $match: {
        $or: [
          { name: { $regex: nombreJuego, $options: "i" } },
          { idGame: parseInt(nombreJuego) }
        ]
      }
    },
    {
      $group: {
        _id: "$platformGames.namePlatform",
        juegos: { $push: "$$ROOT" }
      }
    }
  ]).toArray();
}
```
Ejecutar: Llama a la función y pasa el nombre del juego como parámetro
```js
Consulta_3_buscarJuegosPorNombre("nombre_del_juego"); 
```

Ejemplos:
```js
Consulta_3_buscarJuegosPorNombre("Legend of Zelda"); 
```

# CONSULTA 4: Top 100 juegos con mayor cantidad de soportes de idiomas
Vista que muestre el top 100 de juegos que soporten más idiomas
(subtítulos y audio) ordenados por rating, nombre y que idiomas
soportan
```js
db.createView("Consulta_4_top_games_multilingual", "game", [
  {
    $project: {
      _id: 0,
      idGame: 1,
      name: 1,
      ratingMax: {
        $max: [
          { $ifNull: ["$rating", 0] },
          { $ifNull: ["$totalRating", 0] },
          { $ifNull: ["$aggregatedRating", 0] }
        ]
      },
      cantidadLenguajes: {
        $cond: {
          if: { $isArray: "$languageGames" },
          then: { $size: "$languageGames" },
          else: 0
        }
      },
      idiomasSoportados: {
        $cond: {
          if: { $isArray: "$languageGames" },
          then: "$languageGames.nameLanguage",
          else: []
        }
      }
    }
  },
  {
    $sort: {
      ratingMax: -1,
      cantidadLenguajes: -1,
      name: 1      
    }
  },
  { $limit: 100 }
]);

```
Ejecutar: Llama a la vista con find
```js
db.Consulta_4_top_games_multilingual.find()
```

# CONSULTA 5: Top X de juegos por Género y rating
Consulta que muestre el top los juegos por genero, ordenados por rating
```js
function Consulta_5_getTopGamesByGenre(limit) {
  return db.genre.aggregate([
    {
      $unwind: "$gameGenres"
    },
    {
      $project: {
        _id: 1,
        idGenre: 1,
        nameTheme: 1,
        juegos: {
          name: "$gameGenres.name",
          idGame: "$gameGenres.idGame",
          rating: {
            $max: {
              $ifNull: ["$gameGenres.rating", "$gameGenres.totalRating"]
            }
          },
          firstReleaseDate: "$gameGenres.firstReleaseDate"
        }
      }
    },
    {
      $match: {
        "juegos.rating": { $exists: true }
      }
    },
    {
      $sort: { nameTheme: 1, "juegos.rating": -1 }
    },
    {
      $group: {
        _id: "$_id",
        idGenre: { $first: "$idGenre" },
        nameTheme: { $first: "$nameTheme" },
        juegos: { $push: "$juegos" }
      }
    },
    {
      $project: {
        _id: 0,
        idGenre: 1,
        nameTheme: 1,
        juegos: { $slice: ["$juegos", limit] }
      }
    }
  ]).toArray();
}


```
Ejecutar 
```js
// Llama a la función con la cantidad de juegos que deseas
Consulta_5_getTopGamesByGenre(10);
```

# CONSULTA 6: Top X de juegos por Compania y rating
Consulta que muestre el top los juegos por genero, ordenados por rating
```js
function Consulta_6_getTopGamesByCompany(limit) {
  return db.company.aggregate([
    {
      $unwind: "$games"
    },
    {
      $project: {
        _id: 1,
        idCompany: 1,
        name: 1,
        description: 1,
        juegos: {
          name: "$games.name",
          idGame: "$games.idGame",
          rating: {
            $max: {
              $ifNull: ["$games.rating", "$games.totalRating"]
            }
          },
          developer: "$games.developer",
          porting: "$games.porting",
          publisher: "$games.publisher",
        }
      }
    },
    {
      $match: {
        "juegos.rating": { $exists: true }
      }
    },
    {
      $sort: { name: 1, "juegos.rating": -1 }
    },
    {
      $group: {
        _id: "$_id",
        idCompany: { $first: "$idCompany" },
        name: { $first: "$name" },
        description: { $first: "$description" },
        juegos: { $push: "$juegos" }
      }
    },
    {
      $project: {
        _id: 0,
        idCompany: 1,
        name: 1,
        description: 1,
        juegos: { $slice: ["$juegos", limit] }
      }
    }
  ]).toArray();
}


```
Ejecutar 
```js
// Llama a la función con la cantidad de juegos que deseas
Consulta_6_getTopGamesByCompany(10);
```