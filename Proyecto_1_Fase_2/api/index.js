import fetch from 'node-fetch'; // Importa el módulo fetch
import { writeFileSync, existsSync } from 'fs';
import {apiKey, accessToken} from '.env'
const endpoints = {
  game: {
    url: 'https://api.igdb.com/v4/games',
    fieldsMapping: {
      'idGame': 'id',
      'name': 'name',
      'summary': 'summary',
      'storyline': 'storyline',
      'rating': 'rating',
      'ratingCount': 'rating_count',
      'aggregatedRating': 'aggregated_rating',
      'aggregatedRatingCount': 'aggregated_rating_count',
      'totalRating': 'total_rating',
      'totalRatingCount': 'total_rating_count',
      'firstReleaseDate': 'first_release_date',
      'keywords': 'keywords',
      'screenshots': 'screenshots',
      'videos': 'videos',
      'coverImage': 'cover',
      'artworks': 'artworks',
      'websites': 'websites',
      'parentGame': 'parent_game',
      'idStatus': 'status',
      'idCategory': 'category',
    },
    fieldsName: "fields id, name, summary, storyline, rating, rating_count, aggregated_rating, aggregated_rating_count, total_rating, total_rating_count, first_release_date, keywords, screenshots, videos, cover, artworks, websites, parent_game, status, category;",
    tableName: "Game"
  },
  language: {
    url: 'https://api.igdb.com/v4/languages',
    fieldsMapping: {
      'idLanguage': 'id',
      'nameLanguage': 'name',
      'nativeName': 'native_name',
    },
    fieldsName: "fields id, name, native_name;",
    tableName: "Language"
  },
  languageSupportTypes: {
    url: 'https://api.igdb.com/v4/language_support_types',
    fieldsMapping: {
      'idLanguageSupportType': 'id',
      'name': 'name',
    },
    fieldsName: "fields id, name;",
    tableName: "LanguageSupportTypes"
  },
  languageSupport: {
    url: 'https://api.igdb.com/v4/language_supports',
    fieldsMapping: {
      'idGame': 'game',
      'idLanguage': 'language',
      'idLanguageSupportType': 'language_support_type',
    },
    fieldsName: "fields id, game, language, language_support_type;",
    tableName: "LanguageSupport"
  },
  genre: {
    url: 'https://api.igdb.com/v4/genres',
    fieldsMapping: {
      'idGenre': 'id',
      'nameTheme': 'name',
    },
    fieldsName: "fields id, name;",
    tableName: "Genre"
  },
  platforms: {
    url: 'https://api.igdb.com/v4/platforms',
    fieldsMapping: {
      'idPlatform': 'id',
      'namePlatform': 'name',
    },
    fieldsName: "fields id, name;",
    tableName: "Platform"
  },
  company: {
    url: 'https://api.igdb.com/v4/companies',
    fieldsMapping: {
      'idCompany': 'id',
      'name': 'name',
      'description': 'description',
      'country': 'country',
      'established': 'start_date', // Asegúrate de convertir el formato de fecha adecuadamente
      'website': 'url',
    },
    fieldsName: "fields id, name, description, country, start_date, url;",
    tableName: 'Company'
  },
  involvedCompanies: {
    url: 'https://api.igdb.com/v4/involved_companies',
    fieldsMapping: {
      'idCompany': 'company',
      'idGame': 'game',
      'developer': 'developer',
      'porting': 'porting',
      'publisher': 'publisher',
      'supporting': 'supporting'
    },
    fieldsName: "fields company, game, developer, porting, publisher, supporting; ",
    tableName: "InvolvedCompanies"
  }
  // Puedes agregar más entidades aquí siguiendo el mismo patrón
};
// Encabezados para la solicitud HTTP
const headers = {
  'Client-ID': `${apiKey}`,
  'Authorization': `Bearer ${accessToken}`,
  'Accept': 'application/json',
};

