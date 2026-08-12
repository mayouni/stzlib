/*
	stzSecuritySentinel -- the watcher (incident I4).

	A detection set judges when asked. The sentinel asks ON A CADENCE
	and turns verdict TRANSITIONS into alerts -- the same shape the
	perf system proved (stzPerfSentinel), pointed at security:

		oSent = StzSecuritySentinel(StzDefaultDetectionSet())
		oSent.OnDetection(func aFinding { ? "ALERT: " + aFinding[:message] })
		oSent.OnClear(func cWhere { ? "cleared: " + cWhere })
		oSent.Check()                 # one pass -> fires transitions

	EDGE-TRIGGERED, and the identity of "a thing that fired" is the
	finding's :where -- `credential-stuffing/victim`, not merely
	`credential-stuffing`. Two accounts under attack are two stories,
	and one account still under attack is not a new one every second.
	An alarm that repeats itself is how real alarms get ignored (the
	lesson I3 paid for in its sequence shape).

	Three ways to run it, the house trio:
	  PULL    Check() whenever you like.
	  TICK    Every(ms) + Tick() from any loop you already run.
	  HOSTED  Name_() + Cycle() -- any stzAgentHost supervises it, so
	          a served application watches itself while serving.

	Every transition also fans out on the process-global event bus
	(`sec.detection` / `sec.clear`), so an agent supervised ON that
	channel wakes exactly when something fires -- and any part of the
	process can poll the counts without holding the sentinel.

	THE CASE SNAPSHOT: when something fires, the sentinel photographs
	what was 1 at that moment -- the finding, the ledger's head
	digest (which commits to the whole history), how many events
	existed, and the events nearest the firing. This is the perf
	black box in security clothes, and it is what I5's incident will
	be built from: the investigation should not have to re-derive the
	moment of detection later, when the window may have moved on.

	Deliberately NOT done: the sentinel does not write its own firings
	into the ledger as events. Detections over detection-events invite
	feedback, and the ledger is a record of what the SYSTEM did, not
	of what the watcher thought about it. The alert log is the
	watcher's own memory, kept separately and bounded.
*/

func StzSecuritySentinel(poDetectionSet)
	return new stzSecuritySentinel(poDetectionSet)

