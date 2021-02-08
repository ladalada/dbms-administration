-- DROP PROCEDURE IF EXISTS restore_backup;

/*
�������� ��������� ��� �������������� ��
�� ��������� ������ ��������� ����� (�������)
� ��������� ���� � �������
*/

CREATE PROCEDURE restore_backup 
	@db NVARCHAR(256), 
	@restore_datetime NVARCHAR(256) 
AS
BEGIN
	-- ��������, ���� �� ������ � ��
	IF EXISTS (SELECT * FROM master.dbo.table_backups b WHERE b.backup_db = @db)
	BEGIN
		
		DECLARE @full_datetime NVARCHAR(256);
		DECLARE @diff_datetime NVARCHAR(256);
		DECLARE @full_path NVARCHAR(256);
		DECLARE @diff_path NVARCHAR(256);
		
		-- ����� ���������� ������� ������ � ����� �������� <= @restore_datetime
		SELECT @full_datetime = (
			SELECT TOP 1 backup_datetime
			FROM master.dbo.table_backups
			WHERE backup_is_full = 1
				AND backup_datetime <= @restore_datetime
			ORDER BY backup_datetime DESC);

		-- ����� ���� ��� ���������� ������� ������
		SELECT @full_path = (
			SELECT TOP 1 backup_path
			FROM master.dbo.table_backups
			WHERE backup_is_full = 1
				AND backup_datetime = @full_datetime
			ORDER BY backup_datetime DESC);

		-- ����� ���������� ����������� ������ � ����� �������� <= @restore_datetime
		SELECT @diff_datetime = (
			SELECT TOP 1 backup_datetime 
			FROM master.dbo.table_backups
			WHERE backup_is_full = 0
				AND backup_datetime <= @restore_datetime
			ORDER BY backup_datetime DESC);

		-- ����� ���� ��� ���������� ����������� ������
		SELECT @diff_path = (
			SELECT TOP 1 backup_path
			FROM master.dbo.table_backups
			WHERE backup_is_full = 0
				AND backup_datetime = @diff_datetime
			ORDER BY backup_datetime DESC);

		-- ���� ������ ����� ������ �� �����������
		IF @full_datetime < @diff_datetime 
		BEGIN
			-- �������������� ������� ������
			RESTORE DATABASE @db
			FROM DISK = @full_path
			WITH REPLACE, NORECOVERY;

			-- �������������� ����������� ������
			RESTORE DATABASE @db
			FROM DISK = @diff_path
			WITH RECOVERY;
		END

		-- ���� ���������� ����� ������ �� �������
		ELSE
		BEGIN
			-- �������������� ������ ������� ������
			RESTORE DATABASE @db
			FROM DISK = @full_path
			WITh REPLACE, RECOVERY;
		END

	END;

END;

