-- Stored procedure that grants all user rights 
-- to actions in each table of the current database

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

-- Procedure execution
EXEC Check_permissions @user = 'Nina';
