#================================================================#
#  STZDATAPORT -- the DATABASE service port (local-real mode)      #
#================================================================#

/*--- The exemplar: a dependency that virtualizes by being REAL.

Phase 2 of the service-virtualization plane, and it is deliberately the second
thing built because it proves the pattern with code that already works.

A data port is **"any object with `Exec(sql)` / `Rows(sql)` / `Value(sql)`"** --
the surface `stzDatabase` already exposes. So the port is not new machinery; it is
a name for a shape the library had all along.

WHAT MAKES THE DATABASE DIFFERENT, and why it is worth being the exemplar: the
other doubles in this plane are FAKES. A mail sandbox does not send. An OIDC
sandbox is not Google. But a database sandbox is **sqlite**, and sqlite is not a
pretend database -- it is a real one that happens to live in a file you own. The
plan calls this mode LOCAL-REAL, and it is the reason nobody needs a hosted-DB
subscription to write a data-backed application today.

That distinction has a consequence the registry had to learn: a fake must never
ship, but a **local-real** source shipping is not a violation at all. Plenty of
good systems run sqlite in production forever. So this file introduces the
posture, and the registry gained `BindLocal` to express it.

    oReg.BindLocal(:database, StzSqliteDataSourceQ("app.db"))   # may ship
    oReg.BindSandbox(:mail,   new stzMailSandbox())             # must NOT ship

THE ONE THING THAT *IS* DANGEROUS is an EPHEMERAL local source. `":memory:"` is a
genuine sqlite database, indistinguishable from a file-backed one right up to the
moment the process restarts and every row is gone. It is perfect for tests and
catastrophic in production -- and it is a one-character difference from the safe
thing. So the source reports whether it is ephemeral, and the registry treats an
ephemeral source in a production phase as an error.

At deploy you bind a hosted client -- Postgres, MySQL, a cloud DB -- behind the
same three methods. Softanza binds to no vendor; that adapter is yours to supply,
and it is infra-gated here (a hosted database needs an account and a network).
*/

func StzSqliteDataSourceQ(pcPath)
	return new stzSqliteDataSource(pcPath)

# the conventional in-memory source: real sqlite, gone on restart.
func StzMemoryDataSourceQ()
	return new stzSqliteDataSource(":memory:")


  #=========================================================#
 #  SQLITE DATA SOURCE -- local-real, not a fake             #
#=========================================================#

