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


class stzDatabase from stzObject

	@nHandle = 0
	@cPath = ""
	@cWhy = ""

	def init(pcPath)
		@cPath = "" + pcPath
		@nHandle = StzEngineDbOpen(@cPath)
		if @nHandle = 0
			stzraise("Could not open database '" + @cPath + "'.")
		ok

	def Path()
		return @cPath

	def IsOpen()
		return @nHandle > 0

	def Why()
		return @cWhy

	# run a DDL/DML statement; returns rows-changed, or raises on error
	def Exec(pcSql)
		_n_ = StzEngineDbExec(@nHandle, "" + pcSql)
		if _n_ < 0
			@cWhy = StzEngineDbError()
			stzraise("SQL error: " + @cWhy)
		ok
		return _n_

	# query rows: [ [ col, col, ... ], ... ] (cells text-coerced).
	# Empty result -> []. Raises on a malformed query, AND on a query that
	# fails partway through its rows -- it never returns the rows read so
	# far as if they were the answer. Rows come back as Ring lists straight
	# from the engine: a tab or a newline inside a value is data. (They used
	# to travel as one TAB/NEWLINE-joined string split here, which cut such
	# a value into extra cells and extra rows.)
	def Rows(pcSql)
		return This.RowsWith(pcSql, [])

	# a single scalar (first cell of the first row), "" when empty
	def Value(pcSql)
		return This.ValueWith(pcSql, [])

	#-- BOUND STATEMENTS ----------------------------------------------#
	# Every value goes in paParams and is BOUND to a ? in pcSql -- never
	# spliced into the text -- so no value can change what the statement
	# says, and none needs escaping:
	#
	#   oDb.ExecWith("INSERT INTO users (name, age) VALUES (?, ?)", [ cName, 42 ])
	#   oDb.RowsWith("SELECT age FROM users WHERE name = ?", [ cName ])
	#
	# A string binds as TEXT (exact bytes), an integral number as INTEGER,
	# any other number as REAL. One statement per call.

	# run a statement with bound values; returns rows changed, raises on error
	def ExecWith(pcSql, paParams)
		try
			return StzEngineDbExecP(@nHandle, "" + pcSql, paParams)
		catch
			@cWhy = cCatchError
			stzraise(@cWhy)
		done

	# rows with bound values, every cell as text (NULL -> "")
	def RowsWith(pcSql, paParams)
		try
			return StzEngineDbQueryP(@nHandle, "" + pcSql, paParams, 0)
		catch
			@cWhy = cCatchError
			stzraise(@cWhy)
		done

	# rows with bound values, INTEGER and REAL cells as Ring numbers
	def TypedRowsWith(pcSql, paParams)
		try
			return StzEngineDbQueryP(@nHandle, "" + pcSql, paParams, 1)
		catch
			@cWhy = cCatchError
			stzraise(@cWhy)
		done

	def ValueWith(pcSql, paParams)
		_aR_ = This.RowsWith(pcSql, paParams)
		if len(_aR_) = 0 or len(_aR_[1]) = 0
			return ""
		ok
		return _aR_[1][1]

	#-- TRANSACTIONS --------------------------------------------------#
	# Begin() takes the write lock at once (BEGIN IMMEDIATE), so a busy
	# database refuses here, where the whole unit can be retried.

	def Begin()
		StzEngineDbBegin(@nHandle)
		return This

	def Commit()
		StzEngineDbCommit(@nHandle)
		return This

	def Rollback()
		StzEngineDbRollback(@nHandle)
		return This

	def LastInsertId()
		return StzEngineDbLastInsertId(@nHandle)

	def Close()
		if @nHandle > 0
			StzEngineDbClose(@nHandle)
			@nHandle = 0
		ok
		return This
