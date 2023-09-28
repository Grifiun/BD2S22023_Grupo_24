USE mydb;

-- Inserción de datos en la tabla Category
INSERT INTO `mydb`.`Category` (`idCategory`, `nameCategory`)
VALUES
  (0, 'main_game'),
  (1, 'dlc_addon'),
  (2, 'expansion'),
  (3, 'bundle'),
  (4, 'standalone_expansion'),
  (5, 'mod'),
  (6, 'episode'),
  (7, 'season'),
  (8, 'remake'),
  (9, 'remaster'),
  (10, 'expanded_game'),
  (11, 'port'),
  (12, 'fork'),
  (13, 'pack'),
  (14, 'update');
  
  
 -- Inserción de datos en la tabla GameStatus
INSERT INTO `mydb`.`GameStatus` (`idGameStatus`, `nameStatus`)
VALUES
  (0, 'released'),
  (2, 'alpha'),
  (3, 'beta'),
  (4, 'early_access'),
  (5, 'offline'),
  (6, 'cancelled'),
  (7, 'rumored'),
  (8, 'delisted');
  
 -- Inserción de datos en la tabla Language

INSERT INTO Language (idLanguage, nameLanguage, nativeName) VALUES ("1", "Arabic", "العربية");
INSERT INTO Language (idLanguage, nameLanguage, nativeName) VALUES ("2", "Chinese (Simplified)", "简体中文");
INSERT INTO Language (idLanguage, nameLanguage, nativeName) VALUES ("3", "Chinese (Traditional)", "繁體中文");
INSERT INTO Language (idLanguage, nameLanguage, nativeName) VALUES ("4", "Czech", "čeština");
INSERT INTO Language (idLanguage, nameLanguage, nativeName) VALUES ("5", "Danish", "Dansk");
INSERT INTO Language (idLanguage, nameLanguage, nativeName) VALUES ("6", "Dutch", "Nederlands");
INSERT INTO Language (idLanguage, nameLanguage, nativeName) VALUES ("7", "English", "English (US)");
INSERT INTO Language (idLanguage, nameLanguage, nativeName) VALUES ("8", "English (UK)", "English (UK)");
INSERT INTO Language (idLanguage, nameLanguage, nativeName) VALUES ("9", "Spanish (Spain)", "Español (España)");
INSERT INTO Language (idLanguage, nameLanguage, nativeName) VALUES ("10", "Spanish (Mexico)", "Español (Mexico)");
INSERT INTO Language (idLanguage, nameLanguage, nativeName) VALUES ("11", "Finnish", "Suomi");
INSERT INTO Language (idLanguage, nameLanguage, nativeName) VALUES ("12", "French", "Français");
INSERT INTO Language (idLanguage, nameLanguage, nativeName) VALUES ("13", "Hebrew", "עברית");
INSERT INTO Language (idLanguage, nameLanguage, nativeName) VALUES ("14", "Hungarian", "Magyar");
INSERT INTO Language (idLanguage, nameLanguage, nativeName) VALUES ("15", "Italian", "Italiano");
INSERT INTO Language (idLanguage, nameLanguage, nativeName) VALUES ("16", "Japanese", "日本語");
INSERT INTO Language (idLanguage, nameLanguage, nativeName) VALUES ("17", "Korean", "한국어");
INSERT INTO Language (idLanguage, nameLanguage, nativeName) VALUES ("18", "Norwegian", "Norsk");
INSERT INTO Language (idLanguage, nameLanguage, nativeName) VALUES ("19", "Polish", "Polski");
INSERT INTO Language (idLanguage, nameLanguage, nativeName) VALUES ("20", "Portuguese (Portugal)", "Português (Portugal)");
INSERT INTO Language (idLanguage, nameLanguage, nativeName) VALUES ("21", "Portuguese (Brazil)", "Português (Brasil)");
INSERT INTO Language (idLanguage, nameLanguage, nativeName) VALUES ("22", "Russian", "Русский");
INSERT INTO Language (idLanguage, nameLanguage, nativeName) VALUES ("23", "Swedish", "Svenska");
INSERT INTO Language (idLanguage, nameLanguage, nativeName) VALUES ("24", "Turkish", "Türkçe");
INSERT INTO Language (idLanguage, nameLanguage, nativeName) VALUES ("25", "Thai", "ไทย");
INSERT INTO Language (idLanguage, nameLanguage, nativeName) VALUES ("26", "Vietnamese", "Tiếng Việt");
INSERT INTO Language (idLanguage, nameLanguage, nativeName) VALUES ("27", "German", "Deutsch");
INSERT INTO Language (idLanguage, nameLanguage, nativeName) VALUES ("28", "Ukrainian", "українська");

  
 -- Inserción de datos en la tabla Language
INSERT INTO LanguageSupportType (idLanguageSupportType, name) VALUES ("1", "Audio");
INSERT INTO LanguageSupportType (idLanguageSupportType, name) VALUES ("2", "Subtitles");
INSERT INTO LanguageSupportType (idLanguageSupportType, name) VALUES ("3", "Interface");


