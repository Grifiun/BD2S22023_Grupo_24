# Consultas de MySQL
### Set Global sql mode
```sql
SET GLOBAL sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));
SET GLOBAL sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));
```
### Ver procedures

Ver de 1 en 1
```sql
SHOW PROCEDURE STATUS;
SHOW CREATE PROCEDURE Consulta_2_BuscarJuegosPorNombre;
```
Ver todos
```sql
SELECT
  ROUTINE_NAME AS 'Nombre del Procedimiento',
  ROUTINE_DEFINITION AS 'Definición del Procedimiento'
FROM
  information_schema.ROUTINES
WHERE
  ROUTINE_SCHEMA = 'mydb'
  AND ROUTINE_TYPE = 'PROCEDURE';
```
### Ver Views
```sql
SHOW FULL TABLES IN nombre_de_la_base_de_datos WHERE TABLE_TYPE LIKE 'VIEW';
SHOW CREATE VIEW nombre_de_la_vista;
```

## Consulta 1: Consulta_1_Top100JuegosPorRating
```sql
CREATE VIEW Consulta_1_Top100JuegosPorRating AS
SELECT 
    row_number() OVER (ORDER BY `G`.`totalRating` DESC )  AS `Top`,`G`.`name` AS `Nombre`,
    group_concat(DISTINCT `P`.`namePlatform` ORDER BY `P`.`namePlatform` ASC separator ', ') AS `Plataforma`,
    coalesce(`G`.`totalRating`,0) AS `Rating`,
    coalesce(`G`.`totalRatingCount`,0) AS `Cantidad_de_calificaciones`,
    group_concat(DISTINCT `GR`.`nameTheme` ORDER BY `GR`.`nameTheme` ASC separator ', ') AS `Genero` 
FROM ((((`mydb`.`Game` `G` 
JOIN `mydb`.`PlatformGame` `PG` ON((`G`.`idGame` = `PG`.`idGame`))) 
JOIN `mydb`.`Platform` `P` ON((`PG`.`idPlatform` = `P`.`idPlatform`))) 
JOIN `mydb`.`GameGenre` `GG` ON((`G`.`idGame` = `GG`.`idGame`))) 
JOIN `mydb`.`Genre` `GR` ON((`GG`.`idGenre` = `GR`.`idGenre`))) 
GROUP BY `G`.`name`,`G`.`totalRating` 
ORDER BY `G`.`totalRating` 
DESC LIMIT 100;
```

Ejecutar
```sql
SELECT * FROM Consulta_1_Top100JuegosPorRating;
```

## Consulta 2: Consulta_2_BuscarJuegosPorNombre
```sql
DELIMITER //
DROP PROCEDURE IF EXISTS Consulta_2_BuscarJuegosPorNombre;
CREATE DEFINER=`root`@`localhost` PROCEDURE `Consulta_2_BuscarJuegosPorNombre`(IN nombreJuego VARCHAR(255), IN limite INT)
BEGIN
    SELECT
        G.name AS Nombre,
        GROUP_CONCAT(DISTINCT P.namePlatform ORDER BY P.namePlatform ASC SEPARATOR ', ') AS Plataforma,
        COALESCE(G.totalRating, 0) AS Rating,
        COALESCE(G.totalRatingCount, 0) AS Cantidad_de_calificaciones,
        GROUP_CONCAT(DISTINCT GR.nameTheme ORDER BY GR.nameTheme ASC SEPARATOR ', ') AS Genero
    FROM
        Game AS G
    JOIN
        PlatformGame AS PG ON G.idGame = PG.idGame
    JOIN
        Platform AS P ON PG.idPlatform = P.idPlatform
    JOIN
        GameGenre AS GG ON G.idGame = GG.idGame
    JOIN 
        Genre AS GR ON GG.idGenre = GR.idGenre
    WHERE
        G.name LIKE CONCAT('%', nombreJuego, '%')
    GROUP BY
        G.name, G.totalRating
    ORDER BY
        G.name ASC
    LIMIT limite;
END //
DELIMITER ;

```

Ejecutar
```sql
CALL Consulta_2_BuscarJuegosPorNombre('nombre_del_juego', 100);
```

