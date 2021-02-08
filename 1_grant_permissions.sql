-- Database creating
CREATE DATABASE db_users;

USE db_users;

-- Creating simple tables
CREATE TABLE table1 (
	id INT, 
	col1 VARCHAR(20)
);
CREATE TABLE table2 (
	id INT, 
	col2 INT
);

-- Creating a login for the database
CREATE LOGIN NinaLogin WITH PASSWORD = 'NinaPassword';

-- Add user based on login
CREATE USER Nina FOR LOGIN NinaLogin;

-- Granting user permissions
-- to actions on tables 
GRANT SELECT ON db_users.dbo.table1 TO [Nina];
GRANT UPDATE ON db_users.dbo.table1 TO [Nina];
GRANT INSERT ON db_users.dbo.table2 TO [Nina];
