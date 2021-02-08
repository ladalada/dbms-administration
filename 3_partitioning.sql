/* 
SQL code to split a table of data
by creating an empty split table,
transferring data, and renaming tables
*/

-- Database creation
CREATE DATABASE db_partitioning;

USE db_partitioning;

-- Creating a table to split
CREATE TABLE table_for_partitioning(col1 INT, col2 INT);

-- Populating a table with data
DECLARE @i INT;
SET @i = 0;
WHILE (@i < 90)
BEGIN
	INSERT INTO table_for_partitioning(col1, col2)
		VALUES (@i, @i * 2);
	SET @i = @i + 3;
END;

/* 
PARTITIONING data into 3 sections 
*/

-- 1) Create groups of files 

-- Creating files included in groups

ALTER DATABASE db_partitioning 
ADD FILEGROUP g1;

ALTER DATABASE db_partitioning
ADD FILEGROUP g2;

ALTER DATABASE db_partitioning
ADD FILEGROUP g3;

-- Adding files to each group

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

-- 2) Creating a PARTITION FUNCTION
/* 
Function for dividing data into 3 sections:
	col1 <= 40
	col1 > 40 AND col1 <= 60
	col1 > 60
*/
CREATE PARTITION FUNCTION fun_partitioning (INT) 
AS RANGE LEFT FOR VALUES (40, 60);

-- 3) Creating a PARTITION SCHEME 
CREATE PARTITION SCHEME scheme_partitioning
AS PARTITION fun_partitioning
TO (g1, g2, g3);

-- 4) Create a new split table (blank)
CREATE TABLE new_table (col1 INT, col2 INT)
ON scheme_partitioning(col1);

-- Transferring data to a new table
INSERT INTO new_table(col1, col2)
SELECT col1, col2 FROM table_for_partitioning;

-- Checking the data partitioning of the source table
SELECT o.name table_name, partition_id, partition_number, [rows]
FROM sys.partitions p
INNER JOIN sys.objects o ON o.object_id = p.object_id
WHERE o.name = 'table_for_partitioning';

-- Renaming tables
EXEC sp_rename table_for_partitioning, old_table; 
EXEC sp_rename new_table, table_for_partitioning;

-- Checking data partitioning of a partitioned table
SELECT o.name table_name, partition_id, partition_number, [rows]
FROM sys.partitions p
INNER JOIN sys.objects o ON o.object_id = p.object_id
WHERE o.name = 'table_for_partitioning';
