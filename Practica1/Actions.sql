-- Configura las opciones de SET
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
SET ANSI_PADDING ON;

USE BD2;
GO

-- Trigger: History Log
CREATE TRIGGER HistoryLog1
ON DATABASE
FOR CREATE_PROCEDURE, ALTER_PROCEDURE, DROP_PROCEDURE,
   CREATE_FUNCTION, ALTER_FUNCTION, DROP_FUNCTION,
   CREATE_TABLE, ALTER_TABLE, DROP_TABLE
AS
BEGIN
    DECLARE @eventData XML = EVENTDATA();
    DECLARE @eventType NVARCHAR(100) = @eventData.value('(/EVENT_INSTANCE/EventType)[1]', 'nvarchar(100)');
    DECLARE @objectName NVARCHAR(255) = @eventData.value('(/EVENT_INSTANCE/ObjectName)[1]', 'nvarchar(255)');

    INSERT INTO [practica1].[HistoryLog] (Date, Description)
    VALUES (GETDATE(), @eventType + ' on ' + @objectName);
END;
GO


-------------------------------------- TRANSACCIONES --------------------------------------
-- PR1 --------------------------------------
-- Transaccion
-- Registro de Usuarios
CREATE PROCEDURE [practica1].[PR1]
    @Firstname NVARCHAR(MAX),
    @Lastname NVARCHAR(MAX),
    @Email NVARCHAR(MAX),
    @DateOfBirth DATETIME2,
    @Password NVARCHAR(MAX),    
    @Credits INT
AS
BEGIN    
	BEGIN TRANSACTION;
	BEGIN TRY
		-- Verificar si el usuario ya existe
		IF NOT EXISTS (SELECT 1 FROM [practica1].[Usuarios] WHERE [Email] = @Email)
		BEGIN
			DECLARE @UserId UNIQUEIDENTIFIER;
			DECLARE @TFAStatus BIT = 0; -- Por defecto el TFA esta desactivado
			-- Insertar en la tabla Usuarios y asociar el rol
			INSERT INTO practica1.Usuarios (Id, Firstname, Lastname, Email, DateOfBirth, Password, LastChanges, EmailConfirmed)
			VALUES (NEWID(), @Firstname, @Lastname, @Email, @DateOfBirth, @Password, GETDATE(), 1); -- EmailConfirmed establecido en 1

			SET @UserId = (SELECT Id FROM practica1.Usuarios WHERE Email = @Email);

			-- Asignar rol
			DECLARE @StudentRoleId UNIQUEIDENTIFIER = (SELECT Id FROM practica1.Roles WHERE RoleName = 'Student');
			INSERT INTO practica1.UsuarioRole (RoleId, UserId, IsLatestVersion)
			VALUES (@StudentRoleId, @UserId, 1);

			INSERT INTO practica1.ProfileStudent (UserId, Credits)
			VALUES (@UserId, @Credits);

			-- Registrar TFA si está habilitado
            -- IF @TFAStatus = 1
            BEGIN
                INSERT INTO [practica1].[TFA] ([UserId], [Status], [LastUpdate])
                VALUES (@UserId, @TFAStatus, GETDATE()); -- Se establece el estado TFA como no activo
            END;

            INSERT INTO [practica1].[Notification] ([UserId], [Message], [Date])
            VALUES (@UserId, '¡Bienvenido a nuestro sistema!', GETDATE());
			
			-- Registrar la transacción en el History Log
			INSERT INTO practica1.HistoryLog (Date, Description)
			VALUES (GETDATE(), 'Registro de usuario: ' + @Email);

			COMMIT TRANSACTION;
		END
		ELSE
		BEGIN
			-- Usuario ya existe
			-- Propagar el error
			THROW 50000, 'Error en registro de usuario: email ya existe', 1;
		END
	END TRY
	BEGIN CATCH
		-- Si ocurre un error, hacer rollback y registrar en el History Log
		ROLLBACK TRANSACTION;

		INSERT INTO practica1.HistoryLog (Date, Description)
		VALUES (GETDATE(), 'Error en registro de usuario: ' + @Email);

		-- Propagar el error
		THROW 50000, 'Error en registro de usuario', 1;
	END CATCH;
