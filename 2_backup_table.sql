USE master;

DROP PROCEDURE IF EXISTS create_backup;

/*
Таблица для хранения записей о созданных бэкапах:
	название бд, чей бэкап создается,
	дата создания бэкапа,
	путь до бэкапа,
	указание, полный ли бэкап создается
*/
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'table_backups')
BEGIN
	CREATE TABLE table_backups (
		backup_db NVARCHAR(256),
		backup_datetime NVARCHAR(256),
		backup_path NVARCHAR(256),
		backup_is_full BIT -- 1 полный бэкап, 0 разностный бэкап
	)
END;



