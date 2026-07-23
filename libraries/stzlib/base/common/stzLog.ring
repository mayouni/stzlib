#--------------------------------------------------------------#
#          SOFTANZA LIBRARY (V0.9) - STZLOG                    #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#
# Logging, the Softanza way: STRUCTURED-FIRST and QUERYABLE. A log is not a wall
# of text -- it is a stream of timestamped, leveled, structured ENTRIES you can
# write to, filter by level, query by field, and render as text OR JSON. Logs
# are inspectable DATA (like the audit trail, the findings, the reports), which
# is what a modern system actually needs: not "grep the file" but "give me every
# error in the 'deploy' category with user=mansour".
#
#   oLog = new stzLog("deploy")
#   oLog.Info("build started")
#   oLog.Record(:error, "compile failed", [ [ :part, "api" ], [ :code, 2 ] ])
#   oLog.CountOfLevel(:error)                 # 1
#   oLog.Where(:part, "api")                  # the structured entries about :api
#   ? oLog.AsJson()                           # ship to any log pipeline
#
# Levels (ordered): trace < debug < info < warn < error < fatal. A threshold
# (default 'info') drops anything below it. Entries are retained in memory and
# queryable (with an optional FIFO cap); echo-to-console is opt-in, and the whole
# log renders to text or JSON (WriteToFile / AsJson) for any pipeline.
# An entry is [ :seq, :ts, :level, :category, :message, :fields ].

  #=============#
 #  FUNCTIONS  #
#=============#

func StzLogQ(pcName)
	return new stzLog(pcName)

# level rank for threshold comparison; -1 for an unknown level.
func StzLogLevelRank(pcLevel)
	_l_ = StzLower(ring_trim("" + pcLevel))
	if _l_ = "trace"
		return 0
	but _l_ = "debug"
		return 1
	but _l_ = "info"
		return 2
	but _l_ = "warn"
		return 3
	but _l_ = "error"
		return 4
	but _l_ = "fatal"
		return 5
	ok
	return -1

func StzLogLevels()
	return [ "trace", "debug", "info", "warn", "error", "fatal" ]


  #==========#
 #  STZLOG  #
#==========#

