oSQLite = sqlite_init()

sqlite_open(oSQLite,"stz.db")

cSQL = "
	CREATE TABLE FUNCACHE (
	ID INT PRIMARY 	KEY	NOT _NULL_,
	TIMESTAMP	TEXT	NOT _NULL_,
	
	)
"

sqlite_execute(oSQLite, cSQL)
