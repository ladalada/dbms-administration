-- �������� ��
CREATE DATABASE db_users;

USE db_users;

-- �������� ������� ������
CREATE TABLE table1 (
	id INT, 
	col1 VARCHAR(20)
);
CREATE TABLE table2 (
	id INT, 
	col2 INT
);

-- �������� ������ ��� ��
CREATE LOGIN NinaLogin WITH PASSWORD = 'NinaPassword';

-- ���������� ������������ �� ������ ������
CREATE USER Nina FOR LOGIN NinaLogin;

-- �������������� ���������� ������������
-- �� �������� � �������� 
GRANT SELECT ON db_users.dbo.table1 TO [Nina];
GRANT UPDATE ON db_users.dbo.table1 TO [Nina];
GRANT INSERT ON db_users.dbo.table2 TO [Nina];