//recibe startOD que indica desde donde comenzará
// recibe endpoint que es un objeto que contiene url, fieldsMapping y fieldsName
async function fetchData(startId, endpoint) {
  try {
    //console.log(JSON.stringify(endpoint));

    // Define los límites numéricos (sin comillas)
    const lowerLimit = startId - 500;
    const upperLimit = startId;

    // Crea la cláusula WHERE utilizando los límites
    const whereClause = `where id >= ${lowerLimit}`;
    
    // Crea el cuerpo de la solicitud incluyendo la cláusula WHERE
   
    const body = `${endpoint.fieldsName} ${whereClause};  limit 500; sort id asc;`;
    const response = await fetch(endpoint.url, {
      method: 'POST',
      headers: headers,
      body: body
    });

    if (!response.ok) {
      console.log("Reintentando ....");
      setTimeout(() => {
        fetchData(startId, endpoint); // Reintenta con el mismo startId
      }, 2000); // Espera 5 segundos antes de la siguiente solicitud
      
    } else {
      const data = await response.json();
      console.log(data[0].id, " hasta ", data[data.length - 1].id);
      
      if (data.length > 0) {
        // Imprime los datos en la consola
        //console.log("Obteniendo datos de ID:", startId, " hacia ", (startId - 500));
        // Escribe los datos en el archivo CSV
        await writeCSV(endpoint.tableName, endpoint.fieldsMapping, data);
        
        // Incrementa el valor de startId para la siguiente iteración
        startId += 500;
        if(data[data.length - 1].id > startId){
          startId = data[data.length - 1].id;
        }
        
        // Llama a fetchData nuevamente después de un segundo (puedes ajustar el tiempo)
        setTimeout(() => {
          fetchData(startId, endpoint);
        }, 300); // Espera 1 segundo antes de la siguiente solicitud
      } else {
        console.log('Fin de la obtención de datos.');
        return;
      }
    }
  } catch (error) {
    console.error('Error:', error);
    console.log("Reintentando ....");
    setTimeout(() => {
      fetchData(startId); // Reintenta con el mismo startId
    }, 2000); // Espera 5 segundos antes de la siguiente solicitud
  }
}


