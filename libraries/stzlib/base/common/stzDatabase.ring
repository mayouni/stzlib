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
	# Empty result -> []. Raises on a malformed query.
	def Rows(pcSql)
		_nRows_ = StzEngineDbQuery(@nHandle, "" + pcSql)
		if _nRows_ < 0
			@cWhy = StzEngineDbError()
			stzraise("SQL error: " + @cWhy)
		ok
		if _nRows_ = 0
			return []
		ok
		_cRes_ = StzEngineDbResult()
		_aOut_ = []
		_acLines_ = StzSplit(_cRes_, char(10))
		_nL_ = len(_acLines_)
		for _i_ = 1 to _nL_
			_aOut_ + StzSplit(_acLines_[_i_], char(9))
		next
		return _aOut_

	# a single scalar (first cell of the first row), "" when empty
	def Value(pcSql)
		_aR_ = This.Rows(pcSql)
		if len(_aR_) = 0 or len(_aR_[1]) = 0
			return ""
		ok
		return _aR_[1][1]

	def Close()
		if @nHandle > 0
			StzEngineDbClose(@nHandle)
			@nHandle = 0
		ok
		return This
