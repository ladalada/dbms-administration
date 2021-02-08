-- DROP PROCEDURE IF EXISTS restore_backup;

/*
Stored procedure for restoring a database
from a stored set of backup copies (backups)
with date and time
*/

CREATE PROCEDURE restore_backup 
	@db NVARCHAR(256), 
	@restore_datetime NVARCHAR(256) 
AS
BEGIN
	-- Checking if the database has backups
	IF EXISTS (SELECT * FROM master.dbo.table_backups b WHERE b.backup_db = @db)
	BEGIN
		
		DECLARE @full_datetime NVARCHAR(256);
		DECLARE @diff_datetime NVARCHAR(256);
		DECLARE @full_path NVARCHAR(256);
		DECLARE @diff_path NVARCHAR(256);
		
		-- Finding the last full backup with creation date <= @restore_datetime
		SELECT @full_datetime = (
			SELECT TOP 1 backup_datetime
			FROM master.dbo.table_backups
			WHERE backup_is_full = 1
				AND backup_datetime <= @restore_datetime
			ORDER BY backup_datetime DESC);

		-- Finding the path for the found full backup
		SELECT @full_path = (
			SELECT TOP 1 backup_path
			FROM master.dbo.table_backups
			WHERE backup_is_full = 1
				AND backup_datetime = @full_datetime
			ORDER BY backup_datetime DESC);

		-- Finding the last differential backup with creation date <= @restore_datetime
		SELECT @diff_datetime = (
			SELECT TOP 1 backup_datetime 
			FROM master.dbo.table_backups
			WHERE backup_is_full = 0
				AND backup_datetime <= @restore_datetime
			ORDER BY backup_datetime DESC);

		-- Finding the path for the found differential backup
		SELECT @diff_path = (
			SELECT TOP 1 backup_path
			FROM master.dbo.table_backups
			WHERE backup_is_full = 0
				AND backup_datetime = @diff_datetime
			ORDER BY backup_datetime DESC);

		-- If a full backup was created before the differential
		IF @full_datetime < @diff_datetime 
		BEGIN
			-- Restoring full backup
			RESTORE DATABASE @db
			FROM DISK = @full_path
			WITH REPLACE, NORECOVERY;

			-- Restoring differential backup
			RESTORE DATABASE @db
			FROM DISK = @diff_path
			WITH RECOVERY;
		END

		-- If a differential backup was created before a full
		ELSE
		BEGIN
			-- Restoring only a full backup
			RESTORE DATABASE @db
			FROM DISK = @full_path
			WITH REPLACE, RECOVERY;
		END

	END;

END;