## Consulta 3
Consulta_3_BuscarInfoPorJuego 
``` sql
DELIMITER //
DROP PROCEDURE IF EXISTS Consulta_3_BuscarInfoPorJuego;
CREATE DEFINER=`root`@`localhost` PROCEDURE `Consulta_3_BuscarInfoPorJuego`(IN param VARCHAR(255))
BEGIN
    SELECT
G.idGame AS Id,
        G.name AS Nombre_Juego,        
        P.namePlatform AS Plataforma,
        COALESCE(G.totalRating, 0) AS Rating_Total,
        COALESCE(G.rating, 0) AS Rating_Usuarios,
        COALESCE(G.aggregatedRating, 0) AS Rating_Critica,
        GROUP_CONCAT(DISTINCT GR.nameTheme ORDER BY GR.nameTheme ASC SEPARATOR ', ') AS Genero,
        COALESCE(G.summary, '---') AS Resumen,
        COALESCE(G.storyline, '---') AS Sinopsis,
        S.nameStatus AS Estado
    FROM
        Game AS G
    JOIN
        PlatformGame AS PG ON G.idGame = PG.idGame
    JOIN 
        Platform AS P ON PG.idPlatform = P.idPlatform
    JOIN
        GameGenre AS GG ON G.idGame = GG.idGame
    JOIN 
		Genre AS GR ON GG.idGenre = GR.idGenre
	JOIN
		GameStatus AS S ON G.idStatus = S.idGameStatus
    WHERE
        G.name LIKE CONCAT('%', param, '%') OR G.idGame = param
    ORDER BY
        Plataforma;
END //
DELIMITER ;
```

Ejecutar
```sql
CALL Consulta_3_BuscarInfoPorJuego('nombre_del_juego');
```

## Consulta 4: Consulta_4_Top100JuegosConLanguage
```sql
DROP VIEW IF EXISTS Consulta_4_Top100JuegosConLanguage;
CREATE VIEW Consulta_4_Top100JuegosConLanguage AS
SELECT
    G.name AS NombreDelJuego,
    G.rating AS Rating,
    COUNT(DISTINCT LG.idLanguage) AS CantidadDeIdiomasSoportados,
    GROUP_CONCAT(DISTINCT L.nameLanguage ORDER BY L.nameLanguage ASC SEPARATOR ', ') AS SupportedLanguages
FROM
    Game AS G
JOIN
    LanguageGame AS LG ON G.idGame = LG.idGame
JOIN
    Language AS L ON LG.idLanguage = L.idLanguage
JOIN
    LanguageSupportType AS LST ON LG.idLanguageSupportType = LST.idLanguageSupportType
WHERE
    LST.name IN ('Audio', 'Subtitles')
GROUP BY
    G.name, G.rating
ORDER BY
    G.rating DESC, G.name ASC
LIMIT 100;
```

Ejecutar
```sql
SELECT * FROM Consulta_4_Top100JuegosConLanguage;
```

## Consulta 5: Consulta_6_MejorJuegoPorGenero
```sql
DELIMITER //
DROP PROCEDURE IF EXISTS Consulta_6_MejorJuegoPorGenero;
CREATE PROCEDURE Consulta_6_MejorJuegoPorGenero()
BEGIN
    CREATE TEMPORARY TABLE TempBestGamesByGenre AS (
        SELECT
            GR.nameTheme AS Genero,
            G.idGame AS JuegoId,
            G.name AS NombreJuego,
            MAX(COALESCE(G.totalRating, 0)) AS MaxRating
        FROM
            Game AS G
        JOIN
            GameGenre AS GG ON G.idGame = GG.idGame
        JOIN 
            Genre AS GR ON GG.idGenre = GR.idGenre
        WHERE
            G.totalRating IS NOT NULL
        GROUP BY
            GR.nameTheme
    );

    SELECT
        Genero,
        NombreJuego,
        MaxRating AS Rating
    FROM
        TempBestGamesByGenre;
        
    DROP TEMPORARY TABLE TempBestGamesByGenre;
END //
DELIMITER ;
```
Ejecutar
```sql
SELECT * FROM Consulta_6_MejorJuegoPorGenero;
```