/*
	stzPerfSentinel -- the alerting judge (perf P4).

	An SLA judges when asked; the sentinel judges ON A CADENCE and
	turns verdict TRANSITIONS into alerts. Edge-triggered, which is
	the honest flap suppression: a breach fires ONCE when it appears,
	a recovery fires once when it clears, and an invariant that stays
	broken does not page you four hundred times.

		oSent = new stzPerfSentinel(oSla, oMon)
		oSent.OnBreach(func aFinding { ? "ALERT: " + aFinding[:message] })
		oSent.OnClear(func cRule { ? "recovered: " + cRule })
		oSent.Check()          # one judgment pass -> fires transitions

	Three ways to run it -- the monitor's own trio:
	  PULL    Check() whenever you like.
	  TICK    Every(nMs) + Tick() from any loop (cadence-gated).
	  HOSTED  Name_() + Cycle() = the stzAgentHost contract, so a
	          server hosting agents judges its own SLA continuously.

	Every alert also FANS OUT on the engine event bus (process-global
	channels): breaches on 'perf.breach', recoveries on 'perf.clear'
	-- so an agent supervised ON that channel (SuperviseOnEvent) wakes
	up exactly when the SLA breaks, and any part of the process can
	poll EventCount()/LastEvent() without holding the sentinel.

	The ledger (AlertLog, newest 256) keeps the story: when, which
	invariant, breach or clear, with the verdict message.

	Ring copy honesty: the SLA is copied at birth (declarative config
	-- copies are fine); the monitor copy shares the engine-backed
	metrics; the sentinel's OWN transition state is Ring-side, so ONE
	face should drive Check()/Tick() (the same rule as the monitor's
	cadence).
*/

func StzPerfSentinel(poSla, poMonitor)
	return new stzPerfSentinel(poSla, poMonitor)