END;
GO

-- PR2 --------------------------------------
-- Transaccion
-- Cambio de Roles
CREATE PROCEDURE [practica1].[PR2]
    @UserId UNIQUEIDENTIFIER
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        DECLARE @StudentRoleId UNIQUEIDENTIFIER = (SELECT Id FROM practica1.Roles WHERE RoleName = 'Student');
        DECLARE @TutorRoleId UNIQUEIDENTIFIER = (SELECT Id FROM practica1.Roles WHERE RoleName = 'Tutor');

        -- Agregar el rol de tutor al usuario
        INSERT INTO practica1.UsuarioRole (RoleId, UserId, IsLatestVersion)
        VALUES (@TutorRoleId, @UserId, 1);

        -- Asignar el perfil de tutor
        INSERT INTO practica1.TutorProfile (UserId, TutorCode)
        VALUES (@UserId, NEWID());

        -- Registrar la transacción en el History Log
        INSERT INTO practica1.HistoryLog (Date, Description)
        VALUES (GETDATE(), 'Cambio de rol a tutor: ' + CAST(@UserId AS NVARCHAR(MAX)));

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        -- Si ocurre un error, hacer rollback y registrar en el History Log
        ROLLBACK TRANSACTION;

        INSERT INTO practica1.HistoryLog (Date, Description)
        VALUES (GETDATE(), 'Error en cambio de rol a tutor: ' + CAST(@UserId AS NVARCHAR(MAX)));

        -- Propagar el error
        THROW 50000,'Error en registro de usuario', 1;
        
    END CATCH;
END;
GO

-- PR7 - Asignar tutor a clase dada
-- Transacción exitosa: Asignación exitosa del curso
CREATE PROCEDURE [practica1].[PR7]
    @TutorId UNIQUEIDENTIFIER,
    @CourseCodCourse INT
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        -- Verificar si el curso ya tiene un tutor asignado
        IF EXISTS (SELECT 1 FROM practica1.CourseTutor WHERE CourseCodCourse = @CourseCodCourse)
        BEGIN
            -- El curso ya tiene un tutor asignado
            THROW 50000, 'El curso ya tiene un tutor asignado.', 1;
        END
        ELSE
        BEGIN
            -- Asignar el tutor al curso
            INSERT INTO practica1.CourseTutor (TutorId, CourseCodCourse)
            VALUES (@TutorId, @CourseCodCourse);

            -- Registrar la transacción en el History Log
            INSERT INTO practica1.HistoryLog (Date, Description)
            VALUES (GETDATE(), 'Asignación exitosa del curso' + CAST(@CourseCodCourse AS NVARCHAR(MAX)) + ' al estudiante tutor ' + CAST(@TutorId AS NVARCHAR(MAX)));

            COMMIT TRANSACTION;
        END;
    END TRY
    BEGIN CATCH
        -- Si ocurre un error, hacer rollback y registrar en el History Log
        ROLLBACK TRANSACTION;

        INSERT INTO practica1.HistoryLog (Date, Description)
        VALUES (GETDATE(), 'Error en asignación de curso ' + CAST(@CourseCodCourse AS NVARCHAR(MAX)) + ' al estudiante tutor ' + CAST(@TutorId AS NVARCHAR(MAX)));

        -- Propagar el error
        THROW;
    END CATCH;
