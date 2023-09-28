import fetch from 'node-fetch'; // Importa el módulo fetch
import { writeFileSync, existsSync } from 'fs';
import {apiKey, accessToken} from '.env'

// URL de la API de IGDB para obtener empresas
const apiUrl = 'https://api.igdb.com/v4/games';
const apiUrlLanguages = 'https://api.igdb.com/v4/languages';
const apiUrlLanguageSupportType = 'https://api.igdb.com/v4/language_support_types';
const apiUrlLanguageSupport = 'https://api.igdb.com/v4/language_supports';
const apiUrlGenres = 'https://api.igdb.com/v4/genres';
const apiUrlPlatforms = 'https://api.igdb.com/v4/platforms';

// Encabezados para la solicitud HTTP
const headers = {
  'Client-ID': `${apiKey}`,
  'Authorization': `Bearer ${accessToken}`,
  'Accept': 'application/json',
};

const gameFieldsMapping = {
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
};

const languageMapping = {
	'idLanguage': 'id',
	'nameLanguage': 'name',
	'nativeName': 'native_name'
}
const fieldslanguage = "fields id, name, native_name;" ;

const languageSupportTypeMapping = {
	'idLanguageSupportType': 'id',
	'name': 'name'
}

const fieldslanguageSupportType = "fields id, name" ;

const languageSupportMapping = {
	'idGame': 'game',
	'idLanguage': 'language',
	'idLanguageSupportType': 'language_support_type'
}
const fieldslanguageSupport = "fields id, game, language, language_support_type;" ;

const genresMapping = {
	'idGenre' : 'id',
	'nameTheme': 'name'
}
const fieldsGenres = "fields id, name;" ;

const platformMapping = {
  'idPlatform': 'id' ,
  'namePlatform': 'name'
}

const fieldsPlatforms = "fields id, name;";
//table: "Language, LanguageGame, LanguageSupportType, Genre, GameGenre"

//Body
//var body = `fields ${fields.join(', ')};`;
//console.log (body);

// Nombre del archivo CSV
console.log();

async function fetchData(startId) {
  try {
    // Define los límites numéricos (sin comillas)
    const lowerLimit = startId - 500;
    const upperLimit = startId;

    // Crea la cláusula WHERE utilizando los límites
    const whereClause = `where id >= ${lowerLimit}`;
    
    // Crea el cuerpo de la solicitud incluyendo la cláusula WHERE
    const body = `fields id, name; ${whereClause};  limit 500; sort id asc;`;
    const response = await fetch(apiUrlPlatforms, {
      method: 'POST',
      headers: headers,
      body: body
    });

    if (!response.ok) {
      console.log("Reintentando ....");
      setTimeout(() => {
        fetchData(startId); // Reintenta con el mismo startId
      }, 2000); // Espera 5 segundos antes de la siguiente solicitud
      
    } else {
      const data = await response.json();
      console.log(data[0].id, " hasta ", data[data.length - 1].id);
      
      if (data.length > 0) {
        // Imprime los datos en la consola
        //console.log("Obteniendo datos de ID:", startId, " hacia ", (startId - 500));
        // Escribe los datos en el archivo CSV
        await writeCSV('platform', platformMapping, 'Platform', data);
        
        // Incrementa el valor de startId para la siguiente iteración
        startId += 500;
        if(data[data.length - 1].id > startId){
          startId = data[data.length - 1].id;
        }
        
        // Llama a fetchData nuevamente después de un segundo (puedes ajustar el tiempo)
        setTimeout(() => {
          fetchData(startId);
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


async function writeCSV(csvFileName, fieldsMapping, nombreTabla, data) {
  try {
    const SQLcsvFileName = "SQL_" + csvFileName + ".sql";
    const keys = Object.keys(fieldsMapping);
    const values = Object.values(fieldsMapping);
    
    const columns = keys.join(', '); // Concatena los nombres de las columnas
    // Agrega comillas simples a los nombres de las columnas
    const columnsSQL = keys.map(key => `'${key}'`).join(', ');
    const placeholders = keys.map(() => '?').join(', '); // Crea marcadores de posición para los valores

    // Verifica si el archivo CSV ya existe
    const fileExists = existsSync(csvFileName);

    if (!fileExists) {
      // Si el archivo CSV no existe, crea el encabezado
      const header = columns + '\n';
      writeFileSync(csvFileName + ".csv", header, 'utf-8');
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
          if (field.toLowerCase().includes("date")) {
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
            }
          }catch(err){

          }

          return `"${valField}"`;
        });

        const query = `INSERT INTO ${nombreTabla} (${columns}) VALUES (${values.join(', ')});`;
        return query;
      });

      // Escribe las sentencias SQL en el archivo
      const sqlData = sqlQueries.join('\n');
      writeFileSync(SQLcsvFileName, "\n" + sqlData, { flag: 'a' });
      //console.log('Datos guardados en el archivo SQL. ' + SQLcsvFileName);

    }
  } catch (error) {
    console.error('Ocurrió un error al intentar registrar en el archivo: ', csvFileName, " Error: ", error);
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

fetchData(500);
