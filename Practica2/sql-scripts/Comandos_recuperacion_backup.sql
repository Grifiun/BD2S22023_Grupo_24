-- Delete From Tables
DELETE FROM HABITACION;
DELETE FROM PACIENTE;
DELETE FROM LOG_ACTIVIDAD;
DELETE FROM LOG_HABITACION;

-- Select Tablas
SELECT * FROM HABITACION LIMIT 10;
SELECT * FROM PACIENTE LIMIT 10;
SELECT * FROM LOG_ACTIVIDAD ORDER BY id_log_actividad DESC LIMIT 10;
SELECT * FROM LOG_HABITACION ORDER BY timestampx DESC LIMIT 10;

-- Select Counts Tablas
SELECT COUNT(*) FROM HABITACION;
SELECT COUNT(*) FROM PACIENTE;
SELECT COUNT(*) FROM LOG_ACTIVIDAD;
SELECT COUNT(*) FROM LOG_HABITACION;

-- Full Backups
time mysql -u root -p Practica2 < /backups/full_backup_habitacion_dia1.sql
time mysql -u root -p Practica2 < /backups/full_backup_paciente_dia2.sql
time mysql -u root -p Practica2 < /backups/full_backup_log_actividad_dia3.sql
time mysql -u root -p Practica2 < /backups/full_backup_log_actividad_dia4.sql  
time mysql -u root -p Practica2 < /backups/full_backup_log_habitacion_dia5.sql

-- Incrementales
time mysql -u root -p Practica2 < /backups/backup_incremental_habitacion_dia1.sql
time mysql -u root -p Practica2 < /backups/backup_incremental_paciente_dia2.sql
time mysql -u root -p Practica2 < /backups/backup_incremental_log_actividad_dia3.sql
time mysql -u root -p Practica2 < /backups/backup_incremental_log_actividad_dia4.sql / Revisar si está puesto como -> CREATE TABLE IF NOT EXISTS `LOG_ACTIVIDAD` -> Controlar IF NOT EXISTS 
time mysql -u root -p Practica2 < /backups/backup_incremental_log_habitacion_dia5.sql
