USE master;

DROP PROCEDURE IF EXISTS create_backup;

/*
A table for storing records about created backups:
	the name of the database whose backup is being created,
	the date the backup was created,
	path to backup,
	indicating whether a full backup is being created
*/
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'table_backups')
BEGIN
	CREATE TABLE table_backups (
		backup_db NVARCHAR(256),
		backup_datetime NVARCHAR(256),
		backup_path NVARCHAR(256),
		backup_is_full BIT -- 1 full backup, 0 differential backup
	)
END;