END;
GO
-- PR3 --------------------------------------
-- Transaccion
-- Asignación de Curso
CREATE PROCEDURE [practica1].[PR3]
    @UserId UNIQUEIDENTIFIER,
    @CodCourse INT,
    @MaxStudents INT
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        -- Verificar que el usuario tenga suficientes créditos para el curso
        DECLARE @CreditsRequired INT = (SELECT CreditsRequired FROM practica1.Course WHERE CodCourse = @CodCourse);
        DECLARE @UserCredits INT = (SELECT Credits FROM practica1.ProfileStudent WHERE UserId = @UserId);

        -- Verificar si el usuario ya tiene asignado el curso
        IF NOT EXISTS (SELECT 1 FROM practica1.CourseAssignment WHERE StudentId = @UserId AND CourseCodCourse = @CodCourse)
        BEGIN
            IF @UserCredits >= @CreditsRequired
            BEGIN
                -- Verificar si hay cupo disponible en el curso
                DECLARE @CurrentStudents INT = (SELECT COUNT(*) FROM practica1.CourseAssignment WHERE CourseCodCourse = @CodCourse);

                IF @CurrentStudents < @MaxStudents
                BEGIN
                    -- Realizar la asignación del curso al estudiante
                    INSERT INTO practica1.CourseAssignment (StudentId, CourseCodCourse)
                    VALUES (@UserId, @CodCourse);

                    -- Actualizar los créditos del estudiante
                    UPDATE practica1.ProfileStudent
                    SET Credits = Credits - @CreditsRequired
                    WHERE UserId = @UserId;

                    -- Notificar al estudiante
                    INSERT INTO practica1.Notification (UserId, Message, Date)
                    VALUES (@UserId, 'Has sido asignado al curso ' + CAST(@CodCourse AS NVARCHAR(MAX)), GETDATE());

                    -- Notificar al tutor
                    DECLARE @TutorId UNIQUEIDENTIFIER = (SELECT TutorId FROM practica1.CourseTutor WHERE CourseCodCourse = @CodCourse);
                    INSERT INTO practica1.Notification (UserId, Message, Date)
                    VALUES (@TutorId, 'Se ha asignado un estudiante al curso ' + CAST(@CodCourse AS NVARCHAR(MAX)), GETDATE());

                    -- Registrar la transacción en el History Log
                    INSERT INTO practica1.HistoryLog (Date, Description)
                    VALUES (GETDATE(), 'Asignación exitosa del curso ' + CAST(@CodCourse AS NVARCHAR(MAX)) + ' al estudiante ' + CAST(@UserId AS NVARCHAR(MAX)));

                    COMMIT TRANSACTION;
                END
                ELSE
                BEGIN
                    -- No hay cupo disponible
                    THROW 50000,'El curso ya ha alcanzado el límite de cupo de estudiantes.', 1;

                END
            END
            ELSE
            BEGIN
                -- No tiene suficientes créditos
                THROW 50000,'El usuario no tiene suficientes créditos para este curso.', 1;
            END;
        END
        ELSE
        BEGIN
            -- El usuario ya tiene asignado este curso
            THROW 50000,'El usuario ya tiene asignado este curso.', 1;
        END;
    END TRY
    BEGIN CATCH
        -- Si ocurre un error, hacer rollback y registrar en el History Log
        ROLLBACK TRANSACTION;

        INSERT INTO practica1.HistoryLog (Date, Description)
        VALUES (GETDATE(), 'Error en asignación de curso ' + CAST(@CodCourse AS NVARCHAR(MAX)) + ' al estudiante ' + CAST(@UserId AS NVARCHAR(MAX)));

        -- Propagar el error
        THROW 50000,'Error en asignación de curso ', 1;
    END CATCH;
END;
GO
-- PR4 --------------------------------------
-- Transaccion
-- Creación de roles para estudiantes
CREATE PROCEDURE [practica1].[PR4]
    @RoleName NVARCHAR(MAX)
AS
BEGIN    
	SET NOCOUNT ON;
    BEGIN TRANSACTION;
    BEGIN TRY
        -- Verificar la existencia del rol
        IF NOT EXISTS (SELECT 1 FROM [practica1].[Roles] WHERE [RoleName] = @RoleName)
		BEGIN
			-- Insertar el nuevo rol
			INSERT INTO practica1.Roles (Id, RoleName)
			VALUES (NEWID(), @RoleName);

			-- Registrar la transacción en el History Log
			INSERT INTO practica1.HistoryLog (Date, Description)
			VALUES (GETDATE(), 'Creación de rol: ' + @RoleName);

			COMMIT TRANSACTION;
		END
		ELSE
		BEGIN
			-- El rol ya existe
			-- Propagar el error
			THROW 50000, 'El rol ya existe: ', 1;
		END
	END TRY
	BEGIN CATCH
		-- Si ocurre un error, hacer rollback y registrar en el History Log
		ROLLBACK TRANSACTION;

		INSERT INTO practica1.HistoryLog (Date, Description)
		VALUES (GETDATE(), 'Error en creación de rol: ' + @RoleName);

		-- Propagar el error
		THROW 50000, 'Error en creación de rol: ', 1;
	END CATCH;    
