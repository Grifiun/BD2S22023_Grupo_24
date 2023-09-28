-- ----------------------------------------------consulta 1 --------------------------------------------------------

CREATE VIEW Top100JuegosPorRating AS
SELECT
    G.name AS Nombre,
    P.namePlatform AS Plataforma,
    G.rating AS Rating,
    GG.nameTheme AS Genero
FROM
    Game AS G
JOIN
    PlatformGame AS PG ON G.idGame = PG.idGame
JOIN
    Platform AS P ON PG.idPlatform = P.idPlatform
JOIN
    GameGenre AS GG ON G.idGame = GG.idGame
ORDER BY
    G.rating DESC
LIMIT 100;



--para ver
SELECT * FROM Top100JuegosPorRating;


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

CREATE PROCEDURE BuscarInfoPorJuego(IN nombreJuego VARCHAR(255))
BEGIN
    SELECT
        G.name AS NombreJuego,
        P.namePlatform AS Plataforma,
        G.rating AS Rating,
        GG.nameTheme AS Genero
    FROM
        Game AS G
    JOIN
        PlatformGame AS PG ON G.idGame = PG.idGame
    JOIN
        Platform AS P ON PG.idPlatform = P.idPlatform
    JOIN
        GameGenre AS GG ON G.idGame = GG.idGame
    WHERE
        G.name = nombreJuego
    ORDER BY
        Plataforma;
END //

DELIMITER ;


-- para ver

CALL BuscarInfoPorJuego('nombre_del_juego');

-- ----------------------------------------------consulta 4 --------------------------------------------------------

CREATE VIEW TopJuegosPorSoporteDeIdiomas AS
SELECT
    G.idGame,
    G.name AS NombreDelJuego,
    G.rating,
    GROUP_CONCAT(L.nameLanguage ORDER BY L.nameLanguage ASC) AS IdiomasCompatibles
FROM
    Game G
JOIN
    LanguageGame LG ON G.idGame = LG.idGame
JOIN
    Language L ON LG.idLanguage = L.idLanguage
GROUP BY
    G.idGame
ORDER BY
    G.rating DESC, G.name ASC
LIMIT 100;


--para ver

SELECT * FROM TopJuegosPorSoporteDeIdiomas



--------- por si no funciona la anterior


CREATE VIEW TopJuegosPorSoporteDeIdiomas AS
SELECT
    G.idGame,
    G.name AS NombreDelJuego,
    G.rating,
    (
        SELECT GROUP_CONCAT(L.nameLanguage ORDER BY L.nameLanguage ASC)
        FROM LanguageGame LG
        JOIN Language L ON LG.idLanguage = L.idLanguage
        WHERE LG.idGame = G.idGame
    ) AS IdiomasCompatibles
FROM
    Game G
ORDER BY
    G.rating DESC, G.name ASC
LIMIT 100;


--para ver

SELECT * FROM TopJuegosPorSoporteDeIdiomas;



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