# Holds a local SQLite database as the data port of the service plane: a real database in a file you own, not a fake.
#
# A data port is any object with Exec, Rows and Value, the surface stzDatabase already has. This
# source is local-real: SQLite is not a pretend database, so it may ship, and registering it with
# BindLocal says so. The one dangerous case is the :memory: path, a genuine database that loses
# every row at restart and is one character away from a file path, so IsEphemeral reports it and the
# registry treats it as an error in a production phase. The three port methods run the SQL text as
# written; the small conveniences, TableExists, Tables and RowCount, build their own SQL. At deploy
# a hosted client such as Postgres is bound behind the same three methods.
#
#   receiver   o1 = StzMemoryDataSourceQ()
#   example    o1.Exec("CREATE TABLE people (id INTEGER, name TEXT)")
#              ? o1.Exec("INSERT INTO people VALUES (1, 'Aicha'), (2, 'Zin')")
#              #--> 2
#              ? o1.Value("SELECT name FROM people WHERE id = 2")
#              #--> Zin
#              ? o1.RowCount("people")
#              #--> 2
#              ? @@( o1.Tables() )
#              #--> [ "people" ]
#              ? o1.IsEphemeral()
#              #--> 1
#   see        stzServiceRegistry, stzDatabase, stzMailSandbox
class stzSqliteDataSource from stzObject

	@oDb = ""
	@cPath = ""

	# Opens a SQLite database as the library's data port: a file path, or :memory: for one that vanishes at restart.
	#
	#   pcPath     the database file, created when missing, or the text :memory:
	#   returns    nothing; the object is built
	#   warning    raises an error when the path is empty after trimming
	#   see        Exec, IsEphemeral
	def init(pcPath)
		@cPath = ring_trim("" + pcPath)
		if @cPath = ""
			StzRaise('stzSqliteDataSource: a path is required (or ":memory:" for an ephemeral one).')
		ok
		@oDb = new stzDatabase(@cPath)

	# Runs one SQL statement that changes data or structure and returns how many rows it changed.
	#
	#   pcSql      the statement to run
	#   returns    a number; 0 for a statement such as CREATE TABLE
	#   warning    raises an error with SQLite's message for invalid SQL, and after Close; the text
	#              is run as written, so build it with fixed parts and never by joining untrusted
	#              input
	#   see        Rows, Value
	#@ aka  -- the PORT contract (three methods, and that is all) ----------------
	def Exec(pcSql)
		return @oDb.Exec(pcSql)

	# Runs a query and returns all its rows.
	#
	#   pcSql      the query to run
	#   returns    a list of rows, each a list of the column values as text, so 1 comes back as "1";
	#              an empty list for no rows
	#   warning    raises an error with SQLite's message for invalid SQL, and after Close; the text
	#              is run as written
	#   see        Value, Exec
	def Rows(pcSql)
		return @oDb.Rows(pcSql)

	# Runs a query and returns the first column of its first row.
	#
	#   pcSql      the query to run
	#   returns    a text; an empty text when the query gives no row
	#   warning    raises an error with SQLite's message for invalid SQL, and after Close; the text
	#              is run as written
	#   see        Rows
	def Value(pcSql)
		return @oDb.Value(pcSql)

	# TRUE if the source is a real database and not a fake, so it may ship; it always is for SQLite.
	#
	#   returns    TRUE
	#   see        IsEphemeral
	#@ aka  -- what it is -------------------------------------------------------
	def IsLocalReal()
		return 1

	# TRUE if the path is :memory:, a real database that loses every row at restart, which the registry refuses in production.
	#
	#   returns    TRUE or FALSE
	#   see        IsLocalReal, Path
	#@ aka  ":memory:" is real sqlite that VANISHES on restart -- fine for a test, fatal in production, and one character away from the safe spelling. The registry treats this as an error in a production phase.
	def IsEphemeral()
		return @cPath = ":memory:"

	# Returns the path given at construction, trimmed.
	#
	#   returns    a text
	#   see        IsEphemeral
	def Path()
		return @cPath

	# TRUE if the database is open.
	#
	#   returns    TRUE or FALSE
	#   see        Close
	def IsOpen()
		return @oDb.IsOpen()

	# Returns the stzDatabase underneath, for code that needs more than the three-method port.
	#
	#   returns    a stzDatabase
	#   note       named so its use shows up in a search
	#   see        Exec, Rows
	#@ aka  the live stzDatabase, for code that wants more than the port's three methods (the port is the CONTRACT; this is the escape hatch, named so its use shows up in a grep).
	def DatabaseQ()
		return @oDb

	# TRUE if a table of that exact name exists; the match is case-sensitive.
	#
	#   pcTable    the table name
	#   returns    TRUE or FALSE
	#   warning    raises an error after Close
	#   see        Tables, RowCount
	#@ aka  -- small conveniences on top of the contract -------------------------
	def TableExists(pcTable)
		return ring_number(@oDb.Value("SELECT COUNT(*) FROM sqlite_master " +
		       "WHERE type='table' AND name='" + This._Esc(pcTable) + "'")) > 0

	# Returns the names of the tables, in alphabetical order.
	#
	#   returns    a list of text
	#   see        TableExists
	def Tables()
		_out_ = []
		_r_ = @oDb.Rows("SELECT name FROM sqlite_master WHERE type='table' ORDER BY name")
		_n_ = len(_r_)
		for _i_ = 1 to _n_
			_out_ + ("" + _r_[_i_][1])
		next
		return _out_

	# Returns how many rows a table holds, 0 for a table that does not exist.
	#
	#   pcTable    the table name
	#   returns    a number
	#   note       raises an error after Close
	#   warning    a table whose name needs quoting, such as my-table, raises a SQL error, because
	#              the name is put into the query bare once it is known to exist; a name that is not
	#              an existing table, even with SQL in it, answers 0 and runs nothing
	#   see        TableExists
	def RowCount(pcTable)
		if NOT This.TableExists(pcTable)
			return 0
		ok
		return ring_number(@oDb.Value("SELECT COUNT(*) FROM " + This._Esc(pcTable)))

	# Shuts the database; an in-memory one loses its rows.
	#
	#   returns    the source itself, so calls chain
	#   see        IsOpen
	def Close()
		@oDb.Close()
		return This

	# Prints one line with the path, marked EPHEMERAL for an in-memory source.
	#
	#   returns    nothing; it prints
	#   see        IsEphemeral
	def Show()
		? "stzSqliteDataSource(" + @cPath + ")" + This._EphemeralNote()

	  #-- internals -------------------------------------------------------

	def _EphemeralNote()
		if This.IsEphemeral()
			return "  [EPHEMERAL -- gone on restart]"
		ok
		return ""

	def _Esc(pcVal)
		return StzReplace("" + pcVal, "'", "''")