END;
GO
-- PR5 --------------------------------------
-- Transaccion
-- Creación de Cursos
CREATE PROCEDURE [practica1].[PR5]
	@CodCourse INT,
    @Name NVARCHAR(MAX),
    @CreditsRequired INT
AS
BEGIN
    BEGIN TRANSACTION;
    BEGIN TRY
        -- Validar los datos de entrada
        IF @Name IS NULL OR @CreditsRequired IS NULL OR @CodCourse IS NULL
        BEGIN
            THROW 50000, 'Error: Debe proporcionar valores válidos para CodCourse, Name y CreditsRequired.', 1;
        END;

        -- Verificar si el curso ya existe
        IF NOT EXISTS (SELECT 1 FROM practica1.Course WHERE Name = @Name OR CodCourse = @CodCourse)
        BEGIN
            -- Insertar el nuevo curso
            INSERT INTO practica1.Course (CodCourse, Name, CreditsRequired)
            VALUES (@CodCourse, @Name, @CreditsRequired);

            -- Registrar la transacción en el History Log
            INSERT INTO practica1.HistoryLog (Date, Description)
            VALUES (GETDATE(), 'Creación exitosa del curso ' + @Name);

            COMMIT TRANSACTION;
        END
        ELSE
        BEGIN
            -- El curso ya existe
            -- Propagar el error
            THROW 50000, 'Error en creación del curso: el curso ya existe.', 1;
        END
    END TRY
    BEGIN CATCH
        -- Si ocurre un error, hacer rollback y registrar en el History Log
        ROLLBACK TRANSACTION;

        INSERT INTO practica1.HistoryLog (Date, Description)
        VALUES (GETDATE(), 'Error en creación del curso ' + @Name);

        -- Propagar el error
        THROW 50000, 'Error en creación del curso', 1;
    END CATCH;
END;
GO
-- PR6 --------------------------------------
-- Transaccion
-- Validación de Datos
CREATE PROCEDURE [practica1].[PR6]
AS
BEGIN
    -- Validación para la tabla Usuarios
    DECLARE @done INT = 0;
    DECLARE @fname NVARCHAR(255), @lname NVARCHAR(255);
    DECLARE @cur1 CURSOR;

    SET @cur1 = CURSOR FOR SELECT FirstName, LastName FROM practica1.Usuarios;

    OPEN @cur1;

    FETCH NEXT FROM @cur1 INTO @fname, @lname;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Validar FirstName y LastName para contener solo letras
        IF @fname NOT LIKE '%[^A-Za-z]%' AND @lname NOT LIKE '%[^A-Za-z]%'
        BEGIN
            THROW 50000, 'Error: Datos inválidos en Usuarios.', 1;
        END

        FETCH NEXT FROM @cur1 INTO @fname, @lname;
    END;

    CLOSE @cur1;
    DEALLOCATE @cur1;

    -- Validación para la tabla Cursos
    DECLARE @done2 INT = 0;
    DECLARE @cname NVARCHAR(255);
    DECLARE @credits INT;
    DECLARE @cur2 CURSOR;

    SET @cur2 = CURSOR FOR SELECT Name, CreditsRequired FROM practica1.Cursos;

    OPEN @cur2;

    FETCH NEXT FROM @cur2 INTO @cname, @credits;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Validar Name para contener solo letras
        IF (@cname NOT LIKE '%[^A-Za-z]%')
        BEGIN
            THROW 50001, 'Error: Datos inválidos en Cursos.', 1;
        END 

        -- Validar CreditsRequired para contener solo números
        IF @credits NOT LIKE '%[0-9]%'
		BEGIN
			THROW 50002, 'Error: Datos inválidos en Cursos.', 1;
		END

        FETCH NEXT FROM @cur2 INTO @cname, @credits;
    END;

    CLOSE @cur2;
    DEALLOCATE @cur2;