class stzPerfSentinel from stzObject

	@cName = "perf-sentinel"
	@oSla = ""
	@oMon = ""
	@aBreached = []		# rule names currently in breach
	@fOnBreach = ""
	@fOnClear = ""
	@bHasOnBreach = 0
	@bHasOnClear = 0
	@cBreachChannel = "perf.breach"
	@cClearChannel = "perf.clear"
	@oBus = ""
	@aAlertLog = []		# [ atMs, "breach"|"clear", rule, message ] (newest 256)
	@aBlackBox = []		# flight-recorder snapshots, one per breach (newest 16)
	@nEveryMs = 1000
	@nNextDueMs = 0
	@nChecks = 0

	def init(poSla, poMonitor)
		@oSla = poSla
		@oMon = poMonitor
		@oBus = new stzEventBus()

	def Name()
		return @cName

	def Name_()
		return @cName

	def SetName(pcName)
		if isString(pcName) and pcName != ""
			@cName = pcName
		ok
		return This

	def OnBreach(pfCallback)
		@fOnBreach = pfCallback
		@bHasOnBreach = 1
		return This

	def OnClear(pfCallback)
		@fOnClear = pfCallback
		@bHasOnClear = 1
		return This

	# The event-bus channels alerts fan out on (process-global).
	def SetChannels(pcBreach, pcClear)
		@cBreachChannel = "" + pcBreach
		@cClearChannel = "" + pcClear
		return This

	def BreachChannel()
		return @cBreachChannel

	def ClearChannel()
		return @cClearChannel

	def Every(pnMs)
		if isNumber(pnMs) and pnMs >= 1
			@nEveryMs = pnMs
		ok
		return This

	# -- Judging --------------------------------------------------

	# One judgment pass. Fires alerts on TRANSITIONS only: a rule
	# breaching now that was fine before -> breach alert; a rule fine
	# now that was breached before -> clear alert. Returns the number
	# of NEW breaches this pass.
	def Check()
		_aF_ = @oSla.CheckAgainst(@oMon)
		@nChecks++
		_aNow_ = []
		_nLen_ = ring_len(_aF_)
		for _i_ = 1 to _nLen_
			_aNow_ + _aF_[_i_][:rule]
		next
		_nNew_ = 0
		# new breaches: in now, not in before
		for _i_ = 1 to _nLen_
			if ring_find(@aBreached, _aF_[_i_][:rule]) = 0
				This._FireBreach(_aF_[_i_])
				_nNew_++
			ok
		next
		# recoveries: in before, not in now
		_nB_ = ring_len(@aBreached)
		for _i_ = 1 to _nB_
			if ring_find(_aNow_, @aBreached[_i_]) = 0
				This._FireClear(@aBreached[_i_])
			ok
		next
		@aBreached = _aNow_
		return _nNew_

	def CheckCount()
		return @nChecks

	# Cadence-gated judging, on the monotonic clock -- call from any
	# loop. Returns the number of new breaches (0 when not due).
	def Tick()
		_nNow_ = StzEngineWatchTimestampMs()
		if _nNow_ < @nNextDueMs
			return 0
		ok
		@nNextDueMs = _nNow_ + @nEveryMs
		return This.Check()

	# The agent-host contract: judging IS this agent's act.
	def Cycle()
		return This.Tick()

	# -- Reading --------------------------------------------------

	def ActiveBreaches()
		return @aBreached

	def IsBreached()
		return ring_len(@aBreached) > 0

	def AlertLog()
		return @aAlertLog

	def LastAlert()
		_n_ = ring_len(@aAlertLog)
		if _n_ = 0
			return []
		ok
		return @aAlertLog[_n_]

	def Explain()
		_aLines_ = []
		_cState_ = "all expectations met"
		if ring_len(@aBreached) > 0
			_cState_ = ring_len(@aBreached) + " active breach(es)"
		ok
		_aLines_ + ("Sentinel " + @cName + " -- " + @nChecks + " check(s), " + _cState_ + ".")
		_nB_ = ring_len(@aBreached)
		for _i_ = 1 to _nB_
			_aLines_ + ("  BREACHED: " + @aBreached[_i_])
		next
		return _aLines_

	def Show()
		_aL_ = This.Explain()
		_nL_ = ring_len(_aL_)
		for _i_ = 1 to _nL_
			? _aL_[_i_]
		next

	# -- Internals ------------------------------------------------

	def _FireBreach(paFinding)
		This._Log("breach", paFinding[:rule], paFinding[:message])
		This._RecordBlackBox(paFinding)
		@oBus.Emit(@cBreachChannel, paFinding[:rule] + " | " + paFinding[:message])
		if @bHasOnBreach
			_f_ = @fOnBreach
			call _f_(paFinding)
		ok

	def _FireClear(pcRule)
		This._Log("clear", pcRule, "recovered")
		@oBus.Emit(@cClearChannel, pcRule + " | recovered")
		if @bHasOnClear
			_f_ = @fOnClear
			call _f_(pcRule)
		ok

	def _Log(pcKind, pcRule, pcMessage)
		@aAlertLog + [ StzEngineWatchTimestampMs(), pcKind, pcRule, pcMessage ]
		if ring_len(@aAlertLog) > 256
			del(@aAlertLog, 1)
		ok

	# The FLIGHT RECORDER (perf P6, notebook issue 7): the only
	# monitoring that helps with a problem you cannot reproduce is the
	# monitoring that was already on -- so the moment an invariant
	# breaks, the sentinel photographs the process: the senses as they
	# are NOW, and every metric's current value. The black box is
	# already written when the anomaly lands; nobody has to remember
	# to look while it is still happening.
	def _RecordBlackBox(paFinding)
		_aMetrics_ = []
		_aReg_ = @oMon.Metrics()
		_nLen_ = ring_len(_aReg_)
		for _i_ = 1 to _nLen_
			_aMetrics_ + [ _aReg_[_i_][1], _aReg_[_i_][2],
				@oMon.MetricQ(_aReg_[_i_][1]).Value() ]
		next
		@aBlackBox + [
			:at = StzEngineWatchTimestampMs(),
			:rule = paFinding[:rule],
			:message = paFinding[:message],
			:rssBytes = StzEnginePerfMemRss(),
			:peakBytes = StzEnginePerfMemPeak(),
			:cpuMs = StzEnginePerfCpuNs() / 1000000,
			:sysFreeBytes = StzEnginePerfSysMemFree(),
			:metrics = _aMetrics_,
			# perf P7: the trace ids of the requests nearest the breach
			# (the monitor's engine trace ring -- the server face
			# recorded them, this face reads the same truth). Empty
			# when the monitor does not trace.
			:traces = @oMon.RecentTraces(8)
		]
		if ring_len(@aBlackBox) > 16
			del(@aBlackBox, 1)
		ok

	def BlackBox()
		return @aBlackBox

	def LastBlackBox()
		_n_ = ring_len(@aBlackBox)
		if _n_ = 0
			return []
		ok
		return @aBlackBox[_n_]
