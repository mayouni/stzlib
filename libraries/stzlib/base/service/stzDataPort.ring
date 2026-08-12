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

class stzSqliteDataSource from stzObject

	@oDb = ""
	@cPath = ""

	def init(pcPath)
		@cPath = ring_trim("" + pcPath)
		if @cPath = ""
			StzRaise('stzSqliteDataSource: a path is required (or ":memory:" for an ephemeral one).')
		ok
		@oDb = new stzDatabase(@cPath)

	  #-- the PORT contract (three methods, and that is all) ----------------

	def Exec(pcSql)
		return @oDb.Exec(pcSql)

	def Rows(pcSql)
		return @oDb.Rows(pcSql)

	def Value(pcSql)
		return @oDb.Value(pcSql)

	  #-- what it is -------------------------------------------------------

	# NOT a sandbox: sqlite is a real database. The registry asks this, and the
	# answer is what lets a local source ship where a fake may not.
	def IsLocalReal()
		return 1

	# ":memory:" is real sqlite that VANISHES on restart -- fine for a test, fatal
	# in production, and one character away from the safe spelling. The registry
	# treats this as an error in a production phase.
	def IsEphemeral()
		return @cPath = ":memory:"

	def Path()
		return @cPath

	def IsOpen()
		return @oDb.IsOpen()

	# the live stzDatabase, for code that wants more than the port's three methods
	# (the port is the CONTRACT; this is the escape hatch, named so its use shows up
	# in a grep).
	def DatabaseQ()
		return @oDb

	  #-- small conveniences on top of the contract -------------------------

	def TableExists(pcTable)
		return ring_number(@oDb.Value("SELECT COUNT(*) FROM sqlite_master " +
		       "WHERE type='table' AND name='" + This._Esc(pcTable) + "'")) > 0

	def Tables()
		_out_ = []
		_r_ = @oDb.Rows("SELECT name FROM sqlite_master WHERE type='table' ORDER BY name")
		_n_ = len(_r_)
		for _i_ = 1 to _n_
			_out_ + ("" + _r_[_i_][1])
		next
		return _out_

	def RowCount(pcTable)
		if NOT This.TableExists(pcTable)
			return 0
		ok
		return ring_number(@oDb.Value("SELECT COUNT(*) FROM " + This._Esc(pcTable)))

	def Close()
		@oDb.Close()
		return This

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
