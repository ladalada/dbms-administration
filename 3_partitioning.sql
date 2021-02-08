/* 
SQL-��� ��� ���������� ������� � ������� 
����� �������� ������ ����������� �������, 
�������� ������ � ���������������� ������
*/

-- �������� ��
CREATE DATABASE db_partitioning;

USE db_partitioning;

-- �������� ������� ��� ����������
CREATE TABLE table_for_partitioning(col1 INT, col2 INT);

-- ���������� ������� �������
DECLARE @i INT;
SET @i = 0;
WHILE (@i < 90)
BEGIN
	INSERT INTO table_for_partitioning(col1, col2)
		VALUES (@i, @i * 2);
	SET @i = @i + 3;
END;

/* 
���������� ������ �� 3 ������� (PARTITIONING) 
*/

-- 1) �������� ����� ������ 

-- �������� ������, �������� � ������

ALTER DATABASE db_partitioning 
ADD FILEGROUP g1;

ALTER DATABASE db_partitioning
ADD FILEGROUP g2;

ALTER DATABASE db_partitioning
ADD FILEGROUP g3;

-- ���������� ������ � ������ ������

ALTER DATABASE db_partitioning
ADD FILE 
(
	NAME = f1,
	FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER03\MSSQL\DATA\f1.ndf'
) TO FILEGROUP g1;

ALTER DATABASE db_partitioning
ADD FILE
(
	NAME = f2,
	FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER03\MSSQL\DATA\f2.ndf'
) TO FILEGROUP g2;

ALTER DATABASE db_partitioning
ADD FILE
(
	NAME = f3,
	FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER03\MSSQL\DATA\f3.ndf'
) TO FILEGROUP g3;

-- 2) �������� ������� ���������� (PARTITION FUNCTION) 
/* 
������� ���������� ������ �� 3 ������:
	col1 <= 40
	col1 > 40 AND col1 <= 60
	col1 > 60
*/
CREATE PARTITION FUNCTION fun_partitioning (INT) 
AS RANGE LEFT FOR VALUES (40, 60);

-- 3) �������� ����� ���������� (PARTITION SCHEME)
CREATE PARTITION SCHEME scheme_partitioning
AS PARTITION fun_partitioning
TO (g1, g2, g3);

-- 4) �������� ����� ����������� ������� (�������������)
CREATE TABLE new_table (col1 INT, col2 INT)
ON scheme_partitioning(col1);

-- ������� ������ � ����� �������
INSERT INTO new_table(col1, col2)
SELECT col1, col2 FROM table_for_partitioning;

-- �������� ���������� ������ �������� �������
SELECT o.name table_name, partition_id, partition_number, [rows]
FROM sys.partitions p
INNER JOIN sys.objects o ON o.object_id = p.object_id
WHERE o.name = 'table_for_partitioning';

-- ���������������� ������
EXEC sp_rename table_for_partitioning, old_table; 
EXEC sp_rename new_table, table_for_partitioning;

-- �������� ���������� ������ ����������� �������
SELECT o.name table_name, partition_id, partition_number, [rows]
FROM sys.partitions p
INNER JOIN sys.objects o ON o.object_id = p.object_id
WHERE o.name = 'table_for_partitioning';
