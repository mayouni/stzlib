load "../../stzBase.ring"
load "../_narrated.ring"

# SECURITY-SQL-BOUND-01 -- a value is BOUND, never spliced. HaroBase rung 0.
#
# stzAuthDbStore built about 49 statements by concatenation through a
# hand-written quote-doubler, over an engine bridge that could not bind;
# and stzDatabase.Rows() received every result as ONE string joined with
# TAB and NEWLINE and split it back, so a value holding either character
# came back cut into extra cells and extra rows. A query that failed
# partway through returned the rows read so far, as if complete.
#
# Now the engine prepares, binds, steps and returns rows as Ring lists
# (db.zig statement verbs), stzDatabase has ExecWith / RowsWith /
# TypedRowsWith / ValueWith and transactions, every auth-store statement
# is bound, and any failure raises.

$cNasty = "o'brien" + char(9) + "tab" + char(10) + "line"

# =====================================================================
#  THE AUTH STORE (runs against the old code too)
# =====================================================================

Scenario("a session whose user agent holds a quote, a tab and a newline round-trips")
	oS = new stzAuthDbStore(":memory:")
	Given("a durable auth store")
	When("a session is stored with that user agent")
	oS.PutSession("tok-1", [ :user = "alice", :expires = 2000000000000, :created = 1000,
	                         :ip = "10.0.0.1", :ua = $cNasty, :lastseen = 1000 ])
	aRec = oS.Session("tok-1")
	# before: the tab and the newline cut the row, and ua came back truncated
	Then("the user agent comes back byte for byte", aRec[:ua] = $cNasty, 1)
	Then("the fields after it survive too (lastseen)", aRec[:lastseen], 1000)
EndScenario()

Scenario("a username holding a quote, a tab and a newline is a username")
	oS = new stzAuthDbStore(":memory:")
	When("that user is created, given a role and a session")
	oS.PutUser($cNasty, "salt:hash")
	oS.GrantRole($cNasty, "admin")
	oS.PutSession("tok-2", [ :user = $cNasty, :expires = 5, :created = 1, :ip = "", :ua = "", :lastseen = 1 ])
	Then("the user exists", oS.HasUser($cNasty), 1)
	Then("its hash reads back", oS.UserHash($cNasty), "salt:hash")
	Then("its role reads back", oS.HasRole($cNasty, "admin"), 1)
	aSess = oS.SessionsOf($cNasty)
	Then("its session is found by user", len(aSess), 1)
	Then("and the session names the user exactly", aSess[1][:user] = $cNasty, 1)
EndScenario()

Scenario("an injection-shaped name matches nobody else")
	oS = new stzAuthDbStore(":memory:")
	oS.PutUser("alice", "h1")
	When("the store is asked about  x' OR '1'='1")
	Then("no such user", oS.HasUser("x' OR '1'='1"), 0)
	Then("no hash leaks", oS.UserHash("x' OR '1'='1"), "")
	Then("the real user is still found (positive sibling)", oS.HasUser("alice"), 1)
EndScenario()

# =====================================================================
#  stzDatabase
# =====================================================================

Scenario("a query that fails partway RAISES instead of returning partial rows")
	oDb = new stzDatabase(":memory:")
	oDb.Exec("CREATE TABLE t (x INTEGER)")
	oDb.Exec("INSERT INTO t VALUES (1), (2), (3)")
	When("row 3 overflows abs() at step time")
	bRaised = 0
	aRows = []
	try
		aRows = oDb.Rows("SELECT CASE WHEN x < 3 THEN x ELSE abs(-9223372036854775807 - 1) END FROM t")
	catch
		bRaised = 1
	done
	# before: 2 rows came back, and nothing said the answer was incomplete
	Then("the query raised", bRaised, 1)
	Then("no partial rows were returned", len(aRows), 0)
	Then("a healthy query still answers (positive sibling)", len(oDb.Rows("SELECT x FROM t")), 3)
	oDb.Close()
EndScenario()

Scenario("bound values round-trip exactly, NUL byte included")
	oDb = new stzDatabase(":memory:")
	oDb.Exec("CREATE TABLE v (s TEXT, n INTEGER, r REAL)")
	cWithNul = "a" + char(0) + "b"
	When("text holding a NUL, a quote, a tab and a newline is bound with numbers")
	oDb.ExecWith("INSERT INTO v VALUES (?, ?, ?)", [ $cNasty, 42, 2.5 ])
	oDb.ExecWith("INSERT INTO v VALUES (?, ?, ?)", [ cWithNul, 7, 0.25 ])
	aR = oDb.RowsWith("SELECT s FROM v WHERE n = ?", [ 42 ])
	Then("the text comes back byte for byte", aR[1][1] = $cNasty, 1)
	aR = oDb.RowsWith("SELECT s FROM v WHERE n = ?", [ 7 ])
	Then("the NUL byte survives (length 3)", len(aR[1][1]), 3)
	aT = oDb.TypedRowsWith("SELECT n, r FROM v WHERE s = ?", [ $cNasty ])
	Then("TypedRowsWith gives an INTEGER as a number", aT[1][1], 42)
	Then("and a REAL as a number", aT[1][2], 2.5)
	Then("RowsWith keeps the text contract", oDb.ValueWith("SELECT n FROM v WHERE r = ?", [ 2.5 ]), "42")
	oDb.Close()
EndScenario()

Scenario("what cannot be bound is refused, loudly")
	oDb = new stzDatabase(":memory:")
	oDb.Exec("CREATE TABLE t (x TEXT)")
	When("too few parameters are given")
	bRaised = 0
	try  oDb.ExecWith("INSERT INTO t VALUES (?)", [])  catch  bRaised = 1  done
	Then("it raises", bRaised, 1)
	When("a parameter is a list")
	bRaised = 0
	try  oDb.ExecWith("INSERT INTO t VALUES (?)", [ [ 1, 2 ] ])  catch  bRaised = 1  done
	Then("it raises", bRaised, 1)
	When("two statements are sent as one")
	bRaised = 0
	try  oDb.ExecWith("INSERT INTO t VALUES (?); DROP TABLE t", [ "x" ])  catch  bRaised = 1  done
	Then("it raises", bRaised, 1)
	Then("and the table is still there", len(oDb.Rows("SELECT name FROM sqlite_master WHERE name = 't'")), 1)
	Then("and nothing was inserted", oDb.Value("SELECT COUNT(*) FROM t"), "0")
	oDb.Close()
EndScenario()

Scenario("a transaction commits whole or rolls back whole")
	oDb = new stzDatabase(":memory:")
	oDb.Exec("CREATE TABLE t (x INTEGER PRIMARY KEY, v TEXT)")
	When("two inserts are rolled back")
	oDb.Begin()
	oDb.ExecWith("INSERT INTO t (v) VALUES (?)", [ "a" ])
	oDb.ExecWith("INSERT INTO t (v) VALUES (?)", [ "b" ])
	oDb.Rollback()
	Then("none is kept", oDb.Value("SELECT COUNT(*) FROM t"), "0")
	When("one insert is committed")
	oDb.Begin()
	oDb.ExecWith("INSERT INTO t (v) VALUES (?)", [ "c" ])
	nId = oDb.LastInsertId()
	oDb.Commit()
	Then("it is kept", oDb.Value("SELECT COUNT(*) FROM t"), "1")
	Then("LastInsertId names its row", oDb.ValueWith("SELECT v FROM t WHERE x = ?", [ nId ]), "c")
	oDb.Close()
EndScenario()

Summary()
