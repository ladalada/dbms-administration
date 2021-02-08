USE master;

DROP PROCEDURE IF EXISTS create_backup;

/*
������� ��� �������� ������� � ��������� �������:
	�������� ��, ��� ����� ���������,
	���� �������� ������,
	���� �� ������,
	��������, ������ �� ����� ���������
*/
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'table_backups')
BEGIN
	CREATE TABLE table_backups (
		backup_db NVARCHAR(256),
		backup_datetime NVARCHAR(256),
		backup_path NVARCHAR(256),
		backup_is_full BIT -- 1 ������ �����, 0 ���������� �����
	)
END;



