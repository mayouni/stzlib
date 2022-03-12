oSQLite = sqlite_init()

sqlite_open(oSQLite,"stz.db")

cSQL = "
	CREATE TABLE FUNCACHE (
	ID INT PRIMARY 	KEY	NOT NULL,
	TIMESTAMP	TEXT	NOT NULL,
	
	)
"

sqlite_execute(oSQLite, cSQL)
