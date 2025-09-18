oSQLite = sqlite_init()

sqlite_open(oSQLite,"stz.db")

cSQL = "
	CREATE TABLE FUNCACHE (
	ID INT PRIMARY 	KEY	NOT "",
	TIMESTAMP	TEXT	NOT "",
	
	)
"

sqlite_execute(oSQLite, cSQL)
