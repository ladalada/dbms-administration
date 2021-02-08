-- Хранимая процедура, выдающая все права пользователя
-- на действия в каждой таблице текущей бд

CREATE PROCEDURE Check_permissions @user VARCHAR(50) AS
BEGIN
	EXECUTE AS USER = @user
	DECLARE @SQL NVARCHAR(max) = ''
	SELECT @SQL = @SQL + 
		'SELECT * 
		FROM fn_my_permissions(''' + 
			c.TABLE_CATALOG + '.' + c.TABLE_SCHEMA + '.' + c.TABLE_NAME + ''', 
			''OBJECT''
		)'
	FROM db_users.INFORMATION_SCHEMA.COLUMNS AS c
	WHERE c.COLUMN_NAME = 'id'
	EXEC(@SQL)
END;

-- Выполнение процедуры
EXEC Check_permissions @user = 'Nina';