class stzSecuritySentinel from stzObject

	@cName = "security-sentinel"
	@oSet = ""
	@oLedger = ""		# NULL = watch the process ledger
	@aActive = []		# :where keys currently firing
	@fOnDetection = ""
	@fOnClear = ""
	@bHasOnDetection = 0
	@bHasOnClear = 0
	@cDetectionChannel = "sec.detection"
	@cClearChannel = "sec.clear"
	@oBus = ""
	@aAlertLog = []		# [ atMs, "detection"|"clear", where, message ] (256)
	@aCases = []		# case snapshots, newest 16
	@nEveryMs = 1000
	@nNextDueMs = 0
	@nChecks = 0

	def init(poDetectionSet)
		@oSet = poDetectionSet
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

	# Watch a specific ledger instead of the process one.
	def Watching(poLedger)
		@oLedger = poLedger
		return This

	def OnDetection(pfCallback)
		@fOnDetection = pfCallback
		@bHasOnDetection = 1
		return This

	def OnClear(pfCallback)
		@fOnClear = pfCallback
		@bHasOnClear = 1
		return This

	def SetChannels(pcDetection, pcClear)
		@cDetectionChannel = "" + pcDetection
		@cClearChannel = "" + pcClear
		return This

	def DetectionChannel()
		return @cDetectionChannel

	def ClearChannel()
		return @cClearChannel

	def Every(pnMs)
		if isNumber(pnMs) and pnMs >= 1
			@nEveryMs = pnMs
		ok
		return This

	  #-- watching -----------------------------------------------------

	# One pass: judge, then fire only what CHANGED. Returns the number
	# of NEW firings.
	def Check()
		_oLed_ = This._Ledger()
		if _oLed_ = ""
			return 0
		ok
		@nChecks++
		_aF_ = @oSet.CheckAgainst(_oLed_)
		_aNow_ = []
		_nLen_ = ring_len(_aF_)
		for _i_ = 1 to _nLen_
			_aNow_ + _aF_[_i_][:where]
		next
		_nNew_ = 0
		for _i_ = 1 to _nLen_
			if ring_find(@aActive, _aF_[_i_][:where]) = 0
				This._FireDetection(_aF_[_i_], _oLed_)
				_nNew_++
			ok
		next
		_nA_ = ring_len(@aActive)
		for _i_ = 1 to _nA_
			if ring_find(_aNow_, @aActive[_i_]) = 0
				This._FireClear(@aActive[_i_])
			ok
		next
		@aActive = _aNow_
		return _nNew_

	# Cadence-gated on the monotonic clock -- call from any loop.
	def Tick()
		_nNow_ = StzEngineWatchTimestampMs()
		if _nNow_ < @nNextDueMs
			return 0
		ok
		@nNextDueMs = _nNow_ + @nEveryMs
		return This.Check()

	# The agent-host contract: watching IS this agent's act.
	def Cycle()
		return This.Tick()

	def CheckCount()
		return @nChecks

	  #-- reading ------------------------------------------------------

	def ActiveDetections()
		return @aActive

	def IsFiring()
		return ring_len(@aActive) > 0

	def AlertLog()
		return @aAlertLog

	def LastAlert()
		_n_ = ring_len(@aAlertLog)
		if _n_ = 0
			return []
		ok
		return @aAlertLog[_n_]

	# The case snapshots taken at firing time (newest last).
	def Cases()
		return @aCases

	def LastCase()
		_n_ = ring_len(@aCases)
		if _n_ = 0
			return []
		ok
		return @aCases[_n_]

	def Explain()
		_aL_ = []
		_cS_ = "quiet"
		if ring_len(@aActive) > 0
			_cS_ = "" + ring_len(@aActive) + " active detection(s)"
		ok
		_aL_ + ("Sentinel " + @cName + " -- " + @nChecks + " check(s), " + _cS_ + ".")
		_nA_ = ring_len(@aActive)
		for _i_ = 1 to _nA_
			_aL_ + ("  FIRING: " + @aActive[_i_])
		next
		return _aL_

	def Show()
		_aL_ = This.Explain()
		_nL_ = ring_len(_aL_)
		for _i_ = 1 to _nL_
			? _aL_[_i_]
		next

	  #-- internals ----------------------------------------------------

	def _Ledger()
		if @oLedger != ""
			return @oLedger
		ok
		return StzSecurityLedgerQ()

	def _FireDetection(paFinding, poLedger)
		This._Log("detection", paFinding[:where], paFinding[:message])
		This._RecordCase(paFinding, poLedger)
		@oBus.Emit(@cDetectionChannel, paFinding[:where] + " | " + paFinding[:message])
		if @bHasOnDetection
			_f_ = @fOnDetection
			call _f_(paFinding)
		ok

	def _FireClear(pcWhere)
		This._Log("clear", pcWhere, "no longer firing")
		@oBus.Emit(@cClearChannel, pcWhere + " | cleared")
		if @bHasOnClear
			_f_ = @fOnClear
			call _f_(pcWhere)
		ok

	def _Log(pcKind, pcWhere, pcMessage)
		@aAlertLog + [ StzEngineWatchTimestampMs(), pcKind, pcWhere, pcMessage ]
		if ring_len(@aAlertLog) > 256
			del(@aAlertLog, 1)
		ok

	# The photograph: what was true at the moment of firing.
	def _RecordCase(paFinding, poLedger)
		@aCases + [
			:at = StzEngineTimeWallMs(),
			:where = paFinding[:where],
			:rule = paFinding[:rule],
			:severity = paFinding[:severity],
			:message = paFinding[:message],
			:ledgerCount = poLedger.Count(),
			:headDigest = poLedger.Digest(),
			:recent = poLedger.Recent(8)
		]
		if ring_len(@aCases) > 16
			del(@aCases, 1)
		ok