async function writeCSV(tableName, fieldsMapping, data) {
  try {
    const SQLcsvFileName = "SQL_" + tableName + ".sql";
    const keys = Object.keys(fieldsMapping);
    const values = Object.values(fieldsMapping);
    
    const columns = keys.join(', '); // Concatena los nombres de las columnas
    // Agrega comillas simples a los nombres de las columnas
    const columnsSQL = keys.map(key => `'${key}'`).join(', ');
    const placeholders = keys.map(() => '?').join(', '); // Crea marcadores de posición para los valores

    // Verifica si el archivo CSV ya existe
    const fileExists = existsSync(tableName);

    if (!fileExists) {
      // Si el archivo CSV no existe, crea el encabezado
      const header = columns + '\n';
      writeFileSync(tableName + ".csv", header, 'utf-8');
    }

    if (data && data.length > 0) {
      // Procesa los datos y escribe en el archivo CSV
      /*
      const csvData = data.map(item => values.map(field => `"${item[field]}"` || '').join(',')).join('\n');
      writeFileSync(csvFileName + ".csv", "\n" + csvData, { flag: 'a' });
      console.log('Datos guardados en el archivo CSV. ' + csvFileName);
      */
      // Procesa los datos y crea sentencias SQL
      const sqlQueries = data.map(item => {
        const validKeys = keys.filter(field => {
          const valField = item[fieldsMapping[field]];
          return valField !== undefined && valField !== "undefined";
        });

        const columns = validKeys.join(', ');
        const values = validKeys.map(field => {
          let valField = item[fieldsMapping[field]];

          // Comprueba si el nombre del campo contiene "date" o "Date"
          if (field.toLowerCase().includes("date") || field.toLowerCase().includes("established")) {
            // Crea una nueva instancia de Date y pasa el Unix Timestamp multiplicado por 1000 para convertirlo de segundos a milisegundos
            const fecha = new Date(valField * 1000);

            // Formatea la fecha como YYYY-MM-DD
            const fechaFormateada = fecha.toISOString().split('T')[0];
            valField = `${fechaFormateada}`;
          }

          // Verifica si valField es una cadena antes de intentar reemplazar las comillas
          try{
            if (typeof valField === 'string') {
              // Reemplaza las comillas dobles por comillas simples
              valField = valField.replace(/"/g, "'");
               // Reemplaza los saltos de línea por espacios en blanco
              valField = valField.replace(/\n/g, ' ');
            }
          }catch(err){

          }

          return `"${valField}"`;
        });
        const query = `INSERT INTO ${tableName} (${columns}) VALUES (${values.join(', ')});`;
        return query;
      });

      // Escribe las sentencias SQL en el archivo
      const sqlData = sqlQueries.join('\n');
      writeFileSync(SQLcsvFileName, "\n" + sqlData, { flag: 'a' });
      //console.log('Datos guardados en el archivo SQL. ' + SQLcsvFileName);

    }
  } catch (error) {
    console.error('Ocurrió un error al intentar registrar en el archivo: ', tableName, " Error: ", error);
  }
}

// Llama a la función para obtener datos
//fetchData(500);

async function writeSQL(fileName, sqlData) {
  try {
    await writeFileSync(fileName, "\n" + sqlData, { flag: 'a' });
    //console.log(`Datos guardados en el archivo SQL: ${fileName}`);
  } catch (error) {
    console.error('Ocurrió un error al intentar registrar en el archivo:', fileName, 'Error:', error);
  }
}

async function processGame(game) {
  // Inserta los géneros en la tabla GameGenre
  if (game.genres && game.genres.length > 0) {
    game.genres.forEach(async (genreId) => {
      const genreGameQuery = `INSERT INTO GameGenre (idGenre, idGame) VALUES (${genreId}, ${game.id});`;
      await writeSQL('GameGenre.sql', genreGameQuery);
    });
  }

  // Inserta las plataformas en la tabla GamePlatform
  if (game.platforms && game.platforms.length > 0) {
    game.platforms.forEach(async (platformId) => {
      const platformGameQuery = `INSERT INTO PlatformGame (idPlatform, idGame) VALUES (${platformId}, ${game.id});`;
      await writeSQL('GamePlatform.sql', platformGameQuery);
    });
  }
}

async function fetchGames(startId) {
  try {
    // Define los límites numéricos (sin comillas)
    const lowerLimit = startId - 500;
    const upperLimit = startId;

    // Crea la cláusula WHERE utilizando los límites
    const whereClause = `where id >= ${lowerLimit}`;
    const body = `fields id, genres, platforms; ${whereClause}; limit 500; sort id asc;`;

    const response = await fetch(apiUrl, {
      method: 'POST',
      headers: headers,
      body: body,
    });

    if (!response.ok) {
      console.log("Reintentando ....");
      setTimeout(() => {
        fetchGames(startId); // Reintenta con el mismo startId
      }, 500); // Espera 2 segundos antes de la siguiente solicitud
    } else {
      const data = await response.json();
      console.log(data[0].id, " hasta ", data[data.length - 1].id);
      if (data.length > 0) {
        // Procesa los juegos
        data.forEach(async (game) => {
          await processGame(game);
        });

        // Incrementa el valor de startId para la siguiente iteración
        startId += 500;
        if(data[data.length - 1].id > startId){
          startId = data[data.length - 1].id;
        }
        // Llama a fetchGames nuevamente después de un segundo (puedes ajustar el tiempo)
        setTimeout(() => {
          fetchGames(startId);
        }, 300); // Espera 1 segundo antes de la siguiente solicitud
      } else {
        console.log('Fin de la obtención de datos.');
      }
    }
  } catch (error) {
    console.error('Error:', error);
    console.log("Reintentando ....");
    setTimeout(() => {
      fetchGames(startId); // Reintenta con el mismo startId
    }, 500); // Espera 2 segundos antes de la siguiente solicitud
  }
}

// fetchData(500, endpoints.game);
// fetchData(500, endpoints.company);
fetchData(500, endpoints.involvedCompanies);
