-- USE master;

/*
�������� ��������� ��� �������� ��������� ����� (������) �������� ��.
	���� ����� �� ��������� ������� 
	��� ���� � ���� �������� ���������� ������� ������ ������ ������ ������,
		�� ��������� ������ �����.
	����� 
		��������� ���������� �����. 
*/

CREATE PROCEDURE create_backup @db NVARCHAR(256) AS
BEGIN
	DECLARE @datetime NVARCHAR(256);
	DECLARE @datetime_name NVARCHAR(256);
	DECLARE @path NVARCHAR(256);

	SET @datetime = CAST(SYSDATETIME() AS NVARCHAR(256)); -- 2021-01-21 00:00:00.7906311
	SET @datetime_name = (SELECT REPLACE(REPLACE(@datetime, ' ', 'T'), ':', '.')); -- 2021-01-21T00.00.00.7906311

	-- ����� ��������� �������, ������� ��������� ������ �����
	IF NOT EXISTS (SELECT * FROM master.dbo.table_backups b WHERE b.backup_db = @db)
	BEGIN
		SET @path = 'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER03\MSSQL\DATA\' + @db + '_full_' + @datetime_name + '.bac';
		BACKUP DATABASE @db
		TO DISK = @path
		WITH INIT;
		INSERT INTO master.dbo.table_backups VALUES (@db, @datetime, @path, 1); -- backup_is_full = 1
	END

	-- ����� ��������� �� �������
	ELSE
	BEGIN
		-- ����� ������� ���� �������� ������� ������
		DECLARE @last_full_datetime NVARCHAR(256);
		SELECT @last_full_datetime = t.backup_datetime FROM (
			SELECT TOP 1 backup_datetime
			FROM master.dbo.table_backups
			WHERE backup_is_full = 1 
				AND backup_db = @db
			ORDER BY backup_datetime DESC
		) t;
		
		-- � ���� �������� ���������� ������� ������ ������ ������ ������, ������� ��������� ������ �����
		IF DATEDIFF(month, @last_full_datetime, @datetime) > 1
		BEGIN
			SET @path = 'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER03\MSSQL\DATA\' + @db + '_full_' + @datetime_name + '.bac';
			BACKUP DATABASE @db
			TO DISK = @path
			WITH INIT;
			INSERT INTO master.dbo.table_backups VALUES (@db, @datetime, @path, 1); -- backup_is_full = 1
		END

		-- �������� ����������� ������
		ELSE
		BEGIN
			SET @path = 'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER03\MSSQL\DATA\' + @db + '_diff_' + @datetime_name + '.bac';
			BACKUP DATABASE @db
			TO DISK = @path
			WITH DIFFERENTIAL, INIT;
			INSERT INTO master.dbo.table_backups VALUES (@db, @datetime, @path, 0); -- backup_is_full = 0
		END
	END
END;

EXEC create_backup @db = 'db_example';
