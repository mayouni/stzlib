# R7 slice 1 ACCEPTANCE -- stzDatabase: the MBaaS/IoT data floor
# (SOFTANZA_INTELLIGENCE_ARCHITECTURE.md 5.10): sqlite was vendored but
# wired to nothing -- the quiet blocker for CRUD + telemetry. Now wired.

load "../../stzBase.ring"

nPass = 0
nFail = 0

pr()

? "-- Scene 1: open + DDL/DML --"
oDb = new stzDatabase(":memory:")
chk("an in-memory database opens", oDb.IsOpen() = 1)
oDb.Exec("CREATE TABLE dish(name TEXT, price REAL)")
chk("insert reports rows changed", oDb.Exec("INSERT INTO dish VALUES ('margherita', 8.5)") = 1)
oDb.Exec("INSERT INTO dish VALUES ('tiramisu', 6.0)")
oDb.Exec("INSERT INTO dish VALUES ('espresso', 2.5)")

? ""
? "-- Scene 2: query rows --"
aRows = oDb.Rows("SELECT name, price FROM dish ORDER BY price DESC")
chk("rows come back structured", len(aRows) = 3 and aRows[1][1] = "margherita")
chk("a scalar Value reads", oDb.Value("SELECT COUNT(*) FROM dish") = "3")
chk("an empty result is []", len(oDb.Rows("SELECT name FROM dish WHERE price > 100")) = 0)

? ""
? "-- Scene 3: update + honest error --"
chk("update reports its row count", oDb.Exec("UPDATE dish SET price = 9.0 WHERE name = 'margherita'") = 1)
chk("...and takes effect", oDb.Value("SELECT price FROM dish WHERE name = 'margherita'") = "9.0")
bE = 0
try
	oDb.Exec("NOT VALID SQL")
catch
	bE = 1
done
chk("malformed SQL RAISES with the engine's reason",
	bE = 1 and len(StzFind("syntax error", oDb.Why())) > 0)
oDb.Close()
chk("close releases the handle", oDb.IsOpen() = 0)

? ""
? "-- Scene 4: a FILE database persists across handles --"
cF = "t_db_accept.db"
if fexists(cF) remove(cF) ok
oF = new stzDatabase(cF)
oF.Exec("CREATE TABLE t(x INTEGER)")
oF.Exec("INSERT INTO t VALUES (42)")
oF.Close()
oF2 = new stzDatabase(cF)
chk("data survives close + reopen (the persistence floor)",
	oF2.Value("SELECT x FROM t") = "42")
oF2.Close()
remove(cF)

? ""
? "=========================================="
? "TOTAL: " + (nPass + nFail) + " assertions, " + nPass + " pass, " + nFail + " fail"
? "=========================================="

pf()

func chk(cLabel, bCond)
	if bCond
		nPass++
		? "  [OK] " + cLabel
	else
		nFail++
		? "  [FAIL] " + cLabel
	ok
