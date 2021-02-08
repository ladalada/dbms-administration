-- Создание бд
CREATE DATABASE db_users;

USE db_users;

-- Создание простых таблиц
CREATE TABLE table1 (
	id INT, 
	col1 VARCHAR(20)
);
CREATE TABLE table2 (
	id INT, 
	col2 INT
);

-- Создание логина для бд
CREATE LOGIN NinaLogin WITH PASSWORD = 'NinaPassword';

-- Добавление пользователя на основе логина
CREATE USER Nina FOR LOGIN NinaLogin;

-- Предоставление разрешений пользователю
-- на действия в таблицах 
GRANT SELECT ON db_users.dbo.table1 TO [Nina];
GRANT UPDATE ON db_users.dbo.table1 TO [Nina];
GRANT INSERT ON db_users.dbo.table2 TO [Nina];