class stzLog from stzObject

	@cName = ""              # the category (e.g. "deploy", "auth")
	@cThreshold = "info"     # entries below this level are dropped
	@aEntries = []           # [ [ :seq, :ts, :level, :category, :message, :fields ], ... ]
	@nSeq = 0
	@nCap = 0                # max retained entries (0 = unbounded); FIFO evict
	@bEcho = FALSE           # also print each recorded entry to the console

	def init(pcName)
		@cName = "" + pcName

	def Name()
		return @cName

	  #-- configuration (Q-fluent) ----------------------------------------

	# only entries at or above this level are recorded.
	def SetLevel(pcLevel)
		This.SetLevelQ(pcLevel)

	def SetLevelQ(pcLevel)
		if StzLogLevelRank(pcLevel) < 0
			StzRaise("stzLog: unknown level '" + pcLevel + "'. Levels: trace/debug/info/warn/error/fatal.")
		ok
		@cThreshold = StzLower(ring_trim("" + pcLevel))
		return This

	def Level()
		return @cThreshold

	def SetEcho(pbOn)
		This.SetEchoQ(pbOn)

	def SetEchoQ(pbOn)
		@bEcho = pbOn
		return This

	# retain at most n entries (0 = unbounded); oldest are evicted first.
	def SetCap(pnCap)
		This.SetCapQ(pnCap)

	def SetCapQ(pnCap)
		@nCap = pnCap
		return This

	  #-- writing (returns This, so writes chain) -------------------------

	# the general, STRUCTURED write: level + message + fields ([ [k, v], ... ]).
	def Record(pcLevel, pcMsg, paFields)
		_lvl_ = StzLower(ring_trim("" + pcLevel))
		if StzLogLevelRank(_lvl_) < StzLogLevelRank(@cThreshold)
			return This
		ok
		_flds_ = []
		if isList(paFields)
			_flds_ = paFields
		ok
		@nSeq++
		_entry_ = [ :seq = @nSeq, :ts = StzEngineTimeNowMs(), :level = _lvl_,
			:category = @cName, :message = "" + pcMsg, :fields = _flds_ ]
		@aEntries + _entry_
		if @nCap > 0 and len(@aEntries) > @nCap
			This._EvictOldest()
		ok
		if @bEcho
			? This._FormatEntry(_entry_)
		ok
		return This

	# level shortcuts (no fields) -- the common case.
	def Trace(pcMsg)
		return This.Record("trace", pcMsg, [])
	def Debug(pcMsg)
		return This.Record("debug", pcMsg, [])
	def Info(pcMsg)
		return This.Record("info", pcMsg, [])
	def Warn(pcMsg)
		return This.Record("warn", pcMsg, [])
	def Error(pcMsg)
		return This.Record("error", pcMsg, [])
	def Fatal(pcMsg)
		return This.Record("fatal", pcMsg, [])

	  #-- query (logs as data) --------------------------------------------

	def Entries()
		return @aEntries

	def NumberOfEntries()
		return len(@aEntries)

	def LastEntry()
		if len(@aEntries) = 0
			return []
		ok
		return @aEntries[len(@aEntries)]

	# every entry at exactly this level.
	def EntriesOfLevel(pcLevel)
		_l_ = StzLower(ring_trim("" + pcLevel))
		_out_ = []
		_n_ = len(@aEntries)
		for _i_ = 1 to _n_
			if @aEntries[_i_][:level] = _l_
				_out_ + @aEntries[_i_]
			ok
		next
		return _out_

	def CountOfLevel(pcLevel)
		return len(This.EntriesOfLevel(pcLevel))

	# every entry carrying a field key = value (structured query).
	def Where(pcKey, pValue)
		_k_ = "" + pcKey
		_v_ = "" + pValue
		_out_ = []
		_n_ = len(@aEntries)
		for _i_ = 1 to _n_
			_flds_ = @aEntries[_i_][:fields]
			_m_ = len(_flds_)
			for _j_ = 1 to _m_
				if ("" + _flds_[_j_][1]) = _k_ and ("" + _flds_[_j_][2]) = _v_
					_out_ + @aEntries[_i_]
					exit
				ok
			next
		next
		return _out_

	# entries at or after an epoch-ms timestamp.
	def Since(pnMs)
		_out_ = []
		_n_ = len(@aEntries)
		for _i_ = 1 to _n_
			if @aEntries[_i_][:ts] >= pnMs
				_out_ + @aEntries[_i_]
			ok
		next
		return _out_

	def Clear()
		@aEntries = []
		@nSeq = 0
		return This

	  #-- rendering -------------------------------------------------------

	def AsText()
		_c_ = ""
		_n_ = len(@aEntries)
		for _i_ = 1 to _n_
			_c_ += This._FormatEntry(@aEntries[_i_])
			if _i_ < _n_
				_c_ += nl
			ok
		next
		return _c_

	def Show()
		? This.AsText()

	# a JSON array of the entries -- ship to any log pipeline. Fields are inlined
	# as top-level keys alongside ts / level / category / message.
	def AsJson()
		_q_ = char(34)
		_c_ = "[" + nl
		_n_ = len(@aEntries)
		for _i_ = 1 to _n_
			_c_ += "  " + This._EntryJson(@aEntries[_i_])
			if _i_ < _n_
				_c_ += ","
			ok
			_c_ += nl
		next
		_c_ += "]" + nl
		return _c_

	def WriteToFile(pcPath)
		write("" + pcPath, This.AsText())
		return This

	def WriteJsonToFile(pcPath)
		write("" + pcPath, This.AsJson())
		return This

	  #-- internals -------------------------------------------------------

	def _EvictOldest()
		_aNew_ = []
		_n_ = len(@aEntries)
		_drop_ = _n_ - @nCap
		for _i_ = 1 to _n_
			if _i_ > _drop_
				_aNew_ + @aEntries[_i_]
			ok
		next
		@aEntries = _aNew_

	def _FormatEntry(paEntry)
		_c_ = "" + paEntry[:ts] + " " + upper("" + paEntry[:level]) + " " +
			paEntry[:category] + ": " + paEntry[:message]
		_flds_ = paEntry[:fields]
		_m_ = len(_flds_)
		if _m_ > 0
			_c_ += "  {"
			for _j_ = 1 to _m_
				_c_ += "" + _flds_[_j_][1] + "=" + _flds_[_j_][2]
				if _j_ < _m_
					_c_ += ", "
				ok
			next
			_c_ += "}"
		ok
		return _c_

	def _EntryJson(paEntry)
		_q_ = char(34)
		_c_ = "{ " + _q_ + "ts" + _q_ + ": " + paEntry[:ts]
		_c_ += ", " + _q_ + "level" + _q_ + ": " + _q_ + paEntry[:level] + _q_
		_c_ += ", " + _q_ + "category" + _q_ + ": " + _q_ + paEntry[:category] + _q_
		_c_ += ", " + _q_ + "message" + _q_ + ": " + _q_ + This._JsonEscape(paEntry[:message]) + _q_
		_flds_ = paEntry[:fields]
		_m_ = len(_flds_)
		for _j_ = 1 to _m_
			_c_ += ", " + _q_ + ("" + _flds_[_j_][1]) + _q_ + ": " +
				_q_ + This._JsonEscape("" + _flds_[_j_][2]) + _q_
		next
		_c_ += " }"
		return _c_

	def _JsonEscape(pcStr)
		_s_ = StzReplace("" + pcStr, char(92), char(92) + char(92))   # backslash
		_s_ = StzReplace(_s_, char(34), char(92) + char(34))          # quote
		return _s_
