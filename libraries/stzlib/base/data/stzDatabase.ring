# R7 -- stzDatabase: the MBaaS/IoT DATA FLOOR (5.10)
# A thin, Softanza-shaped face over the engine sqlite bridge -- open
# a file or an in-memory store, run DDL/DML, query rows. The engine
# (stz_db.dll over vendored sqlite3) does the work; this is the Ring
# surface the app server and agents persist through.
#
#   oDb = new stzDatabase(":memory:")
#   oDb.Exec("CREATE TABLE dish(name TEXT, price REAL)")
#   oDb.Exec("INSERT INTO dish VALUES ('margherita', 8.5)")
#   ? oDb.Rows("SELECT name, price FROM dish")   #--> [ [ "margherita", "8.5" ] ]
#   oDb.Close()

func StzDatabaseQ(pcPath)
	return new stzDatabase(pcPath)

func StzMemoryDatabaseQ()
	return new stzDatabase(":memory:")


# Opens a SQLite database, a file or a store in memory, to run statements, read rows and keep transactions.
#
# Exec runs a statement and Rows reads a query, with every cell as text; the With forms bind their
# values to ? marks instead of splicing them into the text, which is the way to put user data in.
# TypedRowsWith returns numbers for numeric cells. Begin takes the write lock at once and Commit or
# Rollback ends the transaction. A failed call raises, and Why keeps the engine's last message. The
# engine does the work; this is the Ring face the application server and agents persist through.
#
#   receiver   o1 = new stzDatabase(":memory:")
#   example    o1.Exec("CREATE TABLE dish(name TEXT, price REAL)")
#              o1.ExecWith("INSERT INTO dish VALUES (?, ?)", [ "margherita", 8.5 ])
#              ? o1.Rows("SELECT name, price FROM dish")[1][1]
#              #--> margherita
#              ? o1.ValueWith("SELECT price FROM dish WHERE name = ?", [ "margherita" ])
#              #--> 8.5
#              ? o1.TypedRowsWith("SELECT price FROM dish", [])[1][1] + 1
#              #--> 9.50
#   see        StzMemoryDatabaseQ, StzDatabaseQ, stzAppServer
class stzDatabase from stzObject

	@nHandle = 0
	@cPath = ""
	@cWhy = ""

	# Opens a SQLite database, a file path or :memory: for a store that lives only in this process, and raises if it can not be opened.
	#
	#   pcPath     the database file, or :memory:
	#   returns    nothing; the object is built
	#   see        Path, IsOpen, Close
	def init(pcPath)
		@cPath = "" + pcPath
		@nHandle = StzEngineDbOpen(@cPath)
		if @nHandle = 0
			stzraise("Could not open database '" + @cPath + "'.")
		ok

	# Returns the path the database was opened with.
	#
	#   returns    a text such as :memory:
	#   see        IsOpen
	def Path()
		return @cPath

	# TRUE if the database handle is still open, which Close ends.
	#
	#   returns    1 or 0, numbers
	#   see        Close, Path
	def IsOpen()
		return @nHandle > 0

	# Returns the text of the last error that a failed call recorded, such as the table that was not found.
	#
	#   returns    a text; empty before any error
	#   note       after a failed Exec the text is the engine's bare message, after a failed query
	#              or bound call it starts with sql error:
	#   see        Exec, Rows
	def Why()
		return @cWhy

	# Runs one DDL or DML statement and returns how many rows it changed; raises on a SQL error.
	#
	#   pcSql      the statement text, with its values written in
	#   returns    a number, 0 for a CREATE
	#   note       values spliced into the text are the caller's to escape; use ExecWith to bind
	#              them
	#   warning    raises SQL error: with the engine's message, for a malformed statement and on a
	#              closed database
	#   see        ExecWith, Rows, Why
	#@ aka  run a DDL/DML statement; returns rows-changed, or raises on error
	def Exec(pcSql)
		_n_ = StzEngineDbExec(@nHandle, "" + pcSql)
		if _n_ < 0
			@cWhy = StzEngineDbError()
			stzraise("SQL error: " + @cWhy)
		ok
		return _n_

	# Returns the rows of a query, each as a list of cells that are all text, NULL being an empty text.
	#
	#   pcSql      the SELECT text
	#   returns    a list of rows; [ ] when the query matches nothing
	#   note       a REAL cell reads 9.5 or 10.0, as SQLite writes it
	#   warning    raises on a malformed query and on one that fails partway; a tab or a line break
	#              in a value stays inside its cell
	#   see        RowsWith, TypedRowsWith, Value
	#@ aka  query rows: [ [ col, col, ... ], ... ] (cells text-coerced). Empty result -> []. Raises on a malformed query, AND on a query that fails partway through its rows -- it never returns the rows read so far as if they were the answer. Rows come back as Ring lists straight from the engine: a tab or a newline inside a value is data. (They used to travel as one TAB/NEWLINE-joined string split here, which 
	def Rows(pcSql)
		return This.RowsWith(pcSql, [])

	# Returns the first cell of the first row of a query, an empty text when there is none.
	#
	#   pcSql      the SELECT text
	#   returns    a text
	#   see        ValueWith, Rows
	#@ aka  a single scalar (first cell of the first row), "" when empty
	def Value(pcSql)
		return This.ValueWith(pcSql, [])

	#-- BOUND STATEMENTS ----------------------------------------------#
	# Runs one statement whose ? marks are bound to the given values and returns how many rows it changed.
	#
	#   pcSql      the statement with ? marks
	#   paParams   the values in order: a text binds as TEXT, a whole number as INTEGER, any other
	#              number as REAL
	#   returns    a number
	#   note       no value can change what the statement says, and none needs escaping
	#   warning    raises when the count of values does not fit, with a message that always says the
	#              statement has -1 parameters, whatever its real count
	#   see        Exec, RowsWith
	#@ aka  Every value goes in paParams and is BOUND to a ? in pcSql -- never spliced into the text -- so no value can change what the statement says, and none needs escaping:
	def ExecWith(pcSql, paParams)
		try
			return StzEngineDbExecP(@nHandle, "" + pcSql, paParams)
		catch
			@cWhy = cCatchError
			stzraise(@cWhy)
		done

	# Returns the rows of a query whose ? marks are bound to the given values, every cell as text.
	#
	#   pcSql      the SELECT text with ? marks
	#   paParams   the values in order, as for ExecWith
	#   returns    a list of rows of text cells
	#   note       a value such as x' OR '1'='1 matches nothing, being data
	#   warning    raises on a count mismatch with the same -1 message as ExecWith
	#   see        TypedRowsWith, ValueWith, Rows
	#@ aka  rows with bound values, every cell as text (NULL -> "")
	def RowsWith(pcSql, paParams)
		try
			return StzEngineDbQueryP(@nHandle, "" + pcSql, paParams, 0)
		catch
			@cWhy = cCatchError
			stzraise(@cWhy)
		done

	# Returns the rows of a bound query with INTEGER and REAL cells as Ring numbers and TEXT and NULL cells as text.
	#
	#   pcSql      the SELECT text with ? marks
	#   paParams   the values in order
	#   returns    a list of rows
	#   note       a NULL still comes back as an empty text, not as a number
	#   see        RowsWith, Rows
	#@ aka  rows with bound values, INTEGER and REAL cells as Ring numbers
	def TypedRowsWith(pcSql, paParams)
		try
			return StzEngineDbQueryP(@nHandle, "" + pcSql, paParams, 1)
		catch
			@cWhy = cCatchError
			stzraise(@cWhy)
		done

	# Returns the first cell of the first row of a bound query, an empty text when there is none.
	#
	#   pcSql      the SELECT text with ? marks
	#   paParams   the values in order
	#   returns    a text
	#   see        Value, RowsWith
	def ValueWith(pcSql, paParams)
		_aR_ = This.RowsWith(pcSql, paParams)
		if len(_aR_) = 0 or len(_aR_[1]) = 0
			return ""
		ok
		return _aR_[1][1]

	#-- TRANSACTIONS --------------------------------------------------#
	# Starts a transaction and takes the write lock at once, so a busy database refuses here.
	#
	#   returns    the database itself, so calls chain
	#   note       one transaction at a time; there is no nesting
	#   warning    raises when a transaction is already open and on a closed database, with the
	#              engine's reason
	#   see        Commit, Rollback
	#@ aka  Begin() takes the write lock at once (BEGIN IMMEDIATE), so a busy database refuses here, where the whole unit can be retried.
	def Begin()
		StzEngineDbBegin(@nHandle)
		return This

	# Makes the changes of the open transaction permanent.
	#
	#   returns    the database itself, so calls chain
	#   warning    raises when no transaction is active
	#   see        Begin, Rollback
	def Commit()
		StzEngineDbCommit(@nHandle)
		return This

	# Undoes the changes of the open transaction.
	#
	#   returns    the database itself, so calls chain
	#   see        Begin, Commit
	def Rollback()
		StzEngineDbRollback(@nHandle)
		return This

	# Returns the rowid of the last row inserted on this connection.
	#
	#   returns    a number; 0 on a closed database
	#   see        ExecWith, Exec
	def LastInsertId()
		return StzEngineDbLastInsertId(@nHandle)

	# Closes the database; closing twice is harmless.
	#
	#   returns    the database itself, so calls chain
	#   warning    after Close every query raises no such database handle
	#   see        IsOpen, init
	def Close()
		if @nHandle > 0
			StzEngineDbClose(@nHandle)
			@nHandle = 0
		ok
		return This
