
------------------------------------------------ SET MODE
SET GLOBAL sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));

SELECT @@sql_mode;
SET sql_mode = 'STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';
SELECT @@sql_mode;

------------------------------------------------ VIEWS
SELECT TABLE_NAME, VIEW_DEFINITION
FROM INFORMATION_SCHEMA.VIEWS
WHERE TABLE_SCHEMA = 'mydb';

+------------------------------------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| TABLE_NAME                         | VIEW_DEFINITION                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
+------------------------------------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Consulta_1_Top100JuegosPorRating   | select row_number() OVER (ORDER BY `G`.`totalRating` desc )  AS `Top`,`G`.`name` AS `Nombre`,group_concat(distinct `P`.`namePlatform` order by `P`.`namePlatform` ASC separator ', ') AS `Plataforma`,coalesce(`G`.`totalRating`,0) AS `Rating`,coalesce(`G`.`totalRatingCount`,0) AS `Cantidad_de_calificaciones`,group_concat(distinct `GR`.`nameTheme` order by `GR`.`nameTheme` ASC separator ', ') AS `Genero` from ((((`mydb`.`Game` `G` join `mydb`.`PlatformGame` `PG` on((`G`.`idGame` = `PG`.`idGame`))) join `mydb`.`Platform` `P` on((`PG`.`idPlatform` = `P`.`idPlatform`))) join `mydb`.`GameGenre` `GG` on((`G`.`idGame` = `GG`.`idGame`))) join `mydb`.`Genre` `GR` on((`GG`.`idGenre` = `GR`.`idGenre`))) group by `G`.`name`,`G`.`totalRating` order by `G`.`totalRating` desc limit 100 |
| Consulta_4_Top100JuegosConLanguage | select row_number() OVER (ORDER BY `G`.`rating` desc,`G`.`name` )  AS `Top`,`G`.`name` AS `NombreDelJuego`,`G`.`rating` AS `Rating`,count(distinct `LG`.`idLanguage`) AS `CantidadDeIdiomasSoportados`,group_concat(distinct `L`.`nameLanguage` order by `L`.`nameLanguage` ASC separator ', ') AS `Idiomas_Soportados` from (((`mydb`.`Game` `G` join `mydb`.`LanguageGame` `LG` on((`G`.`idGame` = `LG`.`idGame`))) join `mydb`.`Language` `L` on((`LG`.`idLanguage` = `L`.`idLanguage`))) join `mydb`.`LanguageSupportType` `LST` on((`LG`.`idLanguageSupportType` = `LST`.`idLanguageSupportType`))) where (`LST`.`name` in ('Audio','Subtitles')) group by `G`.`name`,`G`.`rating` order by `G`.`rating` desc,`G`.`name` limit 100                                                                    |
+------------------------------------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+

-- ----------------------------------------------consulta 1 --------------------------------------------------------

CREATE VIEW Consulta_1_Top100JuegosPorRating AS
SELECT 
    row_number() OVER (ORDER BY `G`.`totalRating` DESC )  AS `Top`,
    `G`.`name` AS `Nombre`,
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

SELECT
    G.name AS Nombre,
    P.namePlatform AS Plataforma,
    G.totalRating AS Rating,
    GR.nameTheme AS Genero
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
ORDER BY
    G.totalRating DESC
LIMIT 100;

SELECT
    ROW_NUMBER() OVER (ORDER BY G.totalRating DESC) AS Numerador,
    G.name AS Nombre,
    GROUP_CONCAT(DISTINCT P.namePlatform ORDER BY P.namePlatform ASC SEPARATOR ', ') AS Plataforma,
    G.totalRating AS Rating,
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
GROUP BY
    G.name, G.totalRating
ORDER BY
    G.totalRating DESC
LIMIT 100;


-- EJECUTAR
SELECT * FROM Consulta_1_Top100JuegosPorRating;

-- ----------------------------------------------consulta 2 --------------------------------------------------------

DELIMITER //

CREATE PROCEDURE BuscarJuegosPorNombre(IN nombreJuego VARCHAR(255))
BEGIN
    SELECT
        G.name AS Nombre,
        P.namePlatform AS Plataforma,
        G.rating AS Rating,
        GG.nameTheme AS Género
    FROM
        Game AS G
    JOIN
        PlatformGame AS PG ON G.idGame = PG.idGame
    JOIN
        Platform AS P ON PG.idPlatform = P.idPlatform
    JOIN
        GameGenre AS GG ON G.idGame = GG.idGame
    WHERE
        G.name LIKE CONCAT('%', nombreJuego, '%');
END //

DELIMITER ;


-- para ver 

CALL BuscarJuegosPorNombre('nombre_del_juego');


-- ----------------------------------------------consulta 3 --------------------------------------------------------

DELIMITER //
DROP PROCEDURE IF EXISTS Consulta_3_BuscarInfoPorJuego;
CREATE PROCEDURE Consulta_3_BuscarInfoPorJuego(IN param VARCHAR(255))
BEGIN
    SELECT
        G.idGame AS Id,
        G.name AS Nombre_Juego,
        G.summary AS Resumen,
        G.storyline AS Sinopsis,
        P.namePlatform AS Plataforma,
        COALESCE(G.totalRating, 0) AS Rating_Total,
        COALESCE(G.rating, 0) AS Rating_Usuarios,
        COALESCE(G.aggregatedRating, 0) AS Rating_Critica,
        GROUP_CONCAT(DISTINCT GR.nameTheme ORDER BY GR.nameTheme ASC SEPARATOR ', ') AS Genero,
        S.idStatus AS Estado
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
        Estado;
END //
DELIMITER ;


-- para ver

CALL Consulta_3_BuscarInfoPorJuego('nombre_del_juego');

-- ----------------------------------------------consulta 4 --------------------------------------------------------
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

-- ----------------------------------------------consulta 5 --------------------------------------------------------


SELECT
    G.name AS NombreJuego,
    GG.nameTheme AS Genero,
    G.rating AS Rating
FROM
    Game AS G
JOIN
    GameGenre AS GG ON G.idGame = GG.idGame
ORDER BY
    Genero,
    Rating DESC
LIMIT 100;


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