END;
GO
-------------------------------------- FUNCIONES --------------------------------------
-- F1 --------------------------------------
-- Funcion
-- Función Func_course_usuarios
-- Función que retornará el listado completo de alumnos que están asignados a un determinado curso.
CREATE FUNCTION [practica1].[F1] (@CodCourse INT)
RETURNS TABLE
AS
RETURN
(
    SELECT u.Firstname, u.Lastname, u.Email, u.DateOfBirth, ps.Credits, r.RoleName
    FROM practica1.CourseAssignment ca
    INNER JOIN practica1.Usuarios u ON ca.StudentId = u.Id
    INNER JOIN practica1.ProfileStudent ps ON u.Id = ps.UserId
    INNER JOIN practica1.UsuarioRole ur ON u.Id = ur.UserId
    INNER JOIN practica1.Roles r ON ur.RoleId = r.Id
    WHERE ca.CourseCodCourse = @CodCourse
);
GO
-- F2 --------------------------------------
-- Funcion
-- Función Func_tutor_course
-- Función que retornará la lista de cursos a los cuales los tutores estén designados para dar clase.
CREATE FUNCTION [practica1].[F2] (@TutorProfileId UNIQUEIDENTIFIER)
RETURNS TABLE
AS
RETURN
(
    SELECT ct.CourseCodCourse, c.Name, c.CreditsRequired
    FROM practica1.CourseTutor ct
    INNER JOIN practica1.Course c ON ct.CourseCodCourse = c.CodCourse
    WHERE ct.TutorId = @TutorProfileId
);
GO
-- F3 --------------------------------------
-- Funcion
-- Función Func_notification_usuarios
-- Función que retornará la lista de notificaciones que hayan sido enviadas a un usuario.
CREATE FUNCTION [practica1].[F3] (@UserId UNIQUEIDENTIFIER)
RETURNS TABLE
AS
RETURN
(
    SELECT N.Id, N.Message, N.Date
    FROM practica1.Notification N
    WHERE N.UserId = @UserId
);
GO
-- F4 --------------------------------------
-- Funcion
-- Función Func_logger
-- Función que retornará la información almacenada en la tabla HistoryLog.
CREATE FUNCTION [practica1].[F4] ()
RETURNS TABLE
AS
RETURN
(
    SELECT H.Id, H.Date, H.Description
    FROM [practica1].[HistoryLog] H
);
GO
-- F5 --------------------------------------
-- Funcion
-- Función Func_usuarios
-- Función que retornará el expediente de cada alumno, que incluye los siguientes campos:
-- o Firstname
-- o Lastname
-- o Email
-- o DateOfBirth
-- o Credits
-- o RoleName
CREATE FUNCTION [practica1].[F5] (@UserId UNIQUEIDENTIFIER)
RETURNS TABLE
AS
RETURN
(
    SELECT U.Firstname, U.Lastname, U.Email, U.DateOfBirth, PS.Credits, R.RoleName
    FROM practica1.Usuarios U
    INNER JOIN practica1.ProfileStudent PS ON U.Id = PS.UserId
    INNER JOIN practica1.UsuarioRole UR ON U.Id = UR.UserId
    INNER JOIN practica1.Roles R ON UR.RoleId = R.Id
    WHERE U.Id = @UserId
);
GO

USE BD2;
GO
/*
-- Trigger: History Log
CREATE TRIGGER [practica1].[HistoryLog]
ON DATABASE
FOR CREATE_PROCEDURE, ALTER_PROCEDURE, DROP_PROCEDURE,
   CREATE_FUNCTION, ALTER_FUNCTION, DROP_FUNCTION,
   CREATE_TABLE, ALTER_TABLE, DROP_TABLE
AS
BEGIN
    INSERT INTO [practica1].[HistoryLog] (Date, Description)
    VALUES (GETDATE(), EVENTDATA().value('(/EVENT_INSTANCE/EventType)[1]', 'nvarchar(100)'))
END;
GO
*/

