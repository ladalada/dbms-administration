-- DROP PROCEDURE IF EXISTS restore_backup;

/*
Хранимая процедура для восстановления бд
из хранимого набора резервных копий (бэкапов)
с указанием даты и времени
*/

CREATE PROCEDURE restore_backup 
	@db NVARCHAR(256), 
	@restore_datetime NVARCHAR(256) 
AS
BEGIN
	-- Проверка, есть ли бэкапы у бд
	IF EXISTS (SELECT * FROM master.dbo.table_backups b WHERE b.backup_db = @db)
	BEGIN
		
		DECLARE @full_datetime NVARCHAR(256);
		DECLARE @diff_datetime NVARCHAR(256);
		DECLARE @full_path NVARCHAR(256);
		DECLARE @diff_path NVARCHAR(256);
		
		-- Поиск последнего полного бэкапа с датой создания <= @restore_datetime
		SELECT @full_datetime = (
			SELECT TOP 1 backup_datetime
			FROM master.dbo.table_backups
			WHERE backup_is_full = 1
				AND backup_datetime <= @restore_datetime
			ORDER BY backup_datetime DESC);

		-- Поиск пути для найденного полного бэкапа
		SELECT @full_path = (
			SELECT TOP 1 backup_path
			FROM master.dbo.table_backups
			WHERE backup_is_full = 1
				AND backup_datetime = @full_datetime
			ORDER BY backup_datetime DESC);

		-- Поиск последнего разностного бэкапа с датой создания <= @restore_datetime
		SELECT @diff_datetime = (
			SELECT TOP 1 backup_datetime 
			FROM master.dbo.table_backups
			WHERE backup_is_full = 0
				AND backup_datetime <= @restore_datetime
			ORDER BY backup_datetime DESC);

		-- Поиск пути для найденного разностного бэкапа
		SELECT @diff_path = (
			SELECT TOP 1 backup_path
			FROM master.dbo.table_backups
			WHERE backup_is_full = 0
				AND backup_datetime = @diff_datetime
			ORDER BY backup_datetime DESC);

		-- Если полный бэкап создан до разностного
		IF @full_datetime < @diff_datetime 
		BEGIN
			-- восстановление полного бэкапа
			RESTORE DATABASE @db
			FROM DISK = @full_path
			WITH REPLACE, NORECOVERY;

			-- восстановление разностного бэкапа
			RESTORE DATABASE @db
			FROM DISK = @diff_path
			WITH RECOVERY;
		END

		-- Если разностный бэкап создан до полного
		ELSE
		BEGIN
			-- восстановление только полного бэкапа
			RESTORE DATABASE @db
			FROM DISK = @full_path
			WITh REPLACE, RECOVERY;
		END

	END;

END;

