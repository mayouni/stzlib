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

# Judges an SLA on a cadence and turns changes of verdict into alerts, one when a breach appears and one when it clears.
#
# An SLA judges when asked; the sentinel judges on a cadence and is edge-triggered, which is the
# honest flap suppression: a breach fires once when it appears and a recovery once when it clears,
# so an invariant that stays broken does not page you four hundred times. Run it three ways: Check
# whenever you like, Every and Tick from any loop, or hosted by an agent host through Name_ and
# Cycle. Every alert also goes out on the engine event bus, perf.breach and perf.clear, and a new
# breach takes a black-box snapshot of the process. The ledger keeps the newest 256 alerts. Explain
# and Show raise error R41 today while a rule is breached.
#
#   receiver   oMon = StzPerfMonitor("api") oDepth = oMon.NewGauge("queue.depth") oDepth.Set(50)
#              oSla = StzSla("api") oSla.ExpectValue("queue.depth").AtMost(100) o1 =
#              StzPerfSentinel(oSla, oMon)
#   example    ? o1.Check()
#              #--> 0
#              oDepth.Set(150)
#              ? o1.Check()
#              #--> 1
#              ? o1.IsBreached()
#              #--> 1
#              ? @@( o1.ActiveBreaches() )
#              #--> [ "value-queue.depth-under-100" ]
#              ? o1.Check()
#              #--> 0
#              ? o1.LastAlert()[2]
#              #--> breach
#              ? o1.LastBlackBox()[:metrics][1][3]
#              #--> 150
#              oDepth.Set(10)
#              ? o1.Check()
#              #--> 0
#              ? o1.LastAlert()[2]
#              #--> clear
#              ? o1.CheckCount()
#              #--> 4
#   see        stzSla, stzPerfMonitor, stzEventBus, stzAgentHost
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

	# Builds a sentinel that judges an SLA against a monitor on a cadence and turns verdict changes into alerts.
	#
	#   poSla       the stzSla to judge
	#   poMonitor   the stzPerfMonitor whose metrics it reads
	#   returns     nothing; the object is built with its own event bus and no breach
	#   note        StzPerfSentinel builds the same object; the SLA is copied at birth, the monitor
	#               copy shares the engine-backed metrics, and the sentinel's own transition state
	#               lives in Ring, so one copy should drive Check and Tick
	#   see         Check, Tick, OnBreach
	def init(poSla, poMonitor)
		@oSla = poSla
		@oMon = poMonitor
		@oBus = new stzEventBus()

	# Returns the sentinel's name.
	#
	#   returns    the name as text, perf-sentinel until SetName changes it
	#   see        SetName, Name_
	def Name()
		return @cName

	# Returns the sentinel's name, the form an agent host asks for.
	#
	#   returns    the name as text, the same as Name
	#   see        Name, Cycle
	def Name_()
		return @cName

	# Sets the sentinel's name.
	#
	#   pcName     the new name, a non-empty text
	#   returns    the sentinel itself, so calls chain
	#   see        Name
	def SetName(pcName)
		if isString(pcName) and pcName != ""
			@cName = pcName
		ok
		return This

	# Sets the function called once when a rule newly breaches.
	#
	#   pfCallback   a function taking the finding, a hash list with rule, subject, where, severity
	#                and message
	#   returns      the sentinel itself, so calls chain
	#   note         it is edge-triggered: a rule that stays broken does not call it again
	#   see          OnClear, Check
	def OnBreach(pfCallback)
		@fOnBreach = pfCallback
		@bHasOnBreach = 1
		return This

	# Sets the function called once when a breached rule recovers.
	#
	#   pfCallback   a function taking the name of the rule that recovered
	#   returns      the sentinel itself, so calls chain
	#   see          OnBreach, Check
	def OnClear(pfCallback)
		@fOnClear = pfCallback
		@bHasOnClear = 1
		return This

	# Sets the names of the process-wide event channels the alerts are also published on.
	#
	#   pcBreach   the channel for breaches
	#   pcClear    the channel for recoveries
	#   returns    the sentinel itself, so calls chain
	#   note       the defaults are perf.breach and perf.clear, so an agent supervised on a channel
	#              wakes when the SLA breaks
	#   see        BreachChannel, ClearChannel
	#@ aka  The event-bus channels alerts fan out on (process-global).
	def SetChannels(pcBreach, pcClear)
		@cBreachChannel = "" + pcBreach
		@cClearChannel = "" + pcClear
		return This

	# Returns the channel breaches are published on.
	#
	#   returns    the channel name as text, perf.breach by default
	#   see        SetChannels, ClearChannel
	def BreachChannel()
		return @cBreachChannel

	# Returns the channel recoveries are published on.
	#
	#   returns    the channel name as text, perf.clear by default
	#   see        SetChannels, BreachChannel
	def ClearChannel()
		return @cClearChannel

	# Sets the cadence of Tick.
	#
	#   pnMs       the interval in milliseconds, 1 or more
	#   returns    the sentinel itself, so calls chain
	#   note       the default is 1000
	#   see        Tick, Check
	def Every(pnMs)
		if isNumber(pnMs) and pnMs >= 1
			@nEveryMs = pnMs
		ok
		return This

	# Judges the SLA once and fires alerts for the changes since the last judgment only.
	#
	#   returns    the number of new breaches in this pass
	#   note       a new breach logs, photographs the process in the black box, publishes on the
	#              breach channel and calls OnBreach; a recovery logs, publishes on the clear
	#              channel and calls OnClear; a breach that persists does nothing, which is the flap
	#              suppression; an unmeasured expectation counts as a breach
	#   see        Tick, OnBreach, ActiveBreaches
	#@ aka  -- Judging --------------------------------------------------
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

	# Returns how many judgments have been made.
	#
	#   returns    a number
	#   see        Check, Tick
	def CheckCount()
		return @nChecks

	# Judges the SLA if the cadence says it is due, for any loop to call.
	#
	#   returns    the number of new breaches; 0 when it was not due
	#   note       the first call is always due, then the next one waits for Every milliseconds on
	#              the monotonic clock; Cycle is the same call, which makes the sentinel hostable by
	#              a stzAgentHost
	#   see        Check, Every
	#@ aka  Cadence-gated judging, on the monotonic clock -- call from any loop. Returns the number of new breaches (0 when not due).
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

	# Returns the rules in breach as of the last judgment.
	#
	#   returns    a list of rule names
	#   see        IsBreached, Check
	#@ aka  -- Reading --------------------------------------------------
	def ActiveBreaches()
		return @aBreached

	# TRUE if any rule is in breach as of the last judgment.
	#
	#   returns    TRUE or FALSE, as 1 or 0
	#   see        ActiveBreaches
	def IsBreached()
		return ring_len(@aBreached) > 0

	# Returns the alerts so far, breaches and recoveries, oldest first.
	#
	#   returns    a list of [ time in milliseconds, breach or clear, rule, message ]; at most the
	#              newest 256
	#   note       the time is on the monotonic clock; a recovery's message is recovered
	#   see        LastAlert, BlackBox
	def AlertLog()
		return @aAlertLog

	# Returns the newest alert.
	#
	#   returns    a list [ time, breach or clear, rule, message ]; [ ] when there is none
	#   see        AlertLog
	def LastAlert()
		_n_ = ring_len(@aAlertLog)
		if _n_ = 0
			return []
		ok
		return @aAlertLog[_n_]

	# Returns the state as lines of text: the name, the number of checks and whether expectations are met, then each breached rule.
	#
	#   returns    a list of text lines
	#   note       with no breach the single line reads Sentinel name -- N check(s), all
	#              expectations met.
	#   warning    raises error R41 Invalid numeric string whenever a rule is in breach, because the
	#              state text adds the number of breaches to a text; it answers well only while
	#              nothing is breached
	#   see        Show, ActiveBreaches
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

	# Prints the explanation to the console, one line per line.
	#
	#   returns    nothing
	#   note       it prints with the ? statement
	#   warning    raises the same error R41 as Explain while a rule is in breach
	#   see        Explain
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

	# Returns the flight-recorder snapshots, one taken at each new breach.
	#
	#   returns    a list of hash lists, the newest 16
	#   note       each holds at, rule, message, rssBytes, peakBytes, cpuMs, sysFreeBytes, the
	#              current value of every metric and the recent trace ids; the values are live, so
	#              assert ranges and signs
	#   see        LastBlackBox, AlertLog
	def BlackBox()
		return @aBlackBox

	# Returns the newest flight-recorder snapshot.
	#
	#   returns    a hash list with the keys at, rule, message, rssBytes, peakBytes, cpuMs,
	#              sysFreeBytes, metrics and traces; [ ] when there is none
	#   note       metrics is a list of [ name, kind, value ]; traces is [ ] when the monitor does
	#              not trace
	#   see        BlackBox
	def LastBlackBox()
		_n_ = ring_len(@aBlackBox)
		if _n_ = 0
			return []
		ok
		return @aBlackBox[_n_]
