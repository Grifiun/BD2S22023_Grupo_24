CREATE DATABASE Practica2;

SHOW DATABASES;

USE Practica2;

CREATE TABLE LOG_ACTIVIDAD (
	id_log_actividad INT auto_increment PRIMARY KEY,
    timestampx VARCHAR(100),
    actividad VARCHAR(500),
    PACIENTE_idPaciente INT,
    HABITACION_idHabitacion INT
);

SELECT * FROM LOG_ACTIVIDAD;
SELECT COUNT(*) FROM LOG_ACTIVIDAD;

CREATE TABLE HABITACION (
idHabitacion INT auto_increment primary KEY,
Habitacion varchar(50)
);

SELECT * FROM HABITACION;
SELECT COUNT(*) FROM HABITACION;

CREATE TABLE PACIENTE(
	idPaciente INT auto_increment primary key,
    edad int,
    genero varchar(20)
);

SELECT * FROM PACIENTE;
SELECT COUNT(*) FROM PACIENTE;

CREATE TABLE LOG_HABITACION(
	timestampx varchar(100) PRIMARY KEY,
    statusx VARCHAR(50),
    idHabitacion INT
);

SELECT * FROM LOG_HABITACION;
SELECT COUNT(*) FROM LOG_HABITACION;

ALTER TABLE LOG_ACTIVIDAD
ADD CONSTRAINT fk_log_actividad_paciente
foreign key (PACIENTE_idPaciente)
REFERENCES PACIENTE(idPaciente)
ON DELETE CASCADE;

ALTER TABLE LOG_ACTIVIDAD
ADD CONSTRAINT fk_habitacion_log_actividad
foreign key (HABITACION_idHabitacion)
REFERENCES HABITACION(idHabitacion)
ON DELETE CASCADE;

ALTER TABLE LOG_HABITACION
ADD CONSTRAINT fk_habitacion_log_habitacion
foreign key (idHabitacion)
REFERENCES HABITACION(idHabitacion)
ON DELETE CASCADE;


-- Sintaxis para un full backup
-- mysqldump -u [usuario] -p [nombre_de_la_base_de_datos] > C:\ruta\al\directorio\full_backup_dia#.sql


-- Sintaxis para un backup incremental
-- mysqldump -u [usuario] -p [nombre_de_la_base_de_datos] [nombre_de_la_tabla] > C:\ruta\al\directorio\incremental_backup_dia#.sql
-- mysqldump -u [usuario] -p [nombre_de_la_base_de_datos] [nombre_de_la_tabla] -where="fecha_modificacion > '2023-01-01 00:00:00'"  > C:\ruta\al\directorio\incremental_backup_dia#.sql
