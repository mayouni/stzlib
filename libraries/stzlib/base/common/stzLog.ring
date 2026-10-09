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

# Keeps a structured, leveled log in memory that you can filter, query by field and render as text or JSON.
#
# A log is a stream of entries, each a hash-list with seq, ts (epoch milliseconds), level, category,
# message and fields. The levels run trace, debug, info, warn, error, fatal; the threshold (info by
# default) drops anything below it. Write with Record or the shortcuts Info, Warn and the rest,
# which return the log so writes chain; read with Entries, EntriesOfLevel, Where, OfTrace and Since;
# render with AsText, AsJson and OtelJson, or write to a file. A cap keeps only the newest entries.
#
#   receiver   o1 = new stzLog("deploy")
#   example    o1.Info("build started")
#              o1.Record(:error, "compile failed", [ [ :part, "api" ], [ :code, 2 ] ])
#              o1.Debug("hidden")
#              ? o1.NumberOfEntries()
#              #--> 2
#              ? o1.CountOfLevel(:error)
#              #--> 1
#              ? @@( o1.LastEntry()[:message] )
#              #--> "compile failed"
#              ? @@( o1.Where(:part, "api")[1][:fields] )
#              #--> [ [ "part", "api" ], [ "code", 2 ] ]
#              ? @@( o1.Level() )
#              #--> "info"
#   see        StzLogQ, StzLogLevels, stzPerfMonitor
class stzLog from stzObject

	@cName = ""              # the category (e.g. "deploy", "auth")
	@cThreshold = "info"     # entries below this level are dropped
	@aEntries = []           # [ [ :seq, :ts, :level, :category, :message, :fields ], ... ]
	@nSeq = 0
	@nCap = 0                # max retained entries (0 = unbounded); FIFO evict
	@bEcho = 0           # also print each recorded entry to the console

	# Builds an empty log for one category, with the threshold info, no echo and no cap on the entries kept.
	#
	#   pcName     the category stamped on every entry, such as deploy
	#   returns    nothing; the object is built
	#   see        SetLevel, SetCap, SetEcho
	def init(pcName)
		@cName = "" + pcName

	# Returns the category the log was built with, which every entry carries.
	#
	#   returns    a text such as deploy
	#   see        Level
	def Name()
		return @cName

	# Sets the lowest level that is recorded, so that anything below it is dropped from now on.
	#
	#   pcLevel    one of trace, debug, info, warn, error or fatal, in any case
	#   returns    nothing; use SetLevelQ to chain
	#   note       entries already recorded stay
	#   warning    raises an error naming the unknown level for any other text, and keeps the old
	#              level
	#   see        Level, Record, SetLevelQ
	#@ aka  -- configuration (Q-fluent) ----------------------------------------
	def SetLevel(pcLevel)
		This.SetLevelQ(pcLevel)

	def SetLevelQ(pcLevel)
		if StzLogLevelRank(pcLevel) < 0
			StzRaise("stzLog: unknown level '" + pcLevel + "'. Levels: trace/debug/info/warn/error/fatal.")
		ok
		@cThreshold = StzLower(ring_trim("" + pcLevel))
		return This

	# Returns the lowest level that is recorded, in lowercase.
	#
	#   returns    a text such as info; info on a new log
	#   see        SetLevel
	def Level()
		return @cThreshold

	# Turns on or off the printing of each entry to the console as it is recorded.
	#
	#   pbOn       1 to print every new entry, 0 to keep quiet
	#   returns    nothing; use SetEchoQ to chain
	#   note       the printed line is the same as one line of AsText
	#   see        Record, Show
	def SetEcho(pbOn)
		This.SetEchoQ(pbOn)

	def SetEchoQ(pbOn)
		@bEcho = pbOn
		return This

	# Sets how many entries the log keeps, evicting the oldest first; 0 means no limit.
	#
	#   pnCap      the most entries to keep, or 0 for no limit
	#   returns    nothing; use SetCapQ to chain
	#   note       the cap is applied when the next entry is recorded, so lowering it does not trim
	#              at once
	#   see        NumberOfEntries, Clear
	#@ aka  retain at most n entries (0 = unbounded); oldest are evicted first.
	def SetCap(pnCap)
		This.SetCapQ(pnCap)

	def SetCapQ(pnCap)
		@nCap = pnCap
		return This

	# Records one entry with a level, a message and structured fields, unless the level is below the threshold.
	#
	#   pcLevel    the level of the entry, such as warn
	#   pcMsg      the message text
	#   paFields   a list of key and value pairs such as [ [ :part, "api" ] ], or [ ] for none
	#   returns    the log itself, so writes chain
	#   note       each entry is a hash-list with seq, ts, level, category, message and fields;
	#              inside a trace scope a traceId field is added
	#   warning    the third argument is required (a call with two raises a missing-parameter
	#              error); a level that is not one of the six is dropped without a message; a third
	#              argument that is not a list is ignored
	#   see        Info, Where, Entries, SetLevel
	#@ aka  -- writing (returns This, so writes chain) -------------------------
	def Record(pcLevel, pcMsg, paFields)
		_lvl_ = StzLower(ring_trim("" + pcLevel))
		if StzLogLevelRank(_lvl_) < StzLogLevelRank(@cThreshold)
			return This
		ok
		_flds_ = []
		if isList(paFields)
			_flds_ = paFields
		ok
		# perf P9: inside a trace scope (the observed server opens one
		# around every request; StzOpenTraceScope opens one anywhere),
		# every record stamps the active trace id -- log lines and
		# request traces correlate with no plumbing. Outside a scope,
		# nothing is added.
		_cTP_ = StzEnginePerfTraceScopeGet()
		if _cTP_ != ""
			_flds_ + [ "traceId", StzEngineTraceId(_cTP_) ]
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

	# Records a message at the lowest level, trace, with no fields.
	#
	#   pcMsg      the message text
	#   returns    the log itself, so writes chain
	#   see        Record, Debug
	#@ aka  level shortcuts (no fields) -- the common case.
	def Trace(pcMsg)
		return This.Record("trace", pcMsg, [])
	# Records a message at level debug with no fields.
	#
	#   pcMsg      the message text
	#   returns    the log itself, so writes chain
	#   see        Record, Info
	def Debug(pcMsg)
		return This.Record("debug", pcMsg, [])
	# Records a message at level info with no fields.
	#
	#   pcMsg      the message text
	#   returns    the log itself, so writes chain
	#   see        Record, Warn
	def Info(pcMsg)
		return This.Record("info", pcMsg, [])
	# Records a message at level warn with no fields.
	#
	#   pcMsg      the message text
	#   returns    the log itself, so writes chain
	#   see        Record, Error
	def Warn(pcMsg)
		return This.Record("warn", pcMsg, [])
	# Records a message at level error with no fields.
	#
	#   pcMsg      the message text
	#   returns    the log itself, so writes chain
	#   see        Record, Fatal
	def Error(pcMsg)
		return This.Record("error", pcMsg, [])
	# Records a message at the highest level, fatal, with no fields.
	#
	#   pcMsg      the message text
	#   returns    the log itself, so writes chain
	#   see        Record, Error
	def Fatal(pcMsg)
		return This.Record("fatal", pcMsg, [])

	# Returns every entry kept, oldest first.
	#
	#   returns    a list of hash-lists with seq, ts, level, category, message and fields
	#   note       ts is the epoch time in milliseconds, so it changes on every run
	#   see        NumberOfEntries, LastEntry, EntriesOfLevel
	#@ aka  -- query (logs as data) --------------------------------------------
	def Entries()
		return @aEntries

	# Returns how many entries the log holds now.
	#
	#   returns    a number
	#   see        Entries, SetCap
	def NumberOfEntries()
		return len(@aEntries)

	# Returns the newest entry, or an empty list when the log holds none.
	#
	#   returns    a hash-list with seq, ts, level, category, message and fields; [ ] for an empty
	#              log
	#   see        Entries
	def LastEntry()
		if len(@aEntries) = 0
			return []
		ok
		return @aEntries[len(@aEntries)]

	# Returns the entries recorded at exactly the given level.
	#
	#   pcLevel    the level to keep, in any case
	#   returns    a list of entries; [ ] when none or when the level is unknown
	#   note       it is an exact match, so asking for warn does not return error
	#   see        CountOfLevel, Where
	#@ aka  every entry at exactly this level.
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

	# Returns how many entries were recorded at exactly the given level.
	#
	#   pcLevel    the level to count, in any case
	#   returns    a number; 0 for an unknown level
	#   see        EntriesOfLevel
	def CountOfLevel(pcLevel)
		return len(This.EntriesOfLevel(pcLevel))

	# Returns the entries that carry a field with the given key and value.
	#
	#   pcKey      the field key to look for, such as part
	#   pValue     the value that field must have
	#   returns    a list of entries; [ ] when none match
	#   note       key and value are compared as text, so 2 and "2" match
	#   see        OfTrace, Record
	#@ aka  every entry carrying a field key = value (structured query).
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

	# Returns the entries stamped with the given trace id, which links a request's trace to its log lines.
	#
	#   pcTraceId   the trace id text
	#   returns     a list of entries; [ ] when none carries that id
	#   see         Where, Record
	#@ aka  every entry stamped with this trace id (perf P9) -- the bridge from an alert's trip trace-ids to the log lines of those trips.
	def OfTrace(pcTraceId)
		return This.Where("traceId", pcTraceId)

	# Returns the entries recorded at or after a time given in epoch milliseconds.
	#
	#   pnMs       the earliest time to keep, in epoch milliseconds
	#   returns    a list of entries, oldest first
	#   see        Entries
	#@ aka  entries at or after an epoch-ms timestamp.
	def Since(pnMs)
		_out_ = []
		_n_ = len(@aEntries)
		for _i_ = 1 to _n_
			if @aEntries[_i_][:ts] >= pnMs
				_out_ + @aEntries[_i_]
			ok
		next
		return _out_

	# Removes every entry and restarts the numbering at 1.
	#
	#   returns    the log itself, so calls chain
	#   note       the level, the cap and the echo flag are kept
	#   see        Entries, SetCap
	def Clear()
		@aEntries = []
		@nSeq = 0
		return This

	# Renders the entries as lines of timestamp, level, category and message, followed by the fields in braces.
	#
	#   returns    a text with one line per entry, no final line break; empty text for an empty log
	#   see        AsJson, Show, WriteToFile
	#@ aka  -- rendering -------------------------------------------------------
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

	# Prints the entries as text on the console, one line each.
	#
	#   returns    nothing
	#   see        AsText, SetEcho
	def Show()
		? This.AsText()

	# Renders the entries as a JSON array, with the fields placed beside ts, level, category and message.
	#
	#   returns    a text holding the array
	#   note       field values come out as JSON text, so 2 is written as "2"
	#   see        OtelJson, WriteJsonToFile
	#@ aka  a JSON array of the entries -- ship to any log pipeline. Fields are inlined as top-level keys alongside ts / level / category / message.
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

	# Writes the text rendering of the entries to a file, replacing its contents.
	#
	#   pcPath     the file to write
	#   returns    the log itself, so calls chain
	#   see        AsText, WriteJsonToFile
	def WriteToFile(pcPath)
		write("" + pcPath, This.AsText())
		return This

	# Writes the JSON rendering of the entries to a file, replacing its contents.
	#
	#   pcPath     the file to write
	#   returns    the log itself, so calls chain
	#   see        AsJson, WriteToFile
	def WriteJsonToFile(pcPath)
		write("" + pcPath, This.AsJson())
		return This

	# Renders the entries as the OpenTelemetry logs envelope that a collector accepts, with the category as the service name.
	#
	#   returns    a text holding the JSON; the trace id of an entry is promoted to the record's own
	#              traceId
	#   note       field values are written as strings; severity numbers are 9 for info, 13 for warn
	#              and 17 for error
	#   see        AsJson
	#@ aka  The OTLP logs envelope (perf P9) -- what a collector ingests at /v1/logs, completing the OTel triad (spans P0/P7, metrics P2, logs here). Each record carries timeUnixNano (exact ms + zeros), severityText/Number, the body, the fields as attributes -- and the trace id PROMOTED to the logRecord's first-class traceId field, where tracing backends expect it.
	def OtelJson()
		_q_ = char(34)
		_cRecs_ = ""
		_n_ = len(@aEntries)
		for _i_ = 1 to _n_
			if _i_ > 1
				_cRecs_ += ","
			ok
			_cRecs_ += This._OtelLogRecordJson(@aEntries[_i_])
		next
		_cJ_ = '{"resourceLogs":[{"resource":{"attributes":[{"key":"service.name","value":{"stringValue":"'
		_cJ_ += @cName
		_cJ_ += '"}}]},"scopeLogs":[{"scope":{"name":"softanza.log"},"logRecords":['
		_cJ_ += _cRecs_
		_cJ_ += ']}]}]}'
		return _cJ_

	# OTLP severityNumber: trace=1 debug=5 info=9 warn=13 error=17 fatal=21.
	def _OtelSeverityNumber(pcLevel)
		return 1 + StzLogLevelRank(pcLevel) * 4

	def _OtelLogRecordJson(paEntry)
		_cR_ = '{"timeUnixNano":"' + ("" + paEntry[:ts]) + '000000"'
		_cR_ += (',"severityText":"' + upper("" + paEntry[:level]) + '"')
		_cR_ += (',"severityNumber":' + This._OtelSeverityNumber(paEntry[:level]))
		_cR_ += (',"body":{"stringValue":"' + This._JsonEscape(paEntry[:message]) + '"}')
		_cTid_ = ""
		_cAttrs_ = ""
		_flds_ = paEntry[:fields]
		_m_ = len(_flds_)
		for _j_ = 1 to _m_
			if ("" + _flds_[_j_][1]) = "traceId"
				_cTid_ = "" + _flds_[_j_][2]
				loop
			ok
			if _cAttrs_ != ""
				_cAttrs_ += ","
			ok
			_cAttrs_ += ('{"key":"' + ("" + _flds_[_j_][1]) + '","value":{"stringValue":"' +
				This._JsonEscape("" + _flds_[_j_][2]) + '"}}')
		next
		if _cAttrs_ != ""
			_cR_ += (',"attributes":[' + _cAttrs_ + ']')
		ok
		if _cTid_ != ""
			_cR_ += (',"traceId":"' + _cTid_ + '"')
		ok
		_cR_ += "}"
		return _cR_